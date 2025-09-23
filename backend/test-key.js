const crypto = require('crypto');

// Test the encryption key generation
const ENCRYPTION_KEY_INPUT = process.env.ENCRYPTION_KEY || 'development-encryption-key-32-byte-secure-key-for-aes-256-cbc-encryption';
const ENCRYPTION_KEY = crypto.createHash('sha256').update(ENCRYPTION_KEY_INPUT).digest().subarray(0, 32);
const ALGORITHM = 'aes-256-cbc';
const IV_LENGTH = 16;

console.log('Testing encryption key generation...');
console.log('Key input:', ENCRYPTION_KEY_INPUT);
console.log('Key length (bytes):', ENCRYPTION_KEY.length);
console.log('Key (hex):', ENCRYPTION_KEY.toString('hex'));

// Test encryption
try {
  const iv = crypto.randomBytes(IV_LENGTH);
  const key = Buffer.from(ENCRYPTION_KEY);
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
  let encrypted = cipher.update('test-data', 'utf8', 'hex');
  encrypted += cipher.final('hex');

  console.log('Encryption successful');
  console.log('IV length:', iv.length);
  console.log('Encrypted data:', iv.toString('hex') + ':' + encrypted);
} catch (error) {
  console.error('Encryption error:', error.message);
}
