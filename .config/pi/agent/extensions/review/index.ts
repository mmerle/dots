import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';
import { findRepoRoot, saveRun, SCOPES, scopeArgs, snapshot, type Snapshot } from './git';
import { MODES, openReview } from './viewer';

function completeArgs(prefix: string) {
  const [scope, mode] = prefix.trimStart().split(/\s+/, 2);
  const values =
    mode === undefined
      ? SCOPES.filter((name) => name.startsWith(scope))
      : SCOPES.includes(scope)
        ? MODES.filter((name) => name.startsWith(mode)).map((name) => `${scope} ${name}`)
        : [];
  return values.length ? values.map((value) => ({ value, label: value })) : null;
}

export default function review(pi: ExtensionAPI) {
  let pending: { root: string; sessionId: string; before: Snapshot } | undefined;

  pi.on('before_agent_start', async (_event, ctx) => {
    const root = !pending && (await findRepoRoot(ctx.cwd));
    if (!root) return;
    const before = await snapshot(root).catch(() => undefined);
    if (before) pending = { root, sessionId: ctx.sessionManager.getSessionId(), before };
  });

  pi.on('agent_settled', async () => {
    const run = pending;
    pending = undefined;
    if (!run) return;
    const after = await snapshot(run.root, run.before.commit).catch(() => undefined);
    if (after && after.tree !== run.before.tree) await saveRun(run.root, run.sessionId, after);
  });

  pi.registerCommand('review', {
    description: 'Review in tuicr: last | uncommitted | branch [split | float]',
    getArgumentCompletions: completeArgs,
    handler: async (args, ctx) => {
      const warn = (message: string) => ctx.ui.notify(message, 'warning');
      const [scope = '', mode = 'inline', extra] = args.trim().split(/\s+/);
      if (!SCOPES.includes(scope) || !MODES.includes(mode) || extra)
        return warn('Usage: /review last|uncommitted|branch [split|float]');
      if (!ctx.isIdle()) return warn('Wait for the agent to finish.');
      const root = await findRepoRoot(ctx.cwd);
      if (!root) return warn('Not inside a Git repository.');
      try {
        await openReview(
          ctx,
          mode,
          root,
          await scopeArgs(scope, root, ctx.sessionManager.getSessionId()),
        );
      } catch (error) {
        warn((error as Error).message);
      }
    },
  });
}
