# Built from the repo ROOT context (the pnpm workspace lockfile lives there).
# render.yaml sets dockerContext to the repo root and points here.
FROM node:22-alpine AS build
RUN corepack enable
WORKDIR /repo

# Install the API's dependency graph, cached on the workspace manifests.
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json ./
COPY services/api/package.json ./services/api/
COPY e2e/package.json ./e2e/
RUN pnpm install --frozen-lockfile --filter @trotxi/api...

# Build, then emit a self-contained production bundle into /app.
COPY services/api ./services/api
RUN pnpm --filter @trotxi/api run build \
  && pnpm --filter @trotxi/api deploy --prod --legacy /app

# ---- Runtime ----
FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/package.json ./package.json
EXPOSE 3000
CMD ["node", "dist/server.js"]
