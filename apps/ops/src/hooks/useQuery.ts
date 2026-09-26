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
  const busy = useRef(false);
  const retry = useCallback(() => {
    if (!busy.current && document.visibilityState !== 'hidden') setGeneration((value) => value + 1);
  }, []);
  useEffect(() => {
    const resume = () => {
      if (document.visibilityState === 'visible') retry();
    };
    document.addEventListener('visibilitychange', resume);
    return () => document.removeEventListener('visibilitychange', resume);
  }, [retry]);
  // A changed filter/account must not display the previous query's rows.
  useEffect(() => {
    setData(null);
  }, dependencies); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    const controller = new AbortController();
    if (document.visibilityState === 'hidden') {
      // A deferred first read is not a successful empty result.
      setLoading(true);
      return;
    }
    busy.current = true;
    setLoading(true);
    setError('');
    void loadRef
      .current(controller.signal)
      .then((value) => {
        if (!controller.signal.aborted) setData(value);
      })
      .catch((value: Error) => {
        if (!controller.signal.aborted) setError(value.message);
      })
      .finally(() => {
        if (!controller.signal.aborted) {
          busy.current = false;
          setLoading(false);
        }
      });
    return () => {
      controller.abort();
      busy.current = false;
    };
    // Dependency values are intentionally supplied by each screen.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [generation, ...dependencies]);

  return { data, error, loading, retry, setData };
}
