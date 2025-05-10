return {
  filetypes = {
    'astro',
    'html',
    'javascript',
    'javascriptreact',
    'php',
    'svelte',
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
