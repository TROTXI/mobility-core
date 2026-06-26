# ADR-0008 — zod as the single source for validation & OpenAPI

**Status:** accepted · **Date:** 2026-06-25

## Context

The API already serves Swagger UI (`/docs`) and an OpenAPI document (`/docs/json`)
via `@fastify/swagger`, but routes carried no schemas — so the spec documented
nothing useful (no request/response shapes, no auth, no error bodies) and nothing
validated request input. We need a real, machine-readable contract: it is what
the Flutter apps build their client against, and it is the reference the backend
and frontend share.

ADR-0003 already committed us to **zod for runtime validation at the boundaries**
and "one type system across the wire." We did not want to hand-write JSON Schema
_and_ zod _and_ TypeScript types for every route — three copies that drift.

## Decision

**Each route declares one zod schema; it drives validation, response
serialization, TypeScript inference, and the OpenAPI spec.**

- **`fastify-type-provider-zod`** wires zod into Fastify: `validatorCompiler` +
  `serializerCompiler` are set on the app, and routes are defined through
  `app.withTypeProvider<ZodTypeProvider>()`. `jsonSchemaTransform` renders each
  zod schema into the OpenAPI document.
  - Pinned to the **v4 line** (peer `zod@^3`). v7 requires zod 4; bumping zod to
    a new major just for docs isn't worth the churn. Revisit when we move to zod 4.
- **Bearer (JWT) security scheme** is declared once (`components.securitySchemes.
bearerAuth`); protected routes opt in with `security: [{ bearerAuth: [] }]`
  (see ADR-0007). Public routes declare nothing.
- **Tags** group endpoints (`system`, `auth`, …) for a navigable spec.
- **Shared schemas** live next to their domain and are reused: `errorResponseSchema`
  (`lib/schemas.ts`) for error bodies, `userResponseSchema` (`modules/users/
user.schema.ts`) for user output. `GET /me` is the worked example.

### The convention (what every new route does)

```ts
app.withTypeProvider<ZodTypeProvider>().post(
  '/things',
  {
    schema: {
      tags: ['things'],
      summary: 'Create a thing',
      security: [{ bearerAuth: [] }], // omit for public routes
      body: z.object({ name: z.string().min(1) }),
      response: { 201: thingSchema, 400: errorResponseSchema },
    },
    preHandler: [app.authenticate],
  },
  handler,
);
```

## Consequences

- **Input is validated for free** — a `body`/`querystring`/`params` zod schema
  rejects bad requests (400) before the handler runs. Declare them on every route
  that takes input.
- **Responses are serialized against their schema.** A handler that returns data
  not matching the declared `response` schema fails loudly — keep response schemas
  honest. `Date` fields use `z.date()` (serialized to ISO date-time strings).
- **The spec is the contract.** The frontend can generate its client from
  `/docs/json` (e.g. `curl <staging>/docs/json`), so route schemas must stay
  accurate — they are not just documentation.
- Routes without schemas still work but are undocumented and unvalidated; in
  review we expect schemas on anything taking input or returning a body.
- Migrating to **zod 4** later means bumping `fastify-type-provider-zod` to v7+;
  that would supersede the version note here.
