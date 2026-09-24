import { act, renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { useQuery } from './useQuery';

describe('useQuery', () => {
  it('loads, exposes failures, and retries with the latest loader', async () => {
    const loader = vi
      .fn()
      .mockRejectedValueOnce(new Error('offline'))
      .mockResolvedValueOnce('ready');
    const { result } = renderHook(() => useQuery(loader));
    await waitFor(() => expect(result.current.error).toBe('offline'));
    act(() => result.current.retry());
    await waitFor(() => expect(result.current.data).toBe('ready'));
    expect(result.current.loading).toBe(false);
  });
  it('aborts the request when its consumer unmounts', () => {
    let signal: AbortSignal | undefined;
    const { unmount } = renderHook(() =>
      useQuery(async (value) => {
        signal = value;
        return 'pending';
      }),
    );
    unmount();
    expect(signal?.aborted).toBe(true);
  });
});
