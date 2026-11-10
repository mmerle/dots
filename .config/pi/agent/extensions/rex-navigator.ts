import { CustomEditor, type ExtensionAPI } from '@earendil-works/pi-coding-agent';
import { matchesKey } from '@earendil-works/pi-tui';

export default function rexNavigator(pi: ExtensionAPI) {
  let controller: AbortController | undefined;

  pi.on('session_shutdown', () => controller?.abort());
  // NOTE: Wrap the prompt editor after all session_start handlers have installed it.
  pi.on('resources_discover', (_event, ctx) => {
    const session = process.env.REX_SESSION;
    const block = process.env.REX_BLOCK;
    if (ctx.mode !== 'tui' || !session || !block || process.env.TMUX) return;
    controller = new AbortController();
    const { signal } = controller;
    const binary = process.env.REX_BIN_DIR ? `${process.env.REX_BIN_DIR}/rex` : 'rex';
    const args = [
      '--autostart=false', '--timeout', '1s',
      'do', '-s', session, '-b', block, 'navigator_focus',
    ];
    let pending = false;

    async function navigate(direction: 'up' | 'down') {
      if (pending || signal.aborted) return;
      pending = true;
      try {
        const result = await pi.exec(binary, [...args, `direction=${direction}`], { timeout: 1250, signal });
        if (!signal.aborted && (result.code !== 0 || result.killed)) {
          const detail = result.stderr.trim() || (result.killed ? 'Rex navigation timed out' : `Rex exited with status ${result.code}`);
          ctx.ui.notify(`navigator: ${detail}`, 'warning');
        }
      } catch (error) {
        if (!signal.aborted) ctx.ui.notify(`navigator: ${String(error)}`, 'warning');
      } finally {
        pending = false;
      }
    }

    const factory = ctx.ui.getEditorComponent();
    ctx.ui.setEditorComponent((tui, theme, keybindings) => {
      // NOTE: Compose with the installed prompt editor instead of replacing it.
      const editor = factory?.(tui, theme, keybindings) ?? new CustomEditor(tui, theme, keybindings);
      if (!('isShowingAutocomplete' in editor) || typeof editor.isShowingAutocomplete !== 'function') return editor;
      const autocomplete = editor.isShowingAutocomplete.bind(editor);
      const input = editor.handleInput.bind(editor);
      editor.handleInput = (data) => {
        const direction = matchesKey(data, 'ctrl+j') ? 'down' : matchesKey(data, 'ctrl+k') ? 'up' : undefined;
        // NOTE: Dialogs own their focus; autocomplete shares this editor's input.
        if (!direction || autocomplete()) input(data);
        else void navigate(direction);
      };
      return editor;
    });
  });
}
