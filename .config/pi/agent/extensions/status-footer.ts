import { homedir } from 'node:os';
import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';
import { truncateToWidth, visibleWidth } from '@earendil-works/pi-tui';

function fitRow(left: string, right: string, width: number): string {
  if (width <= 0) return '';
  if (!right) return truncateToWidth(left, width);
  const rightWidth = visibleWidth(right);
  if (rightWidth >= width) return truncateToWidth(right, width);
  const fittedLeft = truncateToWidth(left, width - rightWidth - 1);
  return fittedLeft + ' '.repeat(width - visibleWidth(fittedLeft) - rightWidth) + right;
}

export default function statusFooter(pi: ExtensionAPI) {
  let modelName = 'no model';
  let effort = '';
  let requestRender: (() => void) | undefined;

  pi.on('model_select', (event) => {
    modelName = event.model.id;
    requestRender?.();
  });

  pi.on('thinking_level_select', (event) => {
    effort = event.level === 'off' ? '' : ` ${event.level}`;
    requestRender?.();
  });

  pi.on('session_start', (_event, ctx) => {
    if (ctx.mode !== 'tui') return;
    modelName = ctx.model?.id ?? 'no model';
    effort = ctx.thinkingLevel && ctx.thinkingLevel !== 'off' ? ` ${ctx.thinkingLevel}` : '';
    ctx.ui.setFooter((tui, theme, footerData) => {
      requestRender = () => tui.requestRender();
      const unsubscribe = footerData.onBranchChange(requestRender);

      return {
        dispose() {
          unsubscribe();
          requestRender = undefined;
        },
        invalidate() {},
        render(width: number): string[] {
          const dim = (text: string) => theme.fg('dim', text);
          const cwd =
            ctx.cwd === homedir()
              ? '~'
              : ctx.cwd.startsWith(`${homedir()}/`)
                ? `~${ctx.cwd.slice(homedir().length)}`
                : ctx.cwd;
          const session = ctx.sessionManager.getSessionName() ?? 'Untitled';
          const separator = dim(' · ');
          const details = [
            theme.fg('accent', modelName + effort),
            theme.fg('success', cwd),
            theme.fg('warning', session),
          ]
            .filter(Boolean)
            .join(separator);
          // NOTE: Native MCP exposes tool namespaces, not the adapter's footer status string.
          const mcpServers = new Set(
            pi
              .getAllTools()
              .filter(
                (tool) => tool.exposure !== 'hidden' && tool.namespace?.name.startsWith('mcp__')
              )
              .map((tool) => tool.namespace!.name)
          );
          const mcp = mcpServers.size ? theme.fg('success', `${mcpServers.size} MCP`) : '';
          const usage = ctx.getContextUsage();
          const context =
            usage?.percent == null || usage.tokens == null
              ? ''
              : dim(`Context ${Math.round(usage.percent)}% (${(usage.tokens / 1000).toFixed(1)}K)`);
          const right = [context, mcp].filter(Boolean).join(dim(' · '));

          return [
            fitRow(dim('  ') + details, '', width),
            fitRow(dim('  ctrl+s resume'), right ? `${right}${dim('  ')}` : '', width),
          ];
        },
      };
    });
  });
}
