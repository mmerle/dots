import assert from 'node:assert/strict';
import { getEventListeners } from 'node:events';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { test } from 'node:test';

const host = process.env.PI_PACKAGE_DIR;
if (!host)
  throw new Error('Set PI_PACKAGE_DIR to the installed @earendil-works/pi-coding-agent directory.');
const fromHost = (path) => import(pathToFileURL(resolve(host, path)));
const { loadExtensions } = await fromHost('dist/core/extensions/loader.js');
const { createEventBus } = await fromHost('dist/core/event-bus.js');
const { CURSOR_MARKER, getKeybindings, KeybindingsManager, TUI_KEYBINDINGS, visibleWidth } =
  await fromHost('node_modules/@earendil-works/pi-tui/dist/index.js');
const bus = createEventBus();
const { extensions, errors } = await loadExtensions(
  [new URL('../index.ts', import.meta.url).pathname],
  process.cwd(),
  bus,
);
assert.deepEqual(errors, []);
const tool = extensions[0].tools.get('ask').definition;
const choices = [
  { title: 'Stable', description: 'Predictable releases.' },
  { title: 'Preview', description: 'Upcoming changes.' },
];
const multi = { question: 'Features?', options: choices, allowMultiple: true };
const single = { question: 'Channel?', options: choices };
const theme = {
  fg: (color, text) =>
    `\x1b[${{ accent: 31, text: 37, muted: 90, dim: 2, warning: 33 }[color]}m${text}\x1b[0m`,
  bold: (text) => `\x1b[1m${text}\x1b[22m`,
};
const plain = (text) => text.replace(/\x1b\[[0-9;]*m/g, '');
const down = '\x1b[B';
const up = '\x1b[A';
const right = '\x1b[C';
const left = '\x1b[D';
const enter = '\r';
const escape = '\x1b';
const tab = '\t';

async function run(
  params,
  interact,
  { signal, keys = getKeybindings(), rows = 40, width = 80 } = {},
) {
  return tool.execute('test', params, signal, undefined, {
    mode: 'tui',
    ui: {
      async custom(factory, options) {
        assert.equal(options.blocked.kind, 'question');
        assert.match(options.blocked.message, /Waiting on answers for \d questions?/);
        return new Promise((done) => {
          const component = factory({ terminal: { rows }, requestRender() {} }, theme, keys, done);
          component.focused = true;
          const render = (columns = width) => component.render(columns).join('\n');
          render();
          const press = (...inputs) =>
            inputs.forEach((input) => {
              component.handleInput(input);
              render();
            });
          interact({ component, press, render: (columns) => plain(render(columns)), raw: render });
        });
      },
    },
  });
}

const batch = { question: 'Setup', context: 'Shared context', questions: [single, multi] };

test('registers ask as a sequential, model-only tool', () => {
  assert.equal(tool.name, 'ask');
  assert.equal(tool.exposure, 'model-only');
  assert.equal(tool.executionMode, 'sequential');
});

test('single choice uses radio markers, advances, and requires final submission', async () => {
  const result = await run(single, ({ press, render }) => {
    assert.match(render(), /\(○\) Stable/);
    press(down, enter);
    assert.match(render(), /Review answers/);
    assert.match(render(), /Preview/);
    press(enter);
  });
  assert.deepEqual(result.details, {
    cancelled: false,
    answers: [{ question: 'Channel?', selections: ['Preview'] }],
  });
});

test('question titles and option labels are neutral; accent is limited to selected markers', async () => {
  await run(single, ({ press, raw, render }) => {
    assert.match(raw(), /\x1b\[37mChannel\?/);
    assert.match(raw(), /\x1b\[37mStable/);
    assert.doesNotMatch(raw(), /\x1b\[31m/);
    press(' ');
    assert.match(render(), /\(●\) Stable/);
    assert.match(raw(), /\x1b\[31m\(●\)\x1b\[0m/);
    press(enter, enter);
  });
});

test('number shortcuts select a radio answer but cannot bypass final review', async () => {
  const result = await run(single, ({ press, render }) => {
    assert.match(render(), /2 \(○\) Preview/);
    press('2');
    assert.match(render(), /Review answers/);
    press(enter);
  });
  assert.deepEqual(result.details.answers[0].selections, ['Preview']);
});

test('letter shortcuts cover choices after nine', async () => {
  const options = Array.from({ length: 15 }, (_, index) => ({ title: `Option ${index + 1}` }));
  const result = await run({ question: 'Pick', options }, ({ press }) => press('f', enter));
  assert.deepEqual(result.details.answers[0].selections, ['Option 15']);
});

test('Tab and Shift+Tab cycle answer rows without opening notes', async () => {
  await run(single, ({ press, render }) => {
    press(tab);
    assert.match(render(), /→ 2 \(○\) Preview/);
    press(tab);
    assert.match(render(), /→ z \(○\) Type your answer/);
    press(tab);
    assert.match(render(), /→ 1 \(○\) Stable/);
    press('\x1b[Z');
    assert.match(render(), /→ z \(○\) Type your answer/);
    assert.doesNotMatch(render(), /Notes \(optional\)/);
    press('X');
  });
});

test('multi-select number shortcuts toggle in place and z opens inline text', async () => {
  const result = await run(multi, ({ press, render }) => {
    press('1', '2', '2');
    assert.match(render(), /\[x\] Stable/);
    assert.match(render(), /\[ \] Preview/);
    assert.match(render(), /\[1\/1\]/);
    press('z', 'Custom choice');
    assert.match(render(), /Stable/);
    assert.match(render(), /Preview/);
    assert.match(render(), /Your answer/);
    press(escape, right, enter);
  });
  assert.deepEqual(result.details.answers[0], {
    question: 'Features?',
    selections: ['Stable'],
    text: 'Custom choice',
  });
});

test('input keeps choices visible and treats shortcut characters as literal text', async () => {
  const result = await run(single, ({ press, render }) => {
    press('z', '2znX');
    assert.match(render(), /\(○\) Stable/);
    assert.match(render(), /\(○\) Preview/);
    assert.match(render(), /2znX/);
    press(escape);
    assert.match(render(), /\(●\) Type your answer/);
    press(right, enter);
  });
  assert.deepEqual(result.details.answers[0], {
    question: 'Channel?',
    selections: [],
    text: '2znX',
  });
});

test('z does not open a forbidden written alternative', async () => {
  await run({ ...single, allowFreeform: false }, ({ press, render }) => {
    press('z');
    assert.doesNotMatch(render(), /Your answer/);
    press('1', enter);
  });
});

test('Escape unselects then parks for scrollback without cancelling', async () => {
  const result = await run(single, ({ component, press, render }) => {
    press(' ', 'n', 'Keep this note', escape);
    assert.match(render(), /Notes: Keep this note/);
    press(escape);
    assert.match(render(), /\(○\) Stable/);
    assert.match(render(), /Notes: Keep this note/);
    assert.equal(component.capturesViewportInput, true);
    press(escape);
    assert.equal(component.capturesViewportInput, false);
    assert.match(render(), /Scrollback/);
    press('2', escape);
    assert.match(render(), /Channel\?/);
    assert.doesNotMatch(render(), /\(●\) Preview/);
    press(tab);
    assert.equal(component.capturesViewportInput, true);
    press(escape, ' ');
    assert.equal(component.capturesViewportInput, true);
    assert.doesNotMatch(render(), /\(●\) Stable/);
    press('2', enter);
  });
  assert.equal(result.details.cancelled, false);
  assert.deepEqual(result.details.answers[0], {
    question: 'Channel?',
    selections: ['Preview'],
    notes: 'Keep this note',
  });
});

test('Escape from review parks without erasing collected answers; Shift+X dismisses', async () => {
  const result = await run(single, ({ component, press, render }) => {
    press('1', escape, escape);
    assert.equal(component.capturesViewportInput, false);
    assert.match(render(), /Stable/);
    press('X');
  });
  assert.equal(result.details.cancelled, true);
  assert.deepEqual(result.details.answers[0].selections, ['Stable']);
});

test('Ctrl+C can dismiss while typing', async () => {
  const result = await run(single, ({ press }) => press('z', 'Unsubmitted draft', '\x03'));
  assert.equal(result.details.cancelled, true);
});

test('focused descriptions wrap fully while the choices remain visible', async () => {
  const description =
    'The focused description should wrap across several lines and reveal every word rather than disappearing behind a truncated one-line label.';
  await run(
    { ...single, options: [{ title: 'Stable', description }, choices[1]] },
    ({ press, render }) => {
      assert.ok(render(46).replace(/\s+/g, ' ').includes(description));
      assert.match(render(), /Preview/);
      press('z', 'Typed answer');
      assert.match(render(), /Stable/);
      assert.match(render(), /Preview/);
      press(escape, right, enter);
    },
    { rows: 24 },
  );
});

test('multi-select uses ASCII checkboxes and preserves option order', async () => {
  const result = await run(multi, ({ press, render }) => {
    press(down, ' ', up, ' ');
    assert.match(render(), /\[x\] Stable/);
    assert.match(render(), /\[x\] Preview/);
    press(enter, enter);
  });
  assert.deepEqual(result.details.answers[0].selections, ['Stable', 'Preview']);
});

test('direct back/forward navigation preserves answers before reaching review', async () => {
  const result = await run(batch, ({ press, render }) => {
    press(down, enter, ' ');
    assert.match(render(), /\[2\/2\]/);
    press(left);
    assert.match(render(), /\(●\) Preview/);
    press(up, enter);
    assert.match(render(), /\[x\] Stable/);
    press(right, left);
    assert.match(render(), /Features\?/);
    assert.match(render(), /\[x\] Stable/);
    press(enter, enter);
  });
  assert.deepEqual(
    result.details.answers.map((answer) => answer.selections),
    [['Stable'], ['Stable']],
  );
});

test('queued keys preserve focus and answers without an intervening render', async () => {
  const result = await run(batch, ({ component, render }) => {
    for (const key of [down, enter, down, ' ', left]) component.handleInput(key);
    assert.match(render(), /\(●\) Preview/);
    for (const key of [right, enter, enter]) component.handleInput(key);
  });
  assert.deepEqual(
    result.details.answers.map((answer) => answer.selections),
    [['Preview'], ['Preview']],
  );
});

test('skipping unanswered questions cannot submit the request', async () => {
  const result = await run(batch, ({ press, render }) => {
    press(right, right, enter);
    assert.match(render(), /Answer this question before submitting/);
    assert.match(render(), /Channel\?/);
    press(enter, enter, enter);
  });
  assert.equal(result.details.cancelled, false);
  assert.equal(result.details.answers.length, 2);
});

test('Other is editable inline and combines with multi-select choices', async () => {
  const result = await run(multi, ({ press, render }) => {
    press(' ', down, down, enter, 'Custom choice', enter);
    press(left);
    assert.match(render(), /\[x\] Type your answer/);
    press(enter);
    assert.match(render(), /Custom choice/);
    press(escape, right, enter);
  });
  assert.deepEqual(result.details.answers[0], {
    question: 'Features?',
    selections: ['Stable'],
    text: 'Custom choice',
  });
});

test('clearing the written part of a multi-select can explicitly choose none', async () => {
  const result = await run(multi, ({ press }) => {
    press(down, down, enter, 'Custom choice', enter, left, enter, '\x15', enter, enter);
  });
  assert.equal(result.details.cancelled, false);
  assert.deepEqual(result.details.answers[0], { question: 'Features?', selections: [] });
});

test('written answers use Pi Input and preserve drafts when revisited', async () => {
  const result = await run({ question: 'Name?' }, ({ press, render }) => {
    press(enter, 'Example', enter, left, enter);
    assert.match(render(), /Example/);
    press(escape, right, enter);
  });
  assert.deepEqual(result.details.answers[0], {
    question: 'Name?',
    selections: [],
    text: 'Example',
  });
});

test('notes are separate from single-choice answers even when Other is disabled', async () => {
  const result = await run({ ...single, allowFreeform: false }, ({ press, render }) => {
    assert.doesNotMatch(render(), /Type your answer/);
    press('n', 'After smoke testing', enter, enter);
    assert.match(render(), /Notes: After smoke testing/);
    press(left);
    assert.match(render(), /Notes: After smoke testing/);
    assert.match(render(), /\(●\) Stable/);
    press(right, enter);
  });
  assert.deepEqual(result.details.answers[0], {
    question: 'Channel?',
    selections: ['Stable'],
    notes: 'After smoke testing',
  });
  assert.match(result.content[0].text, /Notes: After smoke testing/);
});

test('changing an answer preserves notes; Escape retains edited notes', async () => {
  const result = await run(single, ({ press, render }) => {
    press('n', 'Saved note', enter, down, enter, left, 'n', '\x15', 'Keep this edit', escape);
    assert.match(render(), /Notes: Keep this edit/);
    press(right, enter);
  });
  assert.deepEqual(result.details.answers[0], {
    question: 'Channel?',
    selections: ['Preview'],
    notes: 'Keep this edit',
  });
});

test('clearing notes removes them without clearing the answer', async () => {
  const result = await run(single, ({ press, render }) => {
    press(' ', 'n', 'Temporary note', enter, 'n', '\x15', enter);
    assert.doesNotMatch(render(), /Notes: Temporary note/);
    press(enter, enter);
  });
  assert.deepEqual(result.details.answers[0], { question: 'Channel?', selections: ['Stable'] });
});

test('empty written answers stay open and do not imply consent', async () => {
  const result = await run({ question: 'Approve?' }, ({ press, render }) => {
    press(enter, enter);
    assert.match(render(), /Write an answer/);
    press(escape, escape, 'X');
  });
  assert.equal(result.details.cancelled, true);
  assert.deepEqual(result.details.answers, []);
});

test('explicit empty multi-select is valid', async () => {
  const result = await run({ ...multi, allowFreeform: false }, ({ press }) => press(enter, enter));
  assert.equal(result.details.cancelled, false);
  assert.deepEqual(result.details.answers[0].selections, []);
});

test('review can return to any question with selected markers intact', async () => {
  const result = await run(batch, ({ press, render }) => {
    press(enter, ' ', enter, down, down, enter);
    assert.match(render(), /\[x\] Stable/);
    press(down, ' ', enter, up, up, enter);
  });
  assert.deepEqual(result.details.answers[1].selections, ['Stable', 'Preview']);
});

test('cancellation reports collected answers as unsubmitted', async () => {
  const result = await run(batch, ({ press }) => press(enter, 'X'));
  assert.equal(result.details.cancelled, true);
  assert.equal(result.details.answers.length, 1);
  assert.match(result.content[0].text, /not submitted/);
});

test('Input follows the configured submit binding and propagates focus', async () => {
  const keys = new KeybindingsManager(TUI_KEYBINDINGS, { 'tui.input.submit': 'ctrl+enter' });
  const result = await run(
    { question: 'Name?' },
    ({ component, press, render, raw }) => {
      press(enter, 'Example');
      assert.match(render(), /ctrl\+enter save/);
      assert.ok(raw().includes(CURSOR_MARKER));
      component.focused = false;
      assert.ok(!raw().includes(CURSOR_MARKER));
      component.focused = true;
      assert.ok(raw().includes(CURSOR_MARKER));
      press('\x1b[13;5u', enter);
    },
    { keys },
  );
  assert.equal(result.details.answers[0].text, 'Example');
});

test('aborts close the card and release listeners', async () => {
  const controller = new AbortController();
  const result = await run(single, () => controller.abort(), { signal: controller.signal });
  assert.equal(result.details.cancelled, true);
  assert.equal(getEventListeners(controller.signal, 'abort').length, 0);
});

test('abort wins even when it arrives immediately after submission', async () => {
  const controller = new AbortController();
  const result = await run(
    single,
    ({ press }) => {
      press(enter, enter);
      controller.abort();
    },
    { signal: controller.signal },
  );
  assert.equal(result.details.cancelled, true);
});

test('already aborted requests open no UI and clean up waiting status', async () => {
  const events = [];
  const off = bus.on('ask:waiting', (event) => events.push(event.count));
  try {
    const result = await tool.execute('test', single, AbortSignal.abort(), undefined, {
      mode: 'tui',
      ui: {},
    });
    assert.equal(result.details.cancelled, true);
    assert.deepEqual(events, [1, 0]);
  } finally {
    off();
  }
});

test('waiting status is cleared even when UI creation fails', async () => {
  const events = [];
  const off = bus.on('ask:waiting', (event) => events.push(event.count));
  try {
    await assert.rejects(
      tool.execute('test', batch, undefined, undefined, {
        mode: 'tui',
        ui: {
          custom() {
            throw new Error('UI failed');
          },
        },
      }),
      /UI failed/,
    );
    assert.deepEqual(events, [2, 0]);
  } finally {
    off();
  }
});

test('validates all questions before opening UI', async () => {
  for (const params of [
    {},
    { question: ' ' },
    { question: 'Pick', options: [{ title: ' ' }] },
    { question: 'Pick', options: [{ title: 'Same' }, { title: ' Same ' }] },
    { question: 'Pick', allowFreeform: false },
    { questions: [single, { question: ' ' }] },
    { questions: [single, single], allowMultiple: true },
  ])
    await assert.rejects(
      tool.execute('test', params, undefined, undefined, { mode: 'tui', ui: {} }),
    );
});

test('rejects noninteractive modes explicitly', async () => {
  await assert.rejects(
    tool.execute('test', single, undefined, undefined, { mode: 'rpc' }),
    /interactive/,
  );
});

test('long content renders within narrow widths and choice lists scroll', async () => {
  await run(
    {
      question: '日本語 🚀 '.repeat(8),
      options: Array.from({ length: 20 }, (_, index) => ({
        title: `Option ${index} ${'x'.repeat(40)}`,
      })),
    },
    ({ component, press }) => {
      for (const width of [12, 30, 80]) {
        component.invalidate();
        assert.ok(component.render(width).every((line) => visibleWidth(line) <= width));
      }
      press(...Array(19).fill(down), enter, enter);
    },
    { rows: 24 },
  );
});

test('elapsed status keeps the waiting label across timer ticks and restores working text', async (t) => {
  t.mock.timers.enable({ apis: ['setInterval'] });
  const loaded = await loadExtensions(
    [new URL('../../elapsed.ts', import.meta.url).pathname],
    process.cwd(),
    bus,
  );
  assert.deepEqual(loaded.errors, []);
  const handlers = loaded.extensions[0].handlers;
  const messages = [];
  const ctx = {
    mode: 'tui',
    ui: {
      setWorkingMessage(value) {
        messages.push(value);
      },
    },
  };
  try {
    await handlers.get('agent_start')[0]({}, ctx);
    bus.emit('ask:waiting', { count: 3 });
    assert.equal(messages.at(-1), 'Waiting on answers for 3 questions');
    t.mock.timers.tick(2000);
    assert.equal(messages.at(-1), 'Waiting on answers for 3 questions');
    bus.emit('ask:waiting', { count: 1 });
    assert.equal(messages.at(-1), 'Waiting on answers for 1 question');
    bus.emit('ask:waiting', { count: 0 });
    assert.match(messages.at(-1), /for \d+s$/);
  } finally {
    await handlers.get('session_shutdown')[0]({}, ctx);
    t.mock.timers.reset();
  }
});
