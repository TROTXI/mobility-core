import contract from './contract.json' with { type: 'json' };

/** Undo only the exclusive-bound adaptation made by build-transport-contract.mjs. */
function openApi30(value: unknown): any {
  if (Array.isArray(value)) return value.map(openApi30);
  if (!value || typeof value !== 'object') return value;
  const out: Record<string, unknown> = {};
  for (const [key, child] of Object.entries(value)) {
    if ((key === 'exclusiveMinimum' || key === 'exclusiveMaximum') && typeof child === 'number') {
      out[key === 'exclusiveMinimum' ? 'minimum' : 'maximum'] = child;
      out[key] = true;
    } else out[key] = openApi30(child);
  }
  return out;
}

export function openApiDocument(origin: string, enabledOperations: ReadonlySet<string>) {
  const paths = Object.fromEntries(
    Object.entries(contract.paths).flatMap(([path, methods]) => {
      const enabled = Object.entries(methods).filter(([, operation]) =>
        enabledOperations.has(operation.operationId),
      );
      return enabled.length
        ? [
            [
              path,
              Object.fromEntries(
                enabled.map(([method, operation]) => [
                  method,
                  Object.fromEntries(
                    Object.entries(operation).filter(
                      ([key]) => key !== 'x-delivery-stage' && key !== 'x-implementation-status',
                    ),
                  ),
                ]),
              ),
            ],
          ]
        : [];
    }),
  );
  return {
    openapi: '3.0.3',
    info: {
      title: 'Trotxi API',
      version: '1.0.0',
      description:
        'This deployment’s enabled endpoints. Reads use a data envelope; lists also return ' +
        'page.nextCursor. Money is integer pesewas in { amountMinor, currency }. ' +
        'Send the client metadata declared by each operation. Retry mutations with the same ' +
        'Idempotency-Key and unchanged body; edits additionally use If-Match from editToken. ' +
        'Staging checkout uses Paystack TEST payments only.',
    },
    servers: [{ url: origin }],
    paths: openApi30(paths),
    components: openApi30(contract.components),
  };
}
