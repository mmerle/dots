return {
  filetypes = {
    'astro',
    'html',
    'javascript',
    'javascriptreact',
    'php',
    'svelte',
    'twig',
    'typescript',
    'typescriptreact',
  },
  init_options = {
    javascript = {
      options = {
        jsx = { enabled = true },
        ['markup.attributes'] = { class = 'className' },
      },
    },
  },
}
