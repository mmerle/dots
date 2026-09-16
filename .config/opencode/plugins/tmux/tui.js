import { spawn } from 'node:child_process';

import { Plugin } from '@opencode/plugin/tui';

const PANE_ID = process.env.TMUX_PANE;
const directions = [
  ['left', 'ctrl+h', '-L'],
  ['down', 'ctrl+j', '-D'],
  ['up', 'ctrl+k', '-U'],
  ['right', 'ctrl+l', '-R'],
];

export default Plugin.define({
  id: 'tmux.tui',
  setup(context) {
    if (!PANE_ID) return;

    return context.ui.slot({
      append: 'app',
      render() {
        context.keymap.layer(() => ({
          mode: 'base',
          priority: 10,
          commands: directions.map(([direction, bind, flag]) => ({
            id: `tmux.navigate.${direction}`,
            title: `Navigate tmux ${direction}`,
            bind,
            run() {
              spawn('tmux', ['select-pane', '-t', PANE_ID, flag], { stdio: 'ignore' });
            },
          })),
        }));
        return null;
      },
    });
  },
});
