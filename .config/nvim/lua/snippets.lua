local ls = require('luasnip')

ls.add_snippets('lua', {
  ls.snippet('hello', {
    ls.text_node('print("hello world")'),
  }),
})

ls.add_snippets('javascriptreact', {
  ls.snippet('frag', {
    ls.text_node('<>'),
    ls.insert_node(0),
    ls.text_node('</>'),
  }),
})
