const { encrypt, decrypt } = require('./src/utils/encryption');

console.log('Testing encryption module...');
try {
  const original = 'test-sensitive-data-12345';
  console.log('Original:', original);

  const encrypted = encrypt(original);
  console.log('Encrypted:', encrypted);

  const decrypted = decrypt(encrypted);
  console.log('Decrypted:', decrypted);

  console.log('Match:', original === decrypted ? 'YES' : 'NO');
} catch (error) {
  console.error('Error:', error.message);
}
