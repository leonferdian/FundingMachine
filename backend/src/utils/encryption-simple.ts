import * as crypto from 'crypto';

// Use environment variable for encryption key, fallback for development
const ENCRYPTION_KEY_INPUT = process.env.ENCRYPTION_KEY || 'development-encryption-key-32-byte-secure-key-for-aes-256-cbc-encryption';
const ENCRYPTION_KEY = crypto.createHash('sha256').update(ENCRYPTION_KEY_INPUT).digest().subarray(0, 32);
const ALGORITHM = 'aes-256-cbc';
const IV_LENGTH = 16;

export function encrypt(text: string): string {
  try {
    const iv = crypto.randomBytes(IV_LENGTH);
    const key = Buffer.from(ENCRYPTION_KEY);
    const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');

    // Return IV + encrypted data
    return iv.toString('hex') + ':' + encrypted;
  } catch (error) {
    console.error('Encryption error:', error);
    throw new Error('Failed to encrypt data');
  }
}

export function decrypt(text: string): string {
  try {
    const textParts = text.split(':');
    const iv = Buffer.from(textParts.shift()!, 'hex');
    const encryptedText = textParts.join(':');
    const key = Buffer.from(ENCRYPTION_KEY);

    const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
    let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
    decrypted += decipher.final('utf8');

    return decrypted;
  } catch (error) {
    console.error('Decryption error:', error);
    throw new Error('Failed to decrypt data');
  }
}

export function hash(text: string): string {
  return crypto.createHash('sha256').update(text).digest('hex');
}
