vim.opt.termguicolors = true
vim.opt.statusline = '%f %M %= %l:%c'
vim.opt.mouse = 'a'

require 'colorizer'.setup()
require 'colorizer'.setup {
  'vim';
  'css';
  'javascript';
}
