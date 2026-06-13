.DEFAULT_GOAL := help
COMPOSE := docker compose -f infra/docker/docker-compose.yml
API := @trotxi/api
E2E := @trotxi/e2e

.PHONY: help
help: ## List available tasks
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

## ---- Infra ----
.PHONY: up
up: ## Start Postgres, Redis, EMQX
	$(COMPOSE) up -d

.PHONY: down
down: ## Stop infra containers
	$(COMPOSE) down

.PHONY: logs
logs: ## Tail infra logs
	$(COMPOSE) logs -f

.PHONY: ps
ps: ## Show infra container status
	$(COMPOSE) ps

## ---- Dependencies ----
.PHONY: install
install: ## Install all workspace dependencies (API + e2e + tooling)
	pnpm install

## ---- API (services/api) ----
.PHONY: dev
dev: ## Run API in watch mode
	pnpm --filter $(API) run dev

.PHONY: test
test: ## Run API unit tests
	pnpm --filter $(API) test

.PHONY: coverage
coverage: ## Run API tests with coverage
	pnpm --filter $(API) run test:coverage

.PHONY: typecheck
typecheck: ## Typecheck the API
	pnpm --filter $(API) run typecheck

.PHONY: lint
lint: ## Lint the API
	pnpm --filter $(API) run lint

.PHONY: format
format: ## Auto-format the whole repo (Prettier)
	pnpm run format

.PHONY: format-check
format-check: ## Check formatting without writing (Prettier)
	pnpm run format:check

.PHONY: check
check: format-check typecheck lint test ## Run all quality gates

## ---- End-to-end (e2e) ----
.PHONY: e2e
e2e: ## Run Playwright e2e suite
	pnpm --filter $(E2E) test

.PHONY: e2e-ui
e2e-ui: ## Run the e2e suite in Playwright's interactive UI
	pnpm --filter $(E2E) run test:ui
