local indent = 2
local scrolloff = 3

-- disable netrw for better nvim-tree support
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- disable barbar auto setup
vim.g.barbar_auto_setup = false

vim.opt.autoindent = true -- good auto indent
vim.opt.breakindent = true
vim.opt.clipboard = "unnamedplus" -- enable universal clipboard
vim.opt.cursorline = true -- highlight current line
vim.opt.expandtab = true -- expand tabs into spaces
vim.opt.foldcolumn = "0"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.hidden = true -- handle multiple buffers better
vim.opt.ignorecase = true
vim.opt.laststatus = 3 -- global statusline
vim.opt.list = true
vim.opt.listchars = { tab = "  ", trail = "·" }
vim.opt.mouse = "a" -- enable mouse
vim.opt.number = true -- show line numbers
vim.opt.pumheight = 6 -- commandline completion height
vim.opt.relativenumber = true -- line numbers relative to cursor
vim.opt.scrolloff = scrolloff -- always show at least x lines above/below cursor
vim.opt.sidescrolloff = scrolloff -- always show at least x lines left/right cursor
vim.opt.shiftround = true -- round indent
vim.opt.shiftwidth = indent -- size of indent
vim.opt.showmode = false -- Hide redundant mode
vim.opt.shortmess:append("WcC") -- shorter messages
vim.opt.signcolumn = "yes" -- always show signcolumn
vim.opt.smartcase = true -- only case sensitive when alternate case is used
vim.opt.smartindent = true
vim.opt.smoothscroll = true
vim.opt.splitbelow = true -- split new window below current
vim.opt.splitright = true -- split new window right of current
vim.opt.statuscolumn = '%=%{&nu?(&rnu && v:relnum?v:relnum:v:lnum):""}%=%s'
vim.opt.swapfile = false -- disable swapfiles
vim.opt.tabstop = indent -- size of tab
vim.opt.termguicolors = true -- support for true colour
vim.opt.timeoutlen = 300
vim.opt.undofile = true -- unable undo
vim.opt.updatetime = 250 -- faster update time
vim.opt.visualbell = true -- disable beeping
vim.opt.wildmode = "longest:full,full" -- commandline completion settings
vim.opt.completeopt = "menu,menuone,noinsert"

-- when using fish, set shell to bash
if vim.env.SHELL:match("fish$") then
	vim.opt.shell = "/opt/homebrew/bin/bash"
end

if not vim.g.vscode then
	-- stop 'o' continuing comments
	vim.api.nvim_create_autocmd("BufEnter", {
		command = "setlocal formatoptions-=o",
	})

	-- highlight copied text
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
		end,
	})

	-- use circles for diagnostics
	local signs = { "Error", "Warn", "Hint", "Info" }
	for _, type in pairs(signs) do
		local hl = string.format("DiagnosticSign%s", type)
		vim.fn.sign_define(hl, { text = "●", texthl = hl, numhl = hl })
	end

	-- open nvim-tree on startup, only if in directory
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			local args = vim.fn.argv()
			local directory = vim.fn.isdirectory(args[1]) == 1

			if directory then
				require("nvim-tree.api").tree.open()
			end
		end,
	})

	-- custom statusline
	M = {}

	function M.watch_fn(fn)
		return '%<%{luaeval("' .. fn .. '")}'
	end

	function M.get_branch()
		if vim.fn.isdirectory(".git") ~= 0 then
			local branch = vim.fn.system("git branch --show-current | tr -d '\n'")
			return "(" .. branch .. ")"
		end
		return ""
	end

	function M.diagnostic_error_status()
		local num_errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })

		if num_errors > 0 then
			return "● " .. num_errors
		end
		return ""
	end

	function M.diagnostic_warn_status()
		local num_warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })

		if num_warnings > 0 then
			return "● " .. num_warnings
		end
		return ""
	end

	function M.statusline()
		local lsp_error_count = "%#DiagnosticError#" .. M.watch_fn("M.diagnostic_error_status()") .. "%*"
		local lsp_warning_count = "%#DiagnosticWarn#" .. M.watch_fn("M.diagnostic_warn_status()") .. "%*"
		local current_branch = M.watch_fn("M.get_branch()")

		local sections = {
			current_branch,
			"%f %M",
			"%=",
			lsp_error_count,
			lsp_warning_count,
			"%P %l:%c",
		}

		return " " .. table.concat(sections, " ") .. " "
	end

	-- vim.diagnostic.config({ virtual_text = false })
	vim.opt.statusline = M.statusline()

	-- switch between relative and absolute line numbers based on mode
	local number_toggle = vim.api.nvim_create_augroup("number_toggle", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
		callback = function()
			if vim.opt.number:get() == true then
				vim.opt.relativenumber = true
			end
		end,
		group = number_toggle,
	})
	vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
		callback = function()
			if vim.opt.number:get() == true then
				vim.opt.relativenumber = false
			end
		end,
		group = number_toggle,
	})

	-- open `:help` pages in vsplit
	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = vim.api.nvim_create_augroup("help_window_right", {}),
		pattern = { "*.txt" },
		callback = function()
			if vim.o.filetype == "help" then
				vim.api.nvim_cmd({ cmd = "wincmd", args = { "L" } }, {})
				vim.keymap.set("n", "q", ":q<cr>", { buffer = 0 })
			end
		end,
	})

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("Prose", {}),
		pattern = { "gitcommit", "markdown" },
		callback = function()
			vim.opt_local.spell = true
			vim.opt_local.wrap = true
			vim.opt_local.linebreak = true
			vim.opt_local.conceallevel = 2
		end,
	})
end
