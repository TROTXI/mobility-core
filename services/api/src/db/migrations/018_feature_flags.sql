-- 018_feature_flags: the "deploy != release" keystone (#27). Home-grown flags for
-- the pilot (PostHog later). Two config tables the apps read on launch/session via
-- the public GET /flags, both ops-managed under /admin/*:
--   feature_flags   — a flag set, kill-switch (enabled) + %-rollout ready.
--   app_min_versions — the force-update floor per platform (min_supported_version).
-- Kept intentionally small: a real evaluator (cohorts, bucketing) lands with PostHog.

CREATE TABLE IF NOT EXISTS feature_flags (
  key                text PRIMARY KEY,                    -- e.g. "live_positions"
  enabled            boolean NOT NULL DEFAULT false,      -- the kill-switch
  -- %-rollout ready: 0–100. Returned as-is; per-user bucketing is a later concern.
  rollout_percentage integer NOT NULL DEFAULT 100
                       CHECK (rollout_percentage BETWEEN 0 AND 100),
  description        text,                                -- ops note (not shown to apps)
  updated_at         timestamptz NOT NULL DEFAULT now()
);

-- One row per app platform holding the minimum version the API still supports.
-- The apps compare their build against this on launch and force an update below it.
CREATE TABLE IF NOT EXISTS app_min_versions (
  platform   text PRIMARY KEY CHECK (platform IN ('ios', 'android')),
  version    text NOT NULL,                               -- semver, e.g. "1.2.0"
  updated_at timestamptz NOT NULL DEFAULT now()
);
