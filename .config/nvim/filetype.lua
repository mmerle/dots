vim.filetype.add({
  extension = {
    mdx = 'markdown',
    js = 'javascriptreact',
    conf = 'conf',
  },
  pattern = {
    ['.*%.env.*'] = 'sh',
    ['ignore$'] = 'conf',
  },
})
