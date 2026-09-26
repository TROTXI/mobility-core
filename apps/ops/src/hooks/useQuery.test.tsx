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

  it('does not restart a slow request on polling ticks', async () => {
    let finish!: (value: string) => void;
    const loader = vi.fn(
      () =>
        new Promise<string>((resolve) => {
          finish = resolve;
        }),
    );
    const { result } = renderHook(() => useQuery(loader));
    act(() => {
      result.current.retry();
      result.current.retry();
    });
    expect(loader).toHaveBeenCalledOnce();
    await act(async () => finish('ready'));
    expect(result.current.data).toBe('ready');
  });

  it('rejects late successes after a filter change', async () => {
    let old!: (value: string) => void;
    const { result, rerender } = renderHook(
      ({ filter }) =>
        useQuery(
          () =>
            filter === 'old'
              ? new Promise<string>((resolve) => {
                  old = resolve;
                })
              : Promise.resolve('new'),
          [filter],
        ),
      { initialProps: { filter: 'old' } },
    );
    rerender({ filter: 'new' });
    await waitFor(() => expect(result.current.data).toBe('new'));
    await act(async () => old('stale'));
    expect(result.current.data).toBe('new');
  });

  it('waits while hidden and reads immediately when visible', async () => {
    const visibility = vi.spyOn(document, 'visibilityState', 'get').mockReturnValue('hidden');
    try {
      const loader = vi.fn().mockResolvedValue('ready');
      const { result } = renderHook(() => useQuery(loader));
      act(() => result.current.retry());
      expect(loader).not.toHaveBeenCalled();
      expect(result.current.loading).toBe(true);
      expect(result.current.data).toBeNull();
      visibility.mockReturnValue('visible');
      act(() => document.dispatchEvent(new Event('visibilitychange')));
      await waitFor(() => expect(result.current.data).toBe('ready'));
      expect(loader).toHaveBeenCalledOnce();
    } finally {
      visibility.mockRestore();
    }
  });
});
