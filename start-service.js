const { spawn } = require('child_process');
const path = require('path');

const authServicePath = '/workspaces/HRMS/services/auth-service';
const proc = spawn('npm', ['run', 'dev'], {
  cwd: authServicePath,
  stdio: 'inherit',
  shell: true
});

proc.on('error', (err) => {
  console.error('Failed to start:', err);
  process.exit(1);
});

proc.on('exit', (code) => {
  console.log(`Process exited with code ${code}`);
});
