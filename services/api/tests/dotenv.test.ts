import { describe, expect, it, beforeEach, afterEach, vi } from 'vitest';
import { existsSync, writeFileSync, unlinkSync } from 'node:fs';
import { resolve } from 'node:path';
import { loadDotenv } from '../src/config/dotenv';

describe('loadDotenv', () => {
  const testEnvPath = resolve(process.cwd(), '.env.test');
  const originalEnv = { ...process.env };

  beforeEach(() => {
    // Clean up any existing test .env file
    if (existsSync(testEnvPath)) {
      unlinkSync(testEnvPath);
    }
  });

  afterEach(() => {
    // Clean up test .env file
    if (existsSync(testEnvPath)) {
      unlinkSync(testEnvPath);
    }
    // Restore original environment
    process.env = { ...originalEnv };
  });

  it('loads .env when present', () => {
    // Create a test .env file
    const envPath = resolve(process.cwd(), '.env');
    const testContent = 'TEST_VAR=test_value\nANOTHER_VAR=another_value\n';
    
    // Clean up if exists
    if (existsSync(envPath)) {
      unlinkSync(envPath);
    }

    try {
      writeFileSync(envPath, testContent);
      
      // Clear the test variables first
      delete process.env.TEST_VAR;
      delete process.env.ANOTHER_VAR;

      loadDotenv();

      // Verify environment variables were loaded
      expect(process.env.TEST_VAR).toBe('test_value');
      expect(process.env.ANOTHER_VAR).toBe('another_value');
    } finally {
      // Clean up
      if (existsSync(envPath)) {
        unlinkSync(envPath);
      }
    }
  });

  it('no-ops when .env is absent', () => {
    const envPath = resolve(process.cwd(), '.env');
    
    // Ensure .env doesn't exist
    if (existsSync(envPath)) {
      unlinkSync(envPath);
    }

    // Should not throw
    expect(() => loadDotenv()).not.toThrow();
  });

  it('throws when .env file is malformed', () => {
    const envPath = resolve(process.cwd(), '.env');
    
    // Clean up if exists
    if (existsSync(envPath)) {
      unlinkSync(envPath);
    }

    try {
      // Create a malformed .env file (this might not actually cause an error with process.loadEnvFile)
      // but we test the error handling path
      writeFileSync(envPath, 'INVALID LINE WITHOUT EQUALS');
      
      // Mock process.loadEnvFile to throw an error
      const originalLoadEnvFile = process.loadEnvFile;
      process.loadEnvFile = vi.fn(() => {
        throw new Error('Malformed .env file');
      });

      expect(() => loadDotenv()).toThrow('Malformed .env file');

      // Restore
      process.loadEnvFile = originalLoadEnvFile;
    } finally {
      // Clean up
      if (existsSync(envPath)) {
        unlinkSync(envPath);
      }
    }
  });
});

