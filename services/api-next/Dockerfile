# Built from the repo ROOT context (the pnpm workspace lockfile lives there).
# Existing staging installs pending, checksum-verified migrations on startup.
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
# Only the named disposable staging service installs migrations on boot.
# Startup never resets data, provisions logins, or changes credentials.
# Telemetry loads first so it can instrument Fastify and pg as they load. It
# does nothing unless OTEL_EXPORTER_OTLP_ENDPOINT is set.
CMD ["node", "--import", "./dist/observability/telemetry.js", "dist/server.js"]
