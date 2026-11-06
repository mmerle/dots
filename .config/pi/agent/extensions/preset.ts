import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import {
  getAgentDir,
  type ExtensionAPI,
  type ExtensionContext,
} from '@earendil-works/pi-coding-agent';

type Preset = {
  tools: string[];
  instructions?: string;
  replaceSystemPrompt?: boolean;
  allowMcp?: boolean;
};
type Active = { name: string; preset: Preset; originalTools: string[] };

const isMcp = (tool: string) => tool.startsWith('mcp__') || /^(list|read)_mcp_resource/.test(tool);

function loadPresets(): Record<string, Preset> {
  try {
    return JSON.parse(readFileSync(join(getAgentDir(), 'presets.json'), 'utf8'));
  } catch {
    return {};
  }
}

export default function preset(pi: ExtensionAPI) {
  const presets = loadPresets();
  let active: Active | undefined;

  const allows = (tool: string) =>
    !!active && (active.preset.tools.includes(tool) || (!!active.preset.allowMcp && isMcp(tool)));

  function activate(
    ctx: ExtensionContext,
    name: string | null,
    persist = true,
    originalTools?: string[],
  ) {
    if (name && !presets[name]) return ctx.ui.notify(`Unknown preset "${name}"`, 'warning');
    const original = active?.originalTools ?? originalTools ?? pi.getActiveTools();
    active = name ? { name, preset: presets[name], originalTools: original } : undefined;
    pi.setActiveTools(active ? active.preset.tools : original);
    if (persist) pi.appendEntry('preset-state', { name, originalTools: original });
    ctx.ui.setStatus('preset', active && ctx.ui.theme.fg('accent', `preset:${name}`));
    if (persist) ctx.ui.notify(active ? `Preset "${name}" activated` : 'Preset cleared', 'info');
  }

  async function restore(_event: unknown, ctx: ExtensionContext) {
    if (active) pi.setActiveTools(active.originalTools);
    active = undefined;
    const entry = ctx.sessionManager
      .getBranch()
      .filter((e) => e.type === 'custom' && e.customType === 'preset-state')
      .pop() as { data?: { name: string | null; originalTools?: string[] } } | undefined;
    const flag = pi.getFlag('preset');
    if (entry?.data?.name) activate(ctx, entry.data.name, false, entry.data.originalTools);
    else if (!entry && typeof flag === 'string' && flag) activate(ctx, flag);
    else ctx.ui.setStatus('preset', undefined);
  }

  pi.registerFlag('preset', { description: 'Preset to start with', type: 'string' });
  pi.on('session_start', restore);
  pi.on('session_tree', restore);

  pi.registerShortcut('shift+tab', {
    description: 'Cycle presets',
    handler: async (ctx) => {
      const cycle = [null, ...Object.keys(presets)];
      activate(ctx, cycle[(cycle.indexOf(active?.name ?? null) + 1) % cycle.length]);
    },
  });

  pi.registerCommand('preset', {
    description: 'Switch preset: /preset <name|none>',
    getArgumentCompletions: (prefix) => {
      const names = [...Object.keys(presets), 'none'].filter((name) =>
        name.startsWith(prefix.trim()),
      );
      return names.length ? names.map((value) => ({ value, label: value })) : null;
    },
    handler: async (args, ctx) => {
      const name =
        args.trim() || (await ctx.ui.select('Preset', [...Object.keys(presets), 'none']));
      if (name) activate(ctx, name === 'none' ? null : name);
    },
  });

  pi.on('before_agent_start', async (event) => {
    if (!active) return;
    const { instructions, replaceSystemPrompt } = active.preset;
    if (!instructions) return;
    if (!replaceSystemPrompt) return { systemPrompt: `${event.systemPrompt}\n\n${instructions}` };
    Object.assign(event.systemPromptOptions, {
      customPrompt: instructions,
      contextFiles: [],
      skills: [],
      appendSystemPrompt: '',
      promptGuidelines: [],
    });
  });

  pi.on('tool_call', async (event, ctx) => {
    if (!active) return;
    if (!allows(event.toolName)) {
      return {
        block: true,
        reason: `Tool ${event.toolName} is unavailable in preset ${active.name}`,
      };
    }
    if (!isMcp(event.toolName)) return;
    const hints = pi.getAllTools().find((tool) => tool.name === event.toolName)?.annotations;
    if (hints?.readOnlyHint && !hints.destructiveHint) return;
    const input = JSON.stringify(event.input, null, 2).slice(0, 2000);
    if (
      !ctx.hasUI ||
      !(await ctx.ui.confirm('Allow integration action?', `${event.toolName}\n${input}`))
    ) {
      return { block: true, reason: 'Integration action was not approved' };
    }
  });
}
