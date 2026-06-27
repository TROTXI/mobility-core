import { describe, expect, it } from 'vitest';
import { generateRefreshToken, hashToken } from '../src/modules/auth/tokens';

describe('tokens', () => {
  it('hashToken is a deterministic sha256 hex digest', () => {
    expect(hashToken('abc')).toBe(hashToken('abc'));
    expect(hashToken('abc')).toMatch(/^[0-9a-f]{64}$/);
    expect(hashToken('abc')).not.toBe(hashToken('abd'));
  });

  it('generateRefreshToken returns a token whose hash matches, with a future expiry', () => {
    const r = generateRefreshToken(30);
    expect(r.token).toBeTruthy();
    expect(r.hash).toBe(hashToken(r.token));
    expect(r.expiresAt.getTime()).toBeGreaterThan(Date.now());
  });

  it('generates a unique token each call', () => {
    expect(generateRefreshToken(1).token).not.toBe(generateRefreshToken(1).token);
  });
});
