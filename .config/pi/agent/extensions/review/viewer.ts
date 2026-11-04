import { execFile, spawnSync } from 'node:child_process';
import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { promisify } from 'node:util';
import type { ExtensionCommandContext } from '@earendil-works/pi-coding-agent';

const run = promisify(execFile);
type Outcome = { code: number; stdout: string; stderr: string };

export const MODES = ['inline', 'split', 'float'];

function deliver(ctx: ExtensionCommandContext, { code, stdout, stderr }: Outcome) {
  if (code !== 0) {
    const reason = stderr
      .split('\n')
      .filter((line) => line.trim() && !line.startsWith('tuicr-'))
      .pop();
    return ctx.ui.notify(
      reason?.replace(/^Error:\s*/, '') ?? `Review exited with code ${code}`,
      'warning',
    );
  }
  const review = stdout.trim();
  if (!review) return ctx.ui.notify('Review closed with no comments.', 'info');
  const draft = ctx.ui.getEditorText().trim();
  ctx.ui.setEditorText(draft ? `${draft}\n\n${review}` : review);
  ctx.ui.notify('Review comments added to the editor.', 'info');
}

function runInline(ctx: ExtensionCommandContext, root: string, args: string[]) {
  return ctx.ui.custom<Outcome>((tui, _theme, _keys, done) => {
    tui.stop();
    const result = spawnSync('tuicr', args, {
      cwd: root,
      stdio: ['inherit', 'pipe', 'pipe'],
      encoding: 'utf8',
    });
    tui.start();
    tui.requestRender(true);
    done({
      code: result.status ?? 1,
      stdout: result.stdout ?? '',
      stderr: result.stderr || String(result.error ?? ''),
    });
    return { render: () => [], invalidate: () => {} };
  });
}

async function runInRex(mode: string, root: string, args: string[]): Promise<Outcome> {
  const session = process.env.REX_SESSION!;
  const dir = await mkdtemp(join(tmpdir(), 'pi-review-'));
  const [out, err] = [join(dir, 'out'), join(dir, 'err')];
  const command = [
    '/bin/sh',
    '-c',
    'o=$1 e=$2; shift 2; "$@" >"$o" 2>"$e"',
    'sh',
    out,
    err,
    'tuicr',
    ...args,
  ];
  const block = {
    flavor: 'com.superlogical.terminal.shell',
    label: 'review',
    options: { command, cwd: root },
  };
  try {
    const { stdout } = await run(
      'rex',
      mode === 'split'
        ? [
            'split',
            '--json',
            '-s',
            session,
            '-b',
            process.env.REX_BLOCK!,
            '-c',
            root,
            '--',
            ...command,
          ]
        : [
            'api',
            'call',
            '-s',
            session,
            'session.new_layer',
            JSON.stringify({ bounds: [0.1, 0.1, 0.8, 0.8], focus: true, layout: { block } }),
          ],
    );
    const id: string = JSON.parse(stdout).block_ids[0];
    const code = await run('rex', ['wait', '-s', session, id]).then(
      () => 0,
      (e) => e.code ?? 1,
    );
    if (code) await run('rex', ['block', 'close', '-s', session, id]).catch(() => {});
    const [stdoutText, stderrText] = await Promise.all(
      [out, err].map((path) => readFile(path, 'utf8').catch(() => '')),
    );
    return { code, stdout: stdoutText, stderr: stderrText };
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
}

export async function openReview(
  ctx: ExtensionCommandContext,
  mode: string,
  root: string,
  scopeArgs: string[],
) {
  const args = ['--stdout', ...scopeArgs];
  if (mode === 'inline') return deliver(ctx, await runInline(ctx, root, args));
  runInRex(mode, root, args).then(
    (outcome) => deliver(ctx, outcome),
    (e: Error) => ctx.ui.notify(e.message, 'error'),
  );
}
