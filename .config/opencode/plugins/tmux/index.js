import { execFile } from 'node:child_process';

const HOST_PANE = process.env.TMUX_PANE;
const PANE_FORMAT = [
  '#{pane_id}',
  '#{session_name}',
  '#{window_index}',
  '#{pane_index}',
  '#{pane_active}',
  '#{pane_current_command}',
  '#{pane_current_path}',
].join('\t');

function runTmux(args) {
  return new Promise((resolve, reject) => {
    execFile('tmux', args, { encoding: 'utf8', timeout: 5000 }, (error, stdout, stderr) => {
      if (error) {
        reject(new Error(stderr.trim() || error.message));
        return;
      }
      resolve(stdout.trim());
    });
  });
}

function paneTarget(pane) {
  return pane || HOST_PANE;
}

function text(content) {
  return { content };
}

function addTool(editor, definition) {
  editor.add({
    ...definition,
    options: { namespace: 'tmux', codemode: true },
  });
}

export default {
  id: 'tmux',
  async setup(context) {
    if (!HOST_PANE) return;

    await context.tool.transform((editor) => {
      editor.namespace({
        name: 'tmux',
        description: 'Open, inspect, and control tmux panes around the current OpenCode pane.',
      });

      addTool(editor, {
        name: 'list',
        description: 'List panes in the current tmux session.',
        input: {
          type: 'object',
          properties: {},
          additionalProperties: false,
        },
        execute: async () => {
          const output = await runTmux(['list-panes', '-s', '-t', HOST_PANE, '-F', PANE_FORMAT]);
          return text(output || 'No panes found.');
        },
      });

      addTool(editor, {
        name: 'split',
        description: 'Open a tmux pane beside or below a target pane.',
        input: {
          type: 'object',
          properties: {
            direction: {
              type: 'string',
              enum: ['right', 'down'],
              description: 'Place the new pane to the right or below the target.',
            },
            pane: {
              type: 'string',
              description: 'Target pane ID. Defaults to the current OpenCode pane.',
            },
            directory: {
              type: 'string',
              description: 'Working directory. Defaults to the target pane directory.',
            },
            command: {
              type: 'string',
              description: 'Optional command to run in the new pane.',
            },
          },
          required: ['direction'],
          additionalProperties: false,
        },
        execute: async ({ direction, pane, directory, command }) => {
          const target = paneTarget(pane);
          const args = [
            'split-window',
            direction === 'right' ? '-h' : '-v',
            '-d',
            '-P',
            '-F',
            '#{pane_id}',
            '-t',
            target,
            '-c',
            directory || '#{pane_current_path}',
          ];
          if (command) args.push(command);

          return text(await runTmux(args));
        },
      });

      addTool(editor, {
        name: 'capture',
        description: 'Read recent visible and historical output from a tmux pane.',
        input: {
          type: 'object',
          properties: {
            pane: {
              type: 'string',
              description: 'Pane ID. Defaults to the current OpenCode pane.',
            },
            lines: {
              type: 'integer',
              minimum: 1,
              maximum: 2000,
              description: 'Number of recent lines to read. Defaults to 200.',
            },
          },
          additionalProperties: false,
        },
        execute: async ({ pane, lines = 200 }) =>
          text(
            await runTmux([
              'capture-pane',
              '-p',
              '-J',
              '-t',
              paneTarget(pane),
              '-S',
              `-${lines}`,
            ]),
          ),
      });

      addTool(editor, {
        name: 'send',
        description: 'Send literal text or tmux key names to a pane.',
        input: {
          type: 'object',
          properties: {
            pane: {
              type: 'string',
              description: 'Pane ID. Defaults to the current OpenCode pane.',
            },
            text: {
              type: 'string',
              description: 'Literal text to send.',
            },
            keys: {
              type: 'array',
              items: { type: 'string' },
              minItems: 1,
              description: 'Tmux key names such as C-c, Enter, or Up.',
            },
            enter: {
              type: 'boolean',
              description: 'Press Enter after literal text. Defaults to true.',
            },
          },
          additionalProperties: false,
        },
        execute: async ({ pane, text: input, keys, enter = true }) => {
          if ((input === undefined) === (keys === undefined)) {
            throw new Error('Provide either text or keys.');
          }

          const target = paneTarget(pane);
          if (input !== undefined) {
            await runTmux(['send-keys', '-t', target, '-l', input]);
            if (enter) await runTmux(['send-keys', '-t', target, 'Enter']);
          } else {
            await runTmux(['send-keys', '-t', target, ...keys]);
          }

          return text(`Sent input to ${target}.`);
        },
      });
    });
  },
};
