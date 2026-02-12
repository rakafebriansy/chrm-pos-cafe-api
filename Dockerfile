# --- Stage 1: Build ---
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /usr/src/app

# Copy package.json dan package-lock.json files
COPY package*.json ./

# Copy prisma folder
COPY prisma ./prisma/

# Install dependencies
RUN npm install

# Generate Prisma Client
RUN npx prisma generate

# Copy all source code
COPY . .

# Build NestJS app (generate /dist folder)
RUN npm run build

# --- Stage 2: Production Run ---
FROM node:20-alpine

WORKDIR /usr/src/app

# Copy build file from Stage 1
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/package*.json ./
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/prisma ./prisma

# Expose port
EXPOSE 3000

# 1. Migrate Deploy: Update production database structure
# 2. Node dist/main: Run app
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main"]