import { execFile, execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

import { Plugin } from '@opencode/plugin';

const PANE_ID = process.env.TMUX_PANE;
const SHELL = '/bin/zsh';
const BRIDGE_PATH = fileURLToPath(new URL('./tmux-terminal-bridge.mjs', import.meta.url));
const childSessions = new Set();
const visibleTerminals = new Map();
const childEventStates = {
  'permission.asked': 'blocked',
  'question.asked': 'blocked',
  'permission.replied': 'working',
  'question.replied': 'working',
  'question.rejected': 'working',
};
const rootEventStates = {
  ...childEventStates,
  'session.compacted': 'working',
  'session.error': 'blocked',
};

let rootSessionID;
let updateChain = Promise.resolve();

function runTmux(args) {
  return new Promise((resolve, reject) => {
    execFile('tmux', args, { encoding: 'utf8', timeout: 1000 }, (error, stdout) => {
      if (error) reject(error);
      else resolve(stdout.trim());
    });
  });
}

function reportTmux(args) {
  return new Promise((resolve) => {
    execFile('tmux', args, { timeout: 500 }, resolve);
  });
}

function delay(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

function paneOptionArgs(paneID, options) {
  return options.flatMap(([name, value], index) => [
    ...(index ? [';'] : []),
    'set-option',
    '-p',
    ...(value === undefined ? ['-u'] : []),
    '-t',
    paneID,
    name,
    ...(value === undefined ? [] : [value]),
  ]);
}

function showPaneOption(paneID, name) {
  return runTmux(['show-options', '-p', '-qv', '-t', paneID, name]);
}

function updatePane(state, sessionID) {
  if (!PANE_ID) return Promise.resolve();

  const options = [];
  if (sessionID) {
    rootSessionID = sessionID;
    options.push(['@opencode_session_id', sessionID]);
  }
  if (state) options.push(['@opencode_state', state]);

  const pending = updateChain.then(() => reportTmux(paneOptionArgs(PANE_ID, options)));
  updateChain = pending;
  return pending;
}

async function paneExists(paneID) {
  try {
    return (await runTmux(['display-message', '-p', '-t', paneID, '#{pane_dead}'])) === '0';
  } catch {
    return false;
  }
}

async function initializeVisibleTerminal(paneID) {
  const setup = [
    'function __opencode_run() {',
    '  local result_dir="$1"',
    '  local command_file="$result_dir/command"',
    '  local output_file="$result_dir/output"',
    '  local status_file="$result_dir/status"',
    '  set --',
    "  printf '\\r\\033[2K$ '",
    '  command cat -- "$command_file"',
    "  printf '\\n'",
    '  tmux pipe-pane -t "$TMUX_PANE" "cat > \'$output_file\'"',
    '  source "$command_file"',
    '  local command_status=$?',
    '  tmux pipe-pane -t "$TMUX_PANE"',
    '  tmux set-option -pu -t "$TMUX_PANE" @opencode_command_owner',
    '  printf \'%s\' "$command_status" > "$status_file"',
    '}',
    'function __opencode_widget() {',
    '  local result_dir',
    '  result_dir=$(tmux show-options -pqv -t "$TMUX_PANE" @opencode_command_dir)',
    '  [[ -n "$result_dir" ]] || return',
    '  zle -I',
    '  __opencode_run "$result_dir"',
    '}',
    'zle -N __opencode_widget',
    "bindkey '^X^O' __opencode_widget",
    'tmux set-option -p -t "$TMUX_PANE" @opencode_visible_ready 1',
    'clear',
  ].join('\n');
  const bufferName = `opencode-setup-${process.pid}`;

  await runTmux([
    'set-buffer',
    '-b',
    bufferName,
    setup,
    ';',
    'paste-buffer',
    '-p',
    '-d',
    '-b',
    bufferName,
    '-t',
    paneID,
    ';',
    'send-keys',
    '-t',
    paneID,
    'Enter',
  ]);

  for (let attempt = 0; attempt < 20; attempt += 1) {
    const ready = await showPaneOption(paneID, '@opencode_visible_ready');
    if (ready === '1') {
      await delay(50);
      await runTmux(['clear-history', '-t', paneID]);
      return;
    }
    await delay(50);
  }
  throw new Error(`Visible terminal pane ${paneID} did not become ready.`);
}

async function startVisibleTerminal({ sessionID, directory }) {
  const existingPaneID = visibleTerminals.get(sessionID);
  if (existingPaneID && (await paneExists(existingPaneID))) {
    return `Visible terminal already active in pane ${existingPaneID}.`;
  }

  visibleTerminals.delete(sessionID);
  const splitArgs = [
    '-d',
    '-P',
    '-F',
    '#{pane_id}',
    '-t',
    PANE_ID,
    '-c',
    directory,
    SHELL,
    '-l',
  ];

  let paneID;
  try {
    paneID = await runTmux(['split-window', '-h', ...splitArgs]);
  } catch {
    paneID = await runTmux(['split-window', '-v', ...splitArgs]);
  }

  await runTmux(paneOptionArgs(paneID, [['@opencode_visible_session', sessionID]]));
  await initializeVisibleTerminal(paneID);
  visibleTerminals.set(sessionID, paneID);
  return `Visible terminal active in pane ${paneID}. All Bash commands for this session will run there.`;
}

async function releaseVisibleTerminal(sessionID) {
  const paneID = visibleTerminals.get(sessionID);
  visibleTerminals.delete(sessionID);
  if (!paneID) return 'No visible terminal is active for this session.';

  await reportTmux(
    paneOptionArgs(paneID, [
      ['@opencode_visible_session'],
      ['@opencode_visible_ready'],
      ['@opencode_command_dir'],
      ['@opencode_command_owner'],
    ]),
  );
  return `Visible terminal routing released from pane ${paneID}. The pane remains open.`;
}

async function visibleTerminalStatus(sessionID) {
  const paneID = visibleTerminals.get(sessionID);
  if (!paneID || !(await paneExists(paneID))) {
    visibleTerminals.delete(sessionID);
    return 'No visible terminal is active for this session.';
  }
  return `Visible terminal active in pane ${paneID}.`;
}

function shellQuote(value) {
  return `'${String(value).replaceAll("'", "'\\''")}'`;
}

function bridgeCommand(paneID, command, timeout) {
  const encodedCommand = Buffer.from(command).toString('base64');
  return [
    'OPENCODE_VISIBLE_BRIDGE=1',
    'node',
    shellQuote(BRIDGE_PATH),
    shellQuote(paneID),
    shellQuote(encodedCommand),
    String(timeout),
  ].join(' ');
}

function clearTmuxOptions() {
  if (!PANE_ID) return;

  try {
    execFileSync('tmux', paneOptionArgs(PANE_ID, [['@opencode_state'], ['@opencode_session_id']]), {
      stdio: 'ignore',
      timeout: 500,
    });
  } catch {}

  for (const paneID of visibleTerminals.values()) {
    try {
      execFileSync(
        'tmux',
        paneOptionArgs(paneID, [
          ['@opencode_visible_session'],
          ['@opencode_visible_ready'],
          ['@opencode_command_dir'],
          ['@opencode_command_owner'],
        ]),
        { stdio: 'ignore', timeout: 500 },
      );
    } catch {}
  }
}

function eventPayload(event) {
  return event?.data ?? event?.properties ?? event ?? {};
}

function eventSessionID(event) {
  const payload = eventPayload(event);
  return payload.sessionID ?? payload.session?.id ?? event?.sessionID;
}

function toolSessionID(value) {
  return value?.sessionID ?? value?.session?.id;
}

function isShellTool(name) {
  return name === 'shell' || name === 'bash';
}

if (PANE_ID) process.once('exit', clearTmuxOptions);

export default Plugin.define({
  id: 'tmux',
  async setup(ctx) {
    if (!PANE_ID || !process.env.TMUX) return;

    await ctx.tool.transform((editor) => {
      editor.add({
        name: 'visible_terminal',
        description:
          'Activate, inspect, or release a persistent tmux shell beside the current OpenCode pane. Call action=start immediately, before any Bash command, when the user asks to run CLI commands in a split, visible terminal, or pane next to them. While active, normal Bash calls are automatically routed there.',
        input: {
          type: 'object',
          properties: {
            action: {
              type: 'string',
              enum: ['start', 'status', 'release'],
              description:
                'Start routing, inspect its status, or release it while leaving the pane open.',
            },
          },
          required: ['action'],
          additionalProperties: false,
        },
        execute: async ({ action }, tool) => {
          const sessionID = toolSessionID(tool);
          const directory = tool?.directory ?? ctx.location.directory;
          if (action === 'start') return { content: await startVisibleTerminal({ sessionID, directory }) };
          if (action === 'release') return { content: await releaseVisibleTerminal(sessionID) };
          return { content: await visibleTerminalStatus(sessionID) };
        },
      });
    });

    await ctx.tool.hook('execute.before', async (event) => {
      if (!isShellTool(event.tool)) return;
      const input = event.input ?? {};
      if (typeof input.command !== 'string') return;
      if (input.command.startsWith('OPENCODE_VISIBLE_BRIDGE=1 ')) return;

      const sessionID = eventSessionID(event) ?? toolSessionID(event);
      const paneID = visibleTerminals.get(sessionID);
      if (!paneID) return;
      if (!(await paneExists(paneID))) {
        visibleTerminals.delete(sessionID);
        throw new Error(`Visible terminal pane ${paneID} is no longer available.`);
      }
      const commandOwner = await showPaneOption(paneID, '@opencode_command_owner');
      if (commandOwner) {
        throw new Error(`Visible terminal pane ${paneID} is still running another Bash command.`);
      }
      await runTmux(
        paneOptionArgs(paneID, [['@opencode_command_owner', event.callID ?? event.id ?? 'visible-terminal']]),
      );

      const timeout = Number.isFinite(input.timeout) ? Math.max(1000, input.timeout - 500) : 119_000;
      const workdir = input.workdir ?? input.cwd;
      const command = workdir ? `cd -- ${shellQuote(workdir)}\n${input.command}` : input.command;
      event.input = { ...input, command: bridgeCommand(paneID, command, timeout) };
    });

    await ctx.session.hook('prompt', async (event) => {
      const sessionID = event.sessionID;
      if (sessionID && !childSessions.has(sessionID)) {
        await updatePane('working', sessionID);
      }
    });

    const controller = new AbortController();
    void (async () => {
      for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
        const type = event.type;
        const payload = eventPayload(event);
        const sessionID = eventSessionID(event);
        const info = payload.info;

        if (info?.id && info.parentID) childSessions.add(info.id);

        if (sessionID && childSessions.has(sessionID)) {
          const state = childEventStates[type];
          if (state) await updatePane(state);
          continue;
        }

        if (type === 'session.created') {
          await updatePane(undefined, sessionID);
          continue;
        }
        if (type === 'session.updated') {
          if (sessionID && sessionID !== rootSessionID) {
            await updatePane(undefined, sessionID);
          }
          continue;
        }
        if (type === 'session.status') {
          const status = payload.status?.type;
          if (status === 'idle') await updatePane('idle', sessionID);
          if (status === 'busy' || status === 'retry') {
            await updatePane('working', sessionID);
          }
          continue;
        }
        if (type === 'session.idle') {
          await updatePane('idle', sessionID);
          continue;
        }
        if (type === 'session.deleted') {
          await releaseVisibleTerminal(sessionID);
          continue;
        }
        const state = rootEventStates[type];
        if (state) await updatePane(state, sessionID);
      }
    })();

    return () => {
      controller.abort();
      clearTmuxOptions();
    };
  },
});
