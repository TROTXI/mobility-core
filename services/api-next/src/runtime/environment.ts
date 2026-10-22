export type Environment = Record<string, string | undefined>;

/** Transitional read compatibility only. New configuration uses plain names.
 * Never overwrite a conflicting setting or change the supplied environment.
 */
export function backendEnvironment(source: Environment): Environment {
  const env = { ...source };
  for (const [name, value] of Object.entries(source)) {
    if (!name.startsWith('REPLACEMENT_') || value === undefined) continue;
    const suffix = name.slice('REPLACEMENT_'.length);
    const canonical = suffix === 'DATABASE_URL' ? 'MIGRATION_DATABASE_URL' : suffix;
    if (env[canonical] !== undefined && env[canonical] !== value)
      throw new Error(`Conflicting settings for ${canonical}; remove the old alias`);
    env[canonical] = value;
    delete env[name];
  }
  return env;
}
