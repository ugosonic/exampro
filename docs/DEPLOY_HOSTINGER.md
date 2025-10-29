Hostinger VPS Deployment (API Mode)

Prereqs
- Domain pointed to your VPS public IP (e.g., api.example.com)
- Neon Postgres project with a DATABASE_URL (Serverless w/ pooled connection recommended)
- SSH access to VPS

Install Docker on VPS
- sudo apt-get update && sudo apt-get install -y ca-certificates curl gnupg
- sudo install -m 0755 -d /etc/apt/keyrings
- curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
- echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
- sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

Clone project
- sudo mkdir -p /opt/exampro && sudo chown $USER:$USER /opt/exampro
- cd /opt/exampro
- git clone https://github.com/<you>/<repo>.git .

Configure env
- cp .env.example .env
- Edit .env and set:
  - DATABASE_URL=postgres://... (Neon)
  - SYNC_ADMIN_TOKEN=... (any strong random string)

Configure domain in Caddyfile
- Edit server/Caddyfile and replace api.example.com with your domain; optionally update email

Start stack
- docker compose up -d --build
- docker compose logs -f (until you see Caddy certificates issued and API listening)

Verify
- curl -k https://api.example.com/health
- curl -k https://api.example.com/sync/version

Images (media)
- Simple local hosting:
  - Upload images (categories/subcategories) via SFTP to /opt/exampro/server/media/categories and /opt/exampro/server/media/subcategories
  - Access at https://api.example.com/media/categories/<file>
  - In Admin Console, paste the HTTPS URL into the Image URL field when creating/updating.
- Recommended production: Use S3-compatible storage (Hostinger Object Storage) or Cloudflare R2 and paste the public HTTPS URL.

App configuration (production build)
- Set assets/env/vc.env in the app build to:
  - API_BASE_URL=https://api.example.com
  - DATABASE_URL= (leave empty to disable Neon-direct from app)
  - ADMIN_EMAILS=you@example.com (optional admin override)

CI/CD from GitHub (optional)
- Add the workflow .github/workflows/deploy-api.yml and set repo secrets:
  - VPS_HOST, VPS_USER, VPS_KEY (private key), VPS_DIR=/opt/exampro
- On push to main, the workflow SSHes into VPS and redeploys via docker compose.

