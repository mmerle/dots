local ls = require('luasnip')

local function add_snippets(filetypes, snippet_body)
  for _, filetype in ipairs(vim.islist(filetypes) and filetypes or { filetypes }) do
    ls.add_snippets(filetype, snippet_body)
  end
end

add_snippets({ 'javascriptreact', 'typescriptreact' }, {
  ls.snippet('frag', {
    ls.text_node('<>'),
    ls.insert_node(0),
    ls.text_node('</>'),
  }),
})
