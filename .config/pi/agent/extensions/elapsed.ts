import type { ExtensionAPI, ExtensionContext } from '@earendil-works/pi-coding-agent';
import { Text } from '@earendil-works/pi-tui';

const ENTRY_TYPE = 'worked-for';

function formatDuration(totalSeconds: number): string {
  return totalSeconds < 60
    ? `${totalSeconds}s`
    : `${Math.floor(totalSeconds / 60)}m ${String(totalSeconds % 60).padStart(2, '0')}s`;
}

const messages = [
  { active: 'Consulting the unseen', complete: 'Consulted the unseen' },
  { active: 'Undertaking strange work', complete: 'Undertook strange work' },
  { active: 'Stirring the apparatus', complete: 'Stirred the apparatus' },
  { active: 'Shifting matter', complete: 'Shifted matter' },
  { active: 'Conducting further study', complete: 'Conducted further study' },
  { active: 'Working quietly', complete: 'Worked quietly' },
  { active: 'Tending the mechanism', complete: 'Tended the mechanism' },
  { active: 'Interpreting uncertain signals', complete: 'Interpreted uncertain signals' },
  { active: 'Gathering fragments', complete: 'Gathered fragments' },
  { active: 'Performing esoteric calculations', complete: 'Performed esoteric calculations' },
];

export default function elapsed(pi: ExtensionAPI) {
  let timer: ReturnType<typeof setInterval> | undefined;
  let run: { message: (typeof messages)[number]; startedAt: number } | undefined;
  let previous: (typeof messages)[number] | undefined;

  pi.registerEntryRenderer<{ seconds: number; message: string }>(ENTRY_TYPE, (entry, _options, theme) => {
    const { message = 'Worked', seconds = 0 } = entry.data ?? {};
    return new Text(theme.fg('dim', `${message} for ${formatDuration(seconds)}`), 1, 0);
  });

  function elapsedSeconds(startedAt: number) {
    return Math.floor((performance.now() - startedAt) / 1000);
  }

  function stop(ctx: ExtensionContext) {
    clearInterval(timer);
    timer = undefined;
    if (ctx.mode === 'tui') ctx.ui.setWorkingMessage();
  }

  pi.on('agent_start', (_event, ctx) => {
    if (ctx.mode !== 'tui') return;
    stop(ctx);
    const choices = messages.filter((message) => message !== previous);
    const current = { message: choices[Math.floor(Math.random() * choices.length)], startedAt: performance.now() };
    run = current;
    previous = current.message;

    const update = () =>
      ctx.ui.setWorkingMessage(`${current.message.active} for ${formatDuration(elapsedSeconds(current.startedAt))}`);
    update();
    timer = setInterval(update, 1000);
  });

  pi.on('agent_end', (_event, ctx) => {
    stop(ctx);
    if (!run) return;
    pi.appendEntry(ENTRY_TYPE, { seconds: elapsedSeconds(run.startedAt), message: run.message.complete });
    run = undefined;
  });

  pi.on('session_shutdown', (_event, ctx) => stop(ctx));
}
