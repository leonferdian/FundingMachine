const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

function runTests() {
  const testDir = __dirname;
  const args = process.argv.slice(2);

  // Check if we should run Jest tests (TypeScript files)
  const hasJestArgs = args.some(arg =>
    arg.includes('integration') ||
    arg.includes('jest') ||
    arg.includes('coverage')
  );

  if (hasJestArgs) {
    console.log('Running Jest tests (TypeScript)...');
    console.log('Arguments:', args.join(' '));

    const jest = spawn('npx', ['jest', ...args], {
      stdio: 'inherit',
      cwd: path.join(__dirname, '..')
    });

    jest.on('close', (code) => {
      console.log(`\nJest test run completed with exit code: ${code}`);
      process.exit(code);
    });

    jest.on('error', (error) => {
      console.error('Error running Jest tests:', error);
      process.exit(1);
    });

    return;
  }

  // Original Node.js test runner logic
  const testFiles = fs.readdirSync(testDir)
    .filter(file => file.endsWith('.test.js') && !file.includes('jest') && !file.includes('ts'))
    .filter(file => {
      // Only include files that use Node.js test runner syntax
      const content = fs.readFileSync(path.join(testDir, file), 'utf8');
      return content.includes('require(\'node:test\')') || content.includes('const { describe, it }');
    })
    .map(file => path.join(testDir, file));

  console.log('Running Node.js test runner tests...');
  console.log(`Found ${testFiles.length} Node.js test runner compatible test files:`, testFiles.map(f => path.basename(f)));

  if (testFiles.length === 0) {
    console.log('No compatible test files found!');
    return;
  }

  // Run all tests
  const nodeTest = spawn('node', ['--test', ...testFiles], {
    stdio: 'inherit',
    cwd: testDir
  });

  nodeTest.on('close', (code) => {
    console.log(`\nTest run completed with exit code: ${code}`);
    process.exit(code);
  });

  nodeTest.on('error', (error) => {
    console.error('Error running tests:', error);
    process.exit(1);
  });
}

if (require.main === module) {
  runTests();
}

module.exports = { runTests };
