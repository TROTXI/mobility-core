// How every failure leaves the API: one envelope, a bounded code, a request
// id, and a log line that says why without saying what the error said.
import type { FastifyInstance } from 'fastify';
import { TransportError, mapDatabaseError } from '../transport/errors.js';
import { LockedError } from '../auth/service.js';
import { failureLog } from '../observability/logging.js';

export function installErrorHandlers(app: FastifyInstance) {
  app.setErrorHandler((error, request, reply) => {
    // Busboy aborts a body it cannot parse with a stream error that carries no
    // status. That is the client's envelope, not our failure.
    const stream = (error as { code?: string }).code;
    // The avatar envelope permits one file and no text fields. Multipart
    // count limits are malformed input, not an oversized request body.
    if (
      stream === 'ERR_STREAM_PREMATURE_CLOSE' ||
      stream?.startsWith('FST_REQ_FILE') ||
      ['FST_FIELDS_LIMIT', 'FST_FILES_LIMIT', 'FST_PARTS_LIMIT'].includes(stream ?? '')
    )
      return reply.code(400).send({
        error: {
          code: 'invalid_request',
          message: 'Supply exactly one image part.',
          requestId: request.id,
        },
      });
    if (error instanceof LockedError) reply.header('Retry-After', String(error.retryAfterSeconds));
    const typed = error as { validation?: unknown; statusCode?: number };
    let safe: TransportError;
    if (error instanceof TransportError) safe = error;
    else if (typed.validation || [400, 413, 415].includes(typed.statusCode ?? 0))
      safe = new TransportError(
        typed.statusCode ?? 400,
        'invalid_request',
        'The request is invalid.',
      );
    else safe = mapDatabaseError(error);
    const failure = failureLog(error, safe.status, safe.code);
    if (safe.status >= 500) request.log.error(failure, 'request failed');
    else request.log.info(failure, 'request refused');
    reply
      .header('Cache-Control', 'no-store')
      .code(safe.status)
      .send({ error: { code: safe.code, message: safe.message, requestId: request.id } });
  });
  app.setNotFoundHandler((request, reply) =>
    reply.code(404).send({
      error: { code: 'not_found', message: 'Resource not found.', requestId: request.id },
    }),
  );
}
