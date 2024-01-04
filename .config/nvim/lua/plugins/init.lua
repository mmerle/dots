return {
  -- flora
  {
    dir = '~/Developer/projects/p/flora/flora.nvim',
    name = 'flora',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme flora]])
    end,
  },
}
