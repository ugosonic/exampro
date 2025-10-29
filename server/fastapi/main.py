import os
import asyncio
from typing import Any, Dict
from fastapi import FastAPI, Depends, Header, HTTPException
from fastapi.responses import JSONResponse
import asyncpg
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv('DATABASE_URL')
SYNC_ADMIN_TOKEN = os.getenv('SYNC_ADMIN_TOKEN', '')

app = FastAPI(title='ExamPro Sync API', version='1.0.0')

async def get_pool() -> asyncpg.Pool:
    if not hasattr(app.state, 'pool'):
        app.state.pool = await asyncpg.create_pool(DATABASE_URL, min_size=1, max_size=5)
    return app.state.pool

@app.on_event('shutdown')
async def shutdown():
    pool = getattr(app.state, 'pool', None)
    if pool:
        await pool.close()

@app.get('/sync/version')
async def version(pool: asyncpg.Pool = Depends(get_pool)):
    async with pool.acquire() as conn:
        row = await conn.fetchrow('SELECT version FROM content_meta WHERE id = 1')
        if not row:
            await conn.execute('INSERT INTO content_meta(id) VALUES (1) ON CONFLICT (id) DO NOTHING')
            row = await conn.fetchrow('SELECT version FROM content_meta WHERE id = 1')
        return {'version': row['version'].isoformat()}

TABLES = [
    'categories',
    'subcategories',
    'exams',
    'questions',
    'choices',
    'exam_questions',
    'exam_grade_bands',
]

async def fetch_all(conn: asyncpg.Connection, table: str):
    rows = await conn.fetch(f'SELECT * FROM {table}')
    return [dict(r) for r in rows]

@app.get('/sync/snapshot')
async def snapshot(pool: asyncpg.Pool = Depends(get_pool)):
    async with pool.acquire() as conn:
        ver_row = await conn.fetchrow('SELECT version FROM content_meta WHERE id = 1')
        version = ver_row['version'].isoformat() if ver_row else None
        data: Dict[str, Any] = {'version': version}
        for t in TABLES:
            data[t] = await fetch_all(conn, t)
        return JSONResponse(data)

@app.post('/admin/bump-version')
async def bump_version(authorization: str = Header(default=''), pool: asyncpg.Pool = Depends(get_pool)):
    if not SYNC_ADMIN_TOKEN:
        raise HTTPException(status_code=403, detail='Not configured')
    if not authorization or not authorization.startswith('Bearer '):
        raise HTTPException(status_code=401, detail='Missing token')
    token = authorization.split(' ', 1)[1].strip()
    if token != SYNC_ADMIN_TOKEN:
        raise HTTPException(status_code=403, detail='Invalid token')
    async with pool.acquire() as conn:
        await conn.execute('UPDATE content_meta SET version = now() WHERE id = 1')
    return {'ok': True}

# Run: uvicorn main:app --reload --port 8000

