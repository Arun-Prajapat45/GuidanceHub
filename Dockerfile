# ---------- Base ----------
FROM node:20-alpine AS base
WORKDIR /app

# ---------- Dependencies ----------
FROM base AS deps
COPY package*.json ./
RUN npm install

# ---------- Builder ----------
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build
# ---------- Runner ----------
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules

# Next.js
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/app ./app
COPY --from=builder /app/next.config.mjs ./next.config.mjs

# 🔥 REQUIRED for Express server
COPY --from=builder /app/models ./models
COPY --from=builder /app/database ./database
COPY --from=builder /app/utils ./utils
COPY --from=builder /app/uploads ./uploads

EXPOSE 3000 3001

CMD ["npm", "run", "prod"]
