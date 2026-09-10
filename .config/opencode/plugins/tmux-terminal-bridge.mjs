import { execFile } from 'node:child_process';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { basename, join } from 'node:path';

const [, , paneID, encodedCommand, timeoutValue] = process.argv;
const command = Buffer.from(encodedCommand, 'base64').toString();
const timeout = Number(timeoutValue);
const shellNames = new Set(['bash', 'zsh', basename(process.env.SHELL || '')]);
let submitted = false;

function runTmux(args) {
  return new Promise((resolve, reject) => {
    execFile(
      'tmux',
      args,
      { encoding: 'utf8', maxBuffer: 10 * 1024 * 1024, timeout: 1000 },
      (error, stdout) => {
        if (error) reject(error);
        else resolve(stdout);
      },
    );
  });
}

function delay(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

async function assertShellReady() {
  const metadata = await runTmux([
    'display-message',
    '-p',
    '-t',
    paneID,
    '#{pane_dead}\t#{pane_current_command}\t#{@opencode_visible_ready}',
  ]);
  const [dead, currentCommand, ready] = metadata.trim().split('\t');
  if (dead !== '0') throw new Error(`Visible terminal pane ${paneID} is dead.`);
  if (!shellNames.has(currentCommand)) {
    throw new Error(
      `Visible terminal pane ${paneID} is busy running ${currentCommand || 'an unknown process'}.`,
    );
  }
  if (ready !== '1') throw new Error(`Visible terminal pane ${paneID} is not initialized.`);
}

async function execute() {
  if (!paneID || !encodedCommand || !Number.isFinite(timeout)) {
    throw new Error('Invalid visible-terminal bridge arguments.');
  }

  await assertShellReady();
  const resultDirectory = await mkdtemp('/tmp/oc-');
  const commandPath = join(resultDirectory, 'command');
  const outputPath = join(resultDirectory, 'output');
  const statusPath = join(resultDirectory, 'status');
  await writeFile(commandPath, command);
  await writeFile(outputPath, '');

  let completed = false;
  try {
    await runTmux([
      'set-option',
      '-p',
      '-t',
      paneID,
      '@opencode_command_dir',
      resultDirectory,
      ';',
      'send-keys',
      '-t',
      paneID,
      'C-x',
      'C-o',
    ]);
    submitted = true;

    const deadline = Date.now() + timeout;
    while (Date.now() < deadline) {
      try {
        const status = Number(await readFile(statusPath, 'utf8'));
        await delay(20);
        completed = true;
        return { output: await readFile(outputPath), status };
      } catch {
        await delay(50);
      }
    }
  } finally {
    if (!submitted || completed) {
      await rm(resultDirectory, { force: true, recursive: true });
    }
  }

  throw new Error(
    `Visible terminal command timed out after ${timeout}ms and remains in pane ${paneID}.`,
  );
}

try {
  const result = await execute();
  if (result.output.length) process.stdout.write(result.output);
  process.exitCode = Number.isInteger(result.status) ? result.status : 1;
} catch (error) {
  if (!submitted && paneID) {
    try {
      await runTmux(['set-option', '-p', '-u', '-t', paneID, '@opencode_command_owner']);
    } catch {}
  }
  process.stderr.write(`${error.message}\n`);
  process.exitCode = 1;
}
