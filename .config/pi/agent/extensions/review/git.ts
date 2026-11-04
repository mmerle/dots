import { execFile } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import { copyFile, rm, stat } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { promisify } from 'node:util';

const run = promisify(execFile);
const IDENTITY = {
  GIT_AUTHOR_NAME: 'pi',
  GIT_AUTHOR_EMAIL: 'pi@local',
  GIT_COMMITTER_NAME: 'pi',
  GIT_COMMITTER_EMAIL: 'pi@local',
};

export const SCOPES = ['last', 'uncommitted', 'branch'];
export type Snapshot = { commit: string; tree: string };

const git = async (cwd: string, args: string[], env = process.env) =>
  (await run('git', args, { cwd, env, maxBuffer: 64 << 20 })).stdout.trim();

const sessionRef = (id: string) => `refs/pi-review/${id.replace(/[^\w.-]/g, '_')}`;

export const findRepoRoot = (cwd: string) =>
  git(cwd, ['rev-parse', '--show-toplevel']).catch(() => undefined);

export async function snapshot(root: string, parent?: string): Promise<Snapshot> {
  const index = join(tmpdir(), `pi-review-${randomUUID()}`);
  const env = { ...process.env, ...IDENTITY, GIT_INDEX_FILE: index };
  try {
    await copyFile(
      await git(root, ['rev-parse', '--path-format=absolute', '--git-path', 'index']),
      index,
    ).catch(() => {});
    const untracked = (await git(root, ['ls-files', '-z', '-o', '--exclude-standard'], env))
      .split('\0')
      .filter(Boolean);
    const sizes = await Promise.all(
      untracked.map((path) =>
        stat(join(root, path)).then(
          (s) => s.size,
          () => 0,
        ),
      ),
    );
    const large = untracked
      .filter((_, i) => sizes[i] > 5 << 20)
      .map((path) => `:(exclude,literal)${path}`);
    await git(root, ['add', '-A', '--', '.', ...large], env);
    const tree = await git(root, ['write-tree'], env);
    const commit = await git(
      root,
      ['commit-tree', tree, ...(parent ? ['-p', parent] : []), '-m', 'pi review'],
      env,
    );
    return { commit, tree };
  } finally {
    await rm(index, { force: true });
  }
}

export const saveRun = (root: string, sessionId: string, after: Snapshot) =>
  git(root, ['update-ref', sessionRef(sessionId), after.commit]);

export async function scopeArgs(scope: string, root: string, sessionId: string): Promise<string[]> {
  if (scope === 'uncommitted') return ['-w'];
  if (scope === 'last') {
    const ref = sessionRef(sessionId);
    const [after, before] = (await git(root, ['rev-parse', ref, `${ref}^`]).catch(() => '')).split(
      '\n',
    );
    if (!before) throw new Error('No agent file changes recorded in this session yet.');
    return ['-r', `${before}..${after}`];
  }
  const remoteHead = await git(root, [
    'symbolic-ref',
    '-q',
    '--short',
    'refs/remotes/origin/HEAD',
  ]).catch(() => '');
  for (const ref of [remoteHead, 'origin/main', 'origin/master', 'main', 'master'].filter(
    Boolean,
  )) {
    const base = await git(root, ['merge-base', 'HEAD', ref]).catch(() => '');
    if (base)
      return base === (await git(root, ['rev-parse', 'HEAD']))
        ? ['-w']
        : ['-r', `${base}..HEAD`, '-w'];
  }
  throw new Error('No default branch (origin/HEAD, main, or master) to compare against.');
}
