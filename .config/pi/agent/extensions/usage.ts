import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';
import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';

const HEADER_PREFIX = 'anthropic-ratelimit-unified-';
const CODEX_USAGE_URL = 'https://chatgpt.com/backend-api/wham/usage';

type CodexWindow = { used_percent: number; limit_window_seconds: number; reset_at: number };

function formatDuration(seconds: number): string {
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  if (days) return `${days}d ${hours}h`;
  if (hours) return `${hours}h ${minutes}m`;
  return `${minutes}m`;
}

function formatWindow(label: string, percent: number, resetAt: number): string {
  const filled = Math.max(0, Math.min(10, Math.round(percent / 10)));
  const bar = '▒'.repeat(filled) + '░'.repeat(10 - filled);
  const reset = formatDuration(Math.max(0, resetAt - Date.now() / 1000));
  return `  ${label.padEnd(4)} ${bar} ${String(Math.round(percent)).padStart(3)}% · resets in ${reset}`;
}

async function codexUsage(token: string, accountId: string | undefined): Promise<string[]> {
  const response = await fetch(CODEX_USAGE_URL, {
    headers: { Authorization: `Bearer ${token}`, ...(accountId && { 'chatgpt-account-id': accountId }) },
    signal: AbortSignal.timeout(10_000),
  });
  if (!response.ok) return [`  Request failed (${response.status})`];
  const { rate_limit } = (await response.json()) as {
    rate_limit?: { primary_window?: CodexWindow | null; secondary_window?: CodexWindow | null };
  };
  return [rate_limit?.primary_window, rate_limit?.secondary_window]
    .filter((window): window is CodexWindow => !!window)
    .map((window) =>
      formatWindow(`${window.limit_window_seconds / 86400}d`, window.used_percent, window.reset_at)
    );
}

export default function usage(pi: ExtensionAPI) {
  // NOTE: claude-bridge forwards Claude Code's rate_limit_event as unified headers
  let claude: Record<string, string> = {};

  pi.on('after_provider_response', (event) => {
    for (const [key, value] of Object.entries(event.headers)) {
      if (key.startsWith(HEADER_PREFIX)) claude[key.slice(HEADER_PREFIX.length)] = value;
    }
  });

  pi.registerCommand('usage', {
    description: 'Show plan usage for connected providers',
    handler: async (_args, ctx) => {
      const claudeLines = Object.keys(claude)
        .filter((key) => key.endsWith('-utilization'))
        .map((key) => {
          const window = key.slice(0, -'-utilization'.length);
          return formatWindow(window, Number(claude[key]) * 100, Number(claude[`${window}-reset`]));
        });
      const sections = [
        ['Claude', ...(claudeLines.length ? claudeLines : ['  No usage reported yet this session'])],
      ];

      const auth = JSON.parse(readFileSync(join(homedir(), '.pi/agent/auth.json'), 'utf8'));
      if (auth['openai-codex']) {
        const token = await ctx.modelRegistry.getApiKeyForProvider('openai-codex');
        const lines = token
          ? await codexUsage(token, auth['openai-codex'].accountId).catch((error) => [`  ${error.message}`])
          : ['  No token available'];
        sections.push(['Codex', ...lines]);
      }

      ctx.ui.notify(sections.map((lines) => lines.join('\n')).join('\n\n'), 'info');
    },
  });
}
