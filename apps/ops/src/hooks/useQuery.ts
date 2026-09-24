import { useCallback, useEffect, useRef, useState } from 'react';

export function useQuery<T>(
  load: (signal: AbortSignal) => Promise<T>,
  dependencies: unknown[] = [],
) {
  const loadRef = useRef(load);
  loadRef.current = load;
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);
  const [generation, setGeneration] = useState(0);
  const retry = useCallback(() => setGeneration((value) => value + 1), []);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);
    setError('');
    void loadRef
      .current(controller.signal)
      .then(setData)
      .catch((value: Error) => {
        if (!controller.signal.aborted) setError(value.message);
      })
      .finally(() => {
        if (!controller.signal.aborted) setLoading(false);
      });
    return () => controller.abort();
    // Dependency values are intentionally supplied by each screen.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [generation, ...dependencies]);

  return { data, error, loading, retry, setData };
}
