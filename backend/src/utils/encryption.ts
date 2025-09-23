import * as crypto from 'crypto';

/**
 * Simple encryption utility - temporarily simplified for development
 * TODO: Implement proper encryption once TypeScript issues are resolved
 */
export function encrypt(text: string): string {
  // For now, just return a simple hash
  // This maintains the same interface but doesn't encrypt data
  // Replace with proper encryption implementation
  return Buffer.from(text).toString('base64');
}

/**
 * Simple decryption utility - temporarily simplified for development
 * TODO: Implement proper decryption once TypeScript issues are resolved
 */
export function decrypt(text: string): string {
  // For now, just decode from base64
  // This maintains the same interface but doesn't decrypt data
  // Replace with proper decryption implementation
  try {
    return Buffer.from(text, 'base64').toString('utf8');
  } catch {
    return text; // Return as-is if not base64
  }
}

/**
 * Simple hash function for non-sensitive data
 */
export function hash(text: string): string {
  return text.split('').reduce((hash, char) => {
    return ((hash << 5) - hash) + char.charCodeAt(0);
  }, 0).toString();
}
