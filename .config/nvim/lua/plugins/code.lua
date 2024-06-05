return {
	-- luasnip (https://github.com/L3MON4D3/LuaSnip)
	{
		'L3MON4D3/LuaSnip',
		event = 'InsertEnter',
		dependencies = {
			'rafamadriz/friendly-snippets',
			'saadparwaiz1/cmp_luasnip',
		},
		config = function()
			require('luasnip.loaders.from_vscode').lazy_load()
		end,
	},
	-- completions (https://github.com/hrsh7th/nvim-cmp)
	{
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = {
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'onsails/lspkind-nvim',
		},
		config = function()
			local cmp = require('cmp')
			local lspkind = require('lspkind')
			cmp.setup({
				snippet = {
					expand = function(args)
						require('luasnip').lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					['<C-Space>'] = cmp.mapping.complete(),
					['<cr>'] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = false,
					}),
					['<C-j>'] = function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end,
					['<C-k>'] = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end,
				}),
				sources = {
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'buffer', keyword_length = 2 },
					{ name = 'path' },
				},
				formatting = {
					format = lspkind.cmp_format({
						mode = 'text',
						menu = {
							buffer = '[buf]',
							nvim_lsp = '[LSP]',
							path = '[path]',
							luasnip = '[snip]',
						},
					}),
				},
			})

			-- `/` cmdline setup.
			cmp.setup.cmdline('/', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = 'buffer' },
				},
			})
		end,
	},
	-- comment (https://github.com/numToStr/Comment.nvim)
	{
		'numToStr/Comment.nvim',
		event = 'VeryLazy',
		dependencies = {
			'JoosepAlviste/nvim-ts-context-commentstring',
		},
		config = function()
			require('Comment').setup({
				pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
			})
		end,
	},
	-- nvim-surround (https://github.com/kylechui/nvim-surround)
	{
		'kylechui/nvim-surround',
		event = 'VeryLazy',
		opts = {
			keymaps = {
				insert = '<C-g>z',
				insert_line = '<C-g>gZ',
				normal = 'gz',
				normal_cur = 'gZ',
				normal_line = 'gzgz',
				normal_cur_line = 'gZgZ',
				visual = 'gz',
				visual_line = 'gZ',
				delete = 'gzd',
				change = 'gzc',
			},
		},
	},
	-- nvim-autopairs (https://github.com/windwp/nvim-autopairs)
	{
		'windwp/nvim-autopairs',
		event = 'InsertEnter',
		opts = {},
	},
	-- vim-repeat (https://github.com/tpope/vim-repeat)
	{
		'tpope/vim-repeat',
		event = 'VeryLazy',
	},
}
