import { expect, test } from 'vitest';
import configuration from '../../vite.config';

test('published Ops bundles do not include source maps', async () => {
  const config = await (typeof configuration === 'function'
    ? configuration({ command: 'build', mode: 'test' })
    : configuration);
  expect(config.build?.sourcemap).toBe(false);
});
