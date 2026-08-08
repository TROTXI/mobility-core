# Demo & teaching assets

Static pages for team sessions and API exploration. Nothing here ships to
production — the Dockerfile only packages `services/api/dist`.

## auth-explainer.html — the authentication walkthrough

Nine interactive slides explaining how a client signs in and stays signed in:
the three tokens, the sign-in flow, refresh rotation and replay detection,
sessions, 401 vs 403, and the Dio interceptor contract. The last slide is a
live playground that calls the running dev API.

```bash
pnpm --filter @trotxi/api dev   # terminal 1 — API on :3000 (dev verifier)
pnpm demo:auth                  # terminal 2 — serves this folder on :4174
# open http://localhost:4174/auth-explainer.html
```

Navigate with arrow keys. The playground signs in through the dev verifier
(JSON claims as the idToken), so it works with zero Google configuration —
staging always requires a real Google-signed token.

## endpoints.html — the endpoint test console

Served by its own runner (boots the real app in-process and executes 91 live
cases across every endpoint):

```bash
pnpm --filter @trotxi/api demo:endpoints
# dashboard on :4400 · live Swagger on :3001/docs
```

See `ENDPOINTS.md` for details.
