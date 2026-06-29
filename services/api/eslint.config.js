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
  // are TypeScript's job, so no `@param {type}`). WARN for now while modules are
  // documented; flip to `error` (+ `--max-warnings 0`) to make a missing or
  // incomplete docstring fail CI. Impl/integration files (*.pg, *.redis, *.live,
  // *.google), zod schemas, the entrypoint and db scripts are exempt — they
  // implement an already-documented interface or are wiring.
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
        'warn',
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
      'jsdoc/require-param': 'warn',
      'jsdoc/require-param-description': 'warn',
      'jsdoc/require-returns': 'warn',
      'jsdoc/require-returns-description': 'warn',
      'jsdoc/check-param-names': 'warn',
      'jsdoc/check-alignment': 'warn',
    },
  },
);
