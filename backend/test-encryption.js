import { encrypt } from '../utils/encryption';

console.log('Testing encryption import...');
const test = encrypt('test');
console.log('Encryption successful:', test);
