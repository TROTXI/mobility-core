// The live API document and its viewer.
import type { FastifyInstance } from 'fastify';
import { openApiDocument } from './openapi.js';

/** Returns the set the route loop fills with each operation it registers. */
export function installDocs(app: FastifyInstance) {
  // The old service served Swagger UI at /docs and the cutover dropped it, which
  // also removed the /docs/json the ops console's openapi-typescript step reads.
  // Built from the same contract this factory compiles its routes from, so the
  // document cannot describe an endpoint the service does not have. Live build
  // identity stays at /version rather than being restated here and drifting.
  //
  // Unauthenticated, which is what the old service did. That publishes the ops
  // surface to anyone who reaches the host, and is a decision to revisit before
  // there is a production deployment worth reading.
  // Populated at the same branches that register handlers. Optional providers
  // and unwired services must not appear just because they exist in the contract.
  const documentedOperations = new Set<string>();
  app.get('/docs/json', async (request, reply) => {
    reply.header('Cache-Control', 'no-store');
    return openApiDocument(`${request.protocol}://${request.host}`, documentedOperations);
  });
  app.get('/docs', async (_request, reply) => {
    reply.header('Cache-Control', 'no-store').type('text/html; charset=utf-8');
    // Same origin, so the renderer fetches the document above rather than
    // carrying a second copy that could disagree with it.
    return `<!doctype html><html><head><meta charset="utf-8">
<title>Trotxi API</title><meta name="viewport" content="width=device-width,initial-scale=1">
<script src="https://cdnjs.cloudflare.com/ajax/libs/rapidoc/9.3.8/rapidoc-min.js"></script>
<style>html,body{margin:0;height:100%}rapi-doc{height:100vh;width:100%}</style></head>
<body><rapi-doc spec-url="/docs/json" theme="light" bg-color="#F6F7F4" text-color="#0B1C30"
  primary-color="#1F6B4A" nav-bg-color="#013215" nav-text-color="#C9D6CB"
  nav-hover-bg-color="#0B4423" nav-accent-color="#BDCABE" render-style="read"
  schema-style="table" show-header="false" allow-spec-url-load="false"
  allow-spec-file-load="false" show-method-in-nav-bar="as-colored-text"
  persist-auth="true"
  use-path-in-nav-bar="true" sort-endpoints-by="path"></rapi-doc></body></html>`;
  });
  return documentedOperations;
}
