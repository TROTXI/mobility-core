# Built from the repo ROOT context (the pnpm workspace lockfile lives there).
# This image is for the replacement backend and is not the deployed service:
# nothing applies it until the blueprint entries in render.yaml are uncommented.
FROM node:24-alpine AS build
RUN corepack enable
WORKDIR /repo

COPY pnpm-lock.yaml pnpm-workspace.yaml package.json ./
COPY services/api-next/package.json ./services/api-next/
RUN pnpm install --frozen-lockfile --filter @trotxi/api-next...

COPY services/api-next ./services/api-next
RUN pnpm --filter @trotxi/api-next run build \
  && pnpm --filter @trotxi/api-next deploy --prod --legacy /app

# ---- Runtime ----
FROM node:24-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/package.json ./package.json
# The installer reads these at runtime and checks them against the recorded
# hashes, so the image carries the same bytes that were reviewed.
COPY --from=build /repo/services/api-next/migrations ./migrations
EXPOSE 10000
# No migration or grant on boot: installing the schema is a separate, deliberate
# step run by an operator with the owner credentials, not something a restart does.
CMD ["node", "dist/server.js"]
