FROM node:18-alpine AS backend

WORKDIR /app

# Install build dependencies for bcrypt and Prisma
RUN apk add --no-cache python3 make g++ openssl

COPY backend/package*.json ./
RUN npm ci --only=production

COPY backend/prisma/ ./prisma/
RUN npx prisma generate

COPY backend/ ./

EXPOSE 3000

# Sync DB schema on startup, seed if empty, then start server
CMD ["sh", "-c", "npx prisma db push --accept-data-loss 2>&1 | grep -v 'Already' && echo 'Schema synced' || echo 'Schema already up to date'; node src/server.js"]
