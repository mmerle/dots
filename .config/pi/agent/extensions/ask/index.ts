import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';
import { Text } from '@earendil-works/pi-tui';
import { Type, type Static } from 'typebox';
import { askQuestions, formatAnswers, type AskQuestion, type AskResult } from './questionnaire';

const optionSchema = Type.Object({
  title: Type.String({ minLength: 1 }),
  description: Type.Optional(Type.String()),
});
const questionFields = {
  question: Type.String({ minLength: 1 }),
  context: Type.Optional(Type.String()),
  options: Type.Optional(Type.Array(optionSchema)),
  allowMultiple: Type.Optional(
    Type.Boolean({ description: 'Allow selecting several options. Default: false.' }),
  ),
  allowFreeform: Type.Optional(
    Type.Boolean({ description: 'Allow a written answer. Default: true.' }),
  ),
};
const parameters = Type.Object({
  ...questionFields,
  question: Type.Optional(
    Type.String({ description: 'Question, or an optional heading when using questions.' }),
  ),
  questions: Type.Optional(Type.Array(Type.Object(questionFields), { minItems: 2, maxItems: 4 })),
});
type AskParams = Static<typeof parameters>;

function getQuestions(params: AskParams): AskQuestion[] {
  const hasAnswerSettings =
    params.options !== undefined ||
    params.allowMultiple !== undefined ||
    params.allowFreeform !== undefined;
  if (params.questions && hasAnswerSettings) {
    throw new Error('With questions, put options and answer settings inside each question.');
  }
  return (params.questions ?? [{ ...params, question: params.question ?? '' }]).map((question) => {
    if (!question.question.trim())
      throw new Error('Provide a non-empty question or a questions batch.');
    const titles = question.options?.map((option) => option.title.trim()) ?? [];
    if (titles.some((title) => !title) || new Set(titles).size !== titles.length) {
      throw new Error('Option titles must be non-empty and unique within each question.');
    }
    if (!titles.length && question.allowFreeform === false) {
      throw new Error('A question without options must allow a written answer.');
    }
    return {
      ...question,
      context: [params.questions ? params.context : undefined, question.context]
        .filter(Boolean)
        .join('\n\n'),
    };
  });
}

export default function ask(pi: ExtensionAPI) {
  pi.registerTool<typeof parameters, AskResult>({
    name: 'ask',
    label: 'Ask',
    description:
      'Ask questions with optional choices, multiple selection, or written answers. Use questions for 2–4 independent questions. The user can navigate between questions, add notes, and review answers before submitting.',
    parameters,
    exposure: 'model-only',
    executionMode: 'sequential',
    promptSnippet: 'Ask the user for clarification, preferences, or confirmation.',
    promptGuidelines: [
      'Use ask when requirements are ambiguous or a consequential decision needs explicit user input.',
      'Before ask, gather relevant context and include a short summary in context.',
      'Use one focused question by default. Batch only independent questions; put each question and its answer settings inside questions.',
      'Use allowMultiple for a list of independent choices. A cancelled ask request is not approval.',
    ],
    async execute(_toolCallId, params, signal, _onUpdate, ctx) {
      if (ctx.mode !== 'tui') throw new Error('ask requires an interactive Pi terminal.');
      const questions = getQuestions(params);
      pi.events.emit('ask:waiting', { count: questions.length });
      try {
        const result = await askQuestions(
          ctx.ui,
          params.questions ? params.question : undefined,
          questions,
          signal,
        );
        return { content: [{ type: 'text', text: formatAnswers(result) }], details: result };
      } finally {
        pi.events.emit('ask:waiting', { count: 0 });
      }
    },
    renderCall(args, theme) {
      const title = args.question ?? `${args.questions?.length ?? 0} questions`;
      return new Text(theme.fg('toolTitle', theme.bold('Ask ')) + theme.fg('text', title), 0, 0);
    },
    renderResult(result, _options, theme) {
      const details = result.details;
      return new Text(
        theme.fg(details?.cancelled ? 'warning' : 'text', details ? formatAnswers(details) : ''),
        0,
        0,
      );
    },
  });
}
