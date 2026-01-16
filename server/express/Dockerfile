FROM node:20-alpine
WORKDIR /app

# Install dependencies. Prefer "npm ci" when a lockfile is present, otherwise fall back to install.
COPY package*.json ./
RUN if [ -f package-lock.json ]; then \
      npm ci --omit=dev; \
    else \
      npm install --omit=dev; \
    fi

COPY index.js ./
RUN mkdir -p /data/uploads
ENV PORT=8000
EXPOSE 8000
CMD ["node", "index.js"]
