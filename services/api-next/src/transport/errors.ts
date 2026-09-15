export class TransportError extends Error {
  constructor(
    public readonly status: number,
    public readonly code: string,
    message: string,
  ) {
    super(message);
  }
}
export function fail(status: number, code: string, message: string): never {
  throw new TransportError(status, code, message);
}
export function mapDatabaseError(error: unknown): TransportError {
  if (error instanceof TransportError) return error;
  const e = error as { code?: string; constraint?: string; message?: string };
  if (e.code === '23505')
    return new TransportError(
      409,
      'duplicate_resource',
      'This departure or command already exists.',
    );
  if (e.code === '23503')
    return new TransportError(
      409,
      'invalid_reference',
      'The selected resources do not belong together.',
    );
  if (e.code === '23514' || e.code === '23P01')
    return new TransportError(
      409,
      'transport_conflict',
      'This change is not valid for the current transport state.',
    );
  if (e.code === '22P02') return new TransportError(404, 'not_found', 'Resource not found.');
  if (
    e.code?.startsWith('08') ||
    ['40001', '40P01', '55P03', '57014', '57P01', 'ECONNREFUSED', 'ETIMEDOUT'].includes(
      e.code ?? '',
    )
  )
    return new TransportError(
      503,
      'transport_unavailable',
      'Transport is temporarily unavailable.',
    );
  return new TransportError(500, 'internal_error', 'The operation could not be completed.');
}
