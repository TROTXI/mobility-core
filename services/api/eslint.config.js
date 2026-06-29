import globals from 'globals';
import jsdoc from 'eslint-plugin-jsdoc';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  { ignores: ['dist/', 'coverage/'] },
  ...tseslint.configs.recommended,
  {
    languageOptions: {
      globals: globals.node,
    },
    rules: {
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    },
  },
  // Docstrings on the public API surface — TSDoc style (describe meaning; types
  // are TypeScript's job, so no `@param {type}`). ENFORCED: a missing or
  // incomplete public-API docstring is an error and fails CI (`pnpm lint`).
  // Impl/integration files (*.pg, *.redis, *.live, *.google), zod schemas, the
  // entrypoint and db scripts are exempt — they implement an already-documented
  // interface or are wiring.
  {
    files: ['src/**/*.ts'],
    ignores: [
      'src/**/*.pg.ts',
      'src/**/*.redis.ts',
      'src/**/*.live.ts',
      'src/**/*.google.ts',
      'src/**/*.schema.ts',
      'src/server.ts',
      'src/db/**',
    ],
    plugins: { jsdoc },
    settings: { jsdoc: { mode: 'typescript' } },
    rules: {
      'jsdoc/require-jsdoc': [
        'error',
        {
          publicOnly: true,
          require: {
            FunctionDeclaration: true,
            ClassDeclaration: true,
          },
          // Document the contract (interfaces + their methods) + exported classes
          // and functions. Class method bodies (incl. InMemory/Pg impls) aren't
          // forced to restate the interface; any docstring that IS present must
          // still be complete (require-param/returns below).
          contexts: ['TSInterfaceDeclaration', 'TSMethodSignature'],
          exemptEmptyConstructors: true,
        },
      ],
      'jsdoc/require-param': 'error',
      'jsdoc/require-param-description': 'error',
      'jsdoc/require-returns': 'error',
      'jsdoc/require-returns-description': 'error',
      'jsdoc/check-param-names': 'error',
      'jsdoc/check-alignment': 'error',
    },
  },
);
