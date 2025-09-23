const crypto = require('crypto');

// Test if the encryption logic works
const ENCRYPTION_KEY_INPUT = process.env.ENCRYPTION_KEY || 'development-encryption-key-32-byte-secure-key-for-aes-256-cbc-encryption';
const ENCRYPTION_KEY = crypto.createHash('sha256').update(ENCRYPTION_KEY_INPUT).digest().subarray(0, 32);
const ALGORITHM = 'aes-256-cbc';
const IV_LENGTH = 16;

console.log('Testing encryption logic...');

try {
  const iv = crypto.randomBytes(IV_LENGTH);
  const key = Buffer.from(ENCRYPTION_KEY);
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
  let encrypted = cipher.update('test-data', 'utf8', 'hex');
  encrypted += cipher.final('hex');

  console.log('✓ Encryption works');
  console.log('Key length:', ENCRYPTION_KEY.length);
  console.log('IV length:', iv.length);

  // Test decryption
  const textParts = (iv.toString('hex') + ':' + encrypted).split(':');
  const iv2 = Buffer.from(textParts.shift(), 'hex');
  const encryptedText = textParts.join(':');
  const key2 = Buffer.from(ENCRYPTION_KEY);

  const decipher = crypto.createDecipheriv(ALGORITHM, key2, iv2);
  let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
  decrypted += decipher.final('utf8');

  console.log('✓ Decryption works');
  console.log('Original: test-data');
  console.log('Decrypted:', decrypted);
  console.log('Match:', 'test-data' === decrypted);

} catch (error) {
  console.error('Error:', error.message);
  console.error('Stack:', error.stack);
}
