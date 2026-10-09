import type { ExtensionAPI, ExtensionContext } from '@earendil-works/pi-coding-agent';

const messages = [
  'Consulting the unseen...',
  'Strange work underway...',
  'The apparatus stirs...',
  'Shifting matter...',
  'Further study...',
  'Quiet workings...',
  'Tending the mechanism...',
  'Uncertain signals...',
  'Gathering fragments...',
  'Esoteric calculations...',
];

export default function elapsed(pi: ExtensionAPI) {
  let timer: ReturnType<typeof setInterval> | undefined;
  let previous = '';

  function stop(ctx: ExtensionContext) {
    clearInterval(timer);
    timer = undefined;
    if (ctx.mode === 'tui') ctx.ui.setWorkingMessage();
  }

  pi.on('agent_start', (_event, ctx) => {
    if (ctx.mode !== 'tui') return;
    stop(ctx);
    const started = performance.now();
    const choices = messages.filter((message) => message !== previous);
    const message = choices[Math.floor(Math.random() * choices.length)];
    previous = message;

    const update = () => {
      const seconds = Math.floor((performance.now() - started) / 1000);
      const duration =
        seconds < 60
          ? `${seconds}s`
          : `${Math.floor(seconds / 60)}m ${String(seconds % 60).padStart(2, '0')}s`;
      ctx.ui.setWorkingMessage(`${message} ${duration}`);
    };

    update();
    timer = setInterval(update, 1000);
  });

  pi.on('agent_end', (_event, ctx) => stop(ctx));
  pi.on('session_shutdown', (_event, ctx) => stop(ctx));
}
