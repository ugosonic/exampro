# ExamPro API Contract (REST)

Auth
- POST /auth/sign-in
  - Body: { email: string, password: string }
  - 200: { access: string, refresh: string }
  - 401: { error: 'invalid_credentials' }
- POST /auth/refresh
  - Body: { refresh: string }
  - 200: { access: string, refresh: string }
- GET /auth/me
  - 200: { id: string, email: string, role: 'user'|'admin' }

Catalog
- GET /categories
  - 200: [ { id: number, name: string, order: number } ]
- GET /categories/:id/subcategories
  - 200: [ { id: number, name: string, order: number } ]
- GET /exams?categoryId=&subcategoryId=&published=
  - 200: [ { id: number, title: string, categoryId: number, questionCount: number, published: boolean } ]

Admin (requires role=admin)
- POST /categories { name, order }
- PATCH /categories/:id { name?, order? }
- DELETE /categories/:id
- Similar CRUD for subcategories
- POST /exams { title, description, categories: [id], modes, rules }
- PATCH /exams/:id { ... } (includes publish/unpublish and version note)

Questions
- GET /exams/:id/questions?mode=practice|mock|adaptive&limit=
  - 200: [ { id, text, options: [string], answers: [index], explanation?: string, version: number } ]
- POST /questions/import (CSV/JSON)

Attempts
- POST /attempts { examId, mode, startedAt }
  - 201: { attemptId }
- POST /attempts/:id/answer { questionId, selected: [index], timeMs }
- POST /attempts/:id/submit { endedAt }
  - 200: { score, accuracy, breakdown: [ { topic, correct, total } ] }
- GET /attempts?userId=&examId=&limit=20

Analytics
- GET /analytics/category/:id
  - 200: { attempts, avgScore, heatmap: [ { topic, accuracy } ], hardest: [questionId] }

Security
- All endpoints (except sign-in/refresh) require `Authorization: Bearer <access>`
- JWT includes role claim; server enforces RBAC
- Rate limits and standard error shapes: { error: string, message?: string }

