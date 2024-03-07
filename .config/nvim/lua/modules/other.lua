return {
	-- flora
	{
		dir = "~/Developer/projects/p/flora/flora.nvim",
		name = "flora",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme flora]])
		end,
	},
	-- nvim-treesitter (https://github.com/nvim-treesitter/nvim-treesitter)
	{
		"nvim-treesitter/nvim-treesitter",
		enabled = not_vscode,
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"windwp/nvim-ts-autotag",
			"kevinhwang91/promise-async",
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = "all",
				ignore_install = { "phpdoc" },
				highlight = { enable = true },
				indent = { enable = true },
				autotag = { enable = true },
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
						},
					},
				},
			})
		end,
	},
	-- flash.nvim (https://github.com/folke/flash.nvim)
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			prompt = {
				enabled = false,
			},
			modes = {
				search = { enabled = false },
				char = { enabled = false },
			},
		},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
				mode = { "n", "o", "x" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
		},
	},
	-- markdown preview
	{
		"toppair/peek.nvim",
		enables = not_vscode,
		event = { "VeryLazy" },
		build = "deno task --quiet build:fast",
		keys = {
			{ "<leader>mp", "<cmd>PeekOpen<cr>", desc = "Preview markdown" },
		},
		config = function()
			require("peek").setup({
				app = "browser",
			})
			vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
			vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
		end,
	},
	-- obsidian.nvim (https://github.com/epwalsh/obsidian.nvim)
	{
		"epwalsh/obsidian.nvim",
		version = "*",
		lazy = true,
		event = {
			"BufReadPre " .. vim.fn.expand("~") .. "/Documents/notes/**.md",
			"BufNewFile " .. vim.fn.expand("~") .. "/Documents/notes/**.md",
		},
		keys = {
			{ "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Note" },
			{ "<leader>op", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick Switch" },
			{ "<leader>o/", "<cmd>ObsidianSearch<cr>", desc = "Search Notes" },
		},
		opts = {
			dir = "~/Documents/notes",
			completion = { nvim_cmp = true },
			mappings = {
				["gf"] = {
					action = function()
						return require("obsidian").util.gf_passthrough()
					end,
					opts = { noremap = false, expr = true, buffer = true },
				},
			},
			disable_frontmatter = true,
			open_app_foreground = true,
			attachments = {
				img_folder = "attachments/images",
			},
			daily_notes = {
				folder = "/daily",
				date_format = "%y-%m-%d",
			},
			ui = {
				checkboxes = {
					[" "] = { char = "▢", hl_group = "ObsidianTodo" },
					["x"] = { char = "✓", hl_group = "ObsidianDone" },
				},
				bullets = { char = "-", hl_group = "ObsidianBullet" },
				external_link_icon = { char = "↗", hl_group = "ObsidianExtLinkIcon" },
			},
		},
	},
}
