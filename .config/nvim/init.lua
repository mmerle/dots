local function map(mode, lhs, rhs, opts)
	opts = opts or { noremap = true, silent = true }
	return vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

vim.g.mapleader = " "

map("n", "<leader>r", ":source ~/.config/nvim/init.lua<cr>")
map("n", "<leader>e", ":NvimTreeToggle<cr>")
map("n", "<leader>p", [[:lua require('telescope.builtin').find_files()<cr>]])

map("n", "<leader>s", ":w<cr>")
map("n", "<leader>q", ":q<cr>")

map("n", "gt", ":BufferNext<cr>")
map("n", "gT", ":BufferPrevious<cr>")
map("n", "<leader>w", ":BufferClose<cr>")

map("n", "<leader>kc", ":PackerCompile<cr>")
map("n", "<leader>ks", ":PackerSync<cr>")

vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 5
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.breakindent = true
vim.opt.cindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.title = true
vim.opt.titlestring = "%t"
vim.opt.laststatus = 0
vim.opt.statusline = "%f %M %= %l:%c"
vim.opt.wildmode = "longest:full,full"
vim.opt.smartcase = true
vim.opt.updatetime = 300
vim.opt.pumheight = 10
vim.opt.termguicolors = true

vim.cmd("colorscheme flora")

-- plugins
require("packer").startup(function(use)
	use("wbthomason/packer.nvim")
	use("tpope/vim-commentary")
	use("mattn/emmet-vim")
	use("b0o/schemastore.nvim")
	use({
		"nvim-telescope/telescope.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("telescope").setup({
				defaults = {
					file_ignore_patterns = { "node_modules", ".git/", ".next/" },
					layout_config = { horizontal = { preview_width = 0.6 } },
				},
				pickers = {
					find_files = {
						hidden = true,
						theme = "dropdown",
						previewer = false,
					},
				},
			})
		end,
	})
	use({
		"kyazdani42/nvim-tree.lua",
		config = function()
			vim.g.nvim_tree_git_hl = 1
			vim.g.nvim_tree_icons = {
				folder = {
					default = "▶",
					empty = "▶",
					symlink = "▶",
					open = "▼",
					empty_open = "▼",
					symlink_open = "▼",
				},
			}
			vim.g.nvim_tree_symlink_arrow = " → "
			vim.g.nvim_tree_quit_on_open = 1
			vim.g.nvim_tree_show_icons = { folders = 1, files = 0 }

			require("nvim-tree").setup({
				auto_close = true,
				filters = {
					custom = { ".git", ".DS_Store" },
				},
				view = {
					hide_root_folder = true,
				},
			})
		end,
	})
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		requires = {
			"nvim-treesitter/playground",
			"windwp/nvim-ts-autotag",
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = "maintained",
				ignore_install = { "haskell" },
				indent = { enable = true },
				autotag = { enable = true },
				highlight = { enable = true },
				context_commentstring = { enable = true, enable_autocmd = false },
				playground = { enable = true },
			})
		end,
	})
	use({
		"neovim/nvim-lspconfig",
		requires = { "folke/lua-dev.nvim" },
		config = function()
			local function on_attach(client, bufnr)
				client.resolved_capabilities.document_formatting = false
				client.resolved_capabilities.document_range_formatting = false

				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

				local function buf_map(mode, lhs, rhs, opts)
					opts = opts or { noremap = true, silent = true }
					vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
				end

				buf_map("n", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>")
				buf_map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
				buf_map("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")
				buf_map("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>")
				buf_map("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>")
				buf_map("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
				buf_map("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<cr>")
				buf_map("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>")
				buf_map("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<cr>")
			end

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

			local lspconfig = require("lspconfig")
			lspconfig.sumneko_lua.setup(require("lua-dev").setup({
				lspconfig = {
					cmd = {
						vim.fn.getenv("HOME") .. "/.local/share/lua-language-server/bin/macOS/lua-language-server",
					},
					on_attach = on_attach,
					capabilities = capabilities,
				},
			}))

			local servers = { "html", "jsonls", "cssls", "tailwindcss", "tsserver", "svelte" }
			for _, server in ipairs(servers) do
				local opts = {}

				if server == "jsonls" then
					opts = {
						filetypes = { "json", "jsonc" },
						settings = {
							json = {
								schemas = require("schemastore").json.schemas(),
							},
						},
					}
				end

				lspconfig[server].setup(vim.tbl_deep_extend("force", {
					on_attach = on_attach,
					capabilities = capabilities,
				}, opts))
			end
		end,
	})
	use({
		"jose-elias-alvarez/null-ls.nvim",
		requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		config = function()
			local null_ls = require("null-ls")
			local prettier_filetypes = null_ls.builtins.formatting.prettier.filetypes
			table.insert(prettier_filetypes, "jsonc")
			table.insert(prettier_filetypes, "svelte")

			null_ls.config({
				sources = {
					null_ls.builtins.formatting.fish_indent,
					null_ls.builtins.formatting.prettierd.with({
						filetypes = prettier_filetypes,
					}),
					null_ls.builtins.formatting.shfmt.with({ filetypes = { "bash", "sh", "zsh" } }),
					null_ls.builtins.formatting.stylua,
				},
			})

			require("lspconfig")["null-ls"].setup({
				on_attach = function(client)
					if client.resolved_capabilities.document_formatting then
						vim.cmd([[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]])
					end
				end,
			})
		end,
	})
	use({
		"hrsh7th/nvim-cmp",
		requires = { "L3MON4D3/LuaSnip", "hrsh7th/cmp-nvim-lsp", "windwp/nvim-autopairs" },
		config = function()
			local cmp = require("cmp")

			cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = {
					["<c-space>"] = cmp.mapping.complete(),
					["<cr>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = false,
					}),
					["<tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end,
					["<s-tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end,
				},
				sources = {
					{ name = "nvim_lsp" },
				},
			})
		end,
	})
	use({
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup()
		end,
	})
	use({
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({
				"*",
				css = {
					hsl_fn = true,
					names = false,
				},
			})
		end,
	})
	use({
		"lewis6991/gitsigns.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	})
	use({
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("indent_blankline").setup({
				show_end_of_line = true,
			})
		end,
	})
	use({
		"romgrk/barbar.nvim",
		config = function()
			vim.g.bufferline = {
				animation = false,
				icon_close_tab = "x",
				icon_close_tab_modified = "•",
				icons = false,
			}
		end,
	})
end)
