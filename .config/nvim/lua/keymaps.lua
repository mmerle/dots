local opts = { silent = true }

vim.g.mapleader = " "

-- move through wrapped lines
vim.keymap.set({ "n", "v" }, "j", "gj", opts)
vim.keymap.set({ "n", "v" }, "k", "gk", opts)

vim.keymap.set("v", "<", "<gv", opts) -- unindent (keep selection)
vim.keymap.set("v", ">", ">gv", opts) -- indent (keep selection)

vim.keymap.set("n", "H", "^", opts) -- jump to first character of line
vim.keymap.set("n", "L", "g_", opts) -- jump to last character of line

-- quick actions
vim.keymap.set("n", "<leader>s", "<cmd>w<cr>", { desc = "Write file" }, opts) -- quick save
vim.keymap.set("n", "<leader>S", "<cmd>wall<cr>", { desc = "Write all files" }, opts) -- quick save all buffers
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit instance" }, opts) -- quick quit

-- search
vim.keymap.set("n", "<esc>", "<cmd>noh<cr>", opts) -- clear search highlights
vim.keymap.set("n", "*", "*N", opts) -- search word under cursor (keep position)
vim.keymap.set("v", "*", [[y/\V<c-r>=escape(@",'/\')<cr><cr>N]], opts) -- search selection (keep position)
-- vim.keymap.set('n', 'S', ':%s/<c-r><c-w>//g<left><left>', { silent = false }) -- replace selection

-- block movement
vim.keymap.set("n", "J", ":m .+1<cr>==", opts)
vim.keymap.set("n", "K", ":m .-2<cr>==", opts)
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", opts)
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", opts)

-- center vertical movement
vim.keymap.set("n", "<c-d>", "<c-d>zz", opts)
vim.keymap.set("n", "<c-u>", "<c-u>zz", opts)

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- window
vim.keymap.set("n", "<c-h>", "<c-w><c-h>", opts) -- jump to split left
vim.keymap.set("n", "<c-j>", "<c-w><c-j>", opts) -- jump to split below
vim.keymap.set("n", "<c-k>", "<c-w><c-k>", opts) -- jump to split above
vim.keymap.set("n", "<c-l>", "<c-w><c-l>", opts) -- jump to split right
vim.keymap.set("n", "<c-r>", "<c-w><c-r>", opts) -- swap split positions

-- goto
vim.keymap.set("n", "go", "<c-o>", { desc = "Goto previous position" }, opts) -- goto previous position
vim.keymap.set("n", "gm", "%", { desc = "Goto matching pair" }, opts) -- goto matching character: '()', '{}', '[]'

-- inspect syntax highlighting
vim.keymap.set("n", "<leader>i", "<cmd>Inspect<cr>", opts)
