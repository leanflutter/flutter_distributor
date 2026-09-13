//  @ts-check

import { tanstackConfig } from '@tanstack/eslint-config'

export default [
  ...tanstackConfig,
  {
    rules: {
      'import/order': 'off',
      'sort-imports': 'off',
      '@typescript-eslint/array-type': 'off',
      'pnpm/json-enforce-catalog': 'off',
    },
  },
  {
    // Generated from apps/studio-api/openapi.yaml — run `pnpm codegen` instead of
    // editing it, and do not lint what a generator wrote.
    ignores: ['eslint.config.js', 'src/schema.d.ts'],
  },
]
