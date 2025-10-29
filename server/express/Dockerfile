FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY index.js ./
ENV PORT=8000
EXPOSE 8000
CMD ["node", "index.js"]

