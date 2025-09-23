import { encrypt, decrypt } from './src/utils/encryption.js';

console.log('Testing encryption...');
const original = 'test-sensitive-data';
const encrypted = encrypt(original);
const decrypted = decrypt(encrypted);

console.log('Original:', original);
console.log('Encrypted:', encrypted);
console.log('Decrypted:', decrypted);
console.log('Match:', original === decrypted);
