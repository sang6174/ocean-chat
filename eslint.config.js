import js from '@eslint/js';
import ts from '@typescript-eslint/eslint-plugin';
import tsParser from '@typescript-eslint/parser';
import globals from 'globals';

export default [
  {
    ignores: ['node_modules', 'dist', 'build', 'bun.lockb'],
  },
  {
    files: ['**/*.ts', '**/*.tsx', '**/*.js'],
    languageOptions: {
      parser: tsParser,
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.node, 
        Bun: true,       
        console: true,   
      },
    },
    plugins: {
      '@typescript-eslint': ts,
    },
    rules: {
      ...js.configs.recommended.rules,
      ...ts.configs.recommended.rules,
      quotes: ['error', 'single'],
      semi: ['error', 'always'],
      indent: ['error', 2],
      '@typescript-eslint/indent': ['error', 2],
      'no-unused-vars': 'warn',
      '@typescript-eslint/no-explicit-any': 'off',
      'no-undef': 'off', 
    },
  },
];
