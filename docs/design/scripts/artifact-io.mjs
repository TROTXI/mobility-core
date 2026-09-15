import { writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { format, resolveConfig } from '../../../node_modules/prettier/index.mjs';

export async function writeArtifact(url, value) {
  const path = fileURLToPath(url);
  const source = typeof value === 'string' ? value : JSON.stringify(value, null, 2);
  const options = await resolveConfig(path);
  await writeFile(url, await format(source, { ...options, filepath: path }));
}
