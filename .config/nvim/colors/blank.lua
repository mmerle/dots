vim.cmd('hi clear')

if 1 == vim.fn.exists('syntax_on') then
  vim.cmd('syntax reset')
end

vim.opt.termguicolors = true
vim.g.colors_name = 'blank'

local variants = {
  light = {
    error = '#e94b2e',
    warn = '#eba91f',
    hint = '#5288f7',
    info = '#2aac64',
    accent = '#e087af',
    other = '#a9cee4',
    on_accent = '#faf4ed',
    b_low = '#faf4ed',
    b_med = '#fffaf3',
    b_high = '#f2e9e1',
    f_low = '#9893a5',
    f_med = '#797593',
    f_high = '#575279',
    none = 'NONE',
  },
  dark = {
    error = '#e94b2e',
    warn = '#eba91f',
    hint = '#5288f7',
    info = '#2aac64',
    accent = '#e087af',
    other = '#a9cee4',
    on_accent = '#101010',
    b_low = '#101010',
    b_med = '#151515',
    b_high = '#1e1e1e',
    f_low = '#525252',
    f_med = '#837e7e',
    f_high = '#eeeeee',
    none = 'NONE',
  },
}

-- Set palette based on variant
local p = vim.o.background == 'light' and variants.light or variants.dark

local h = function(group, color)
  return vim.api.nvim_set_hl(0, group, color)
end

p.error = vim.g.un_error or p.error
p.warn = vim.g.un_warn or p.warn
p.hint = vim.g.un_hint or p.hint
p.info = vim.g.un_info or p.info
p.on_accent = vim.g.un_on_accent or p.on_accent
p.accent = vim.g.un_accent or p.accent
p.b_low = vim.g.un_b_low or p.b_low
p.b_med = vim.g.un_b_med or p.b_med
p.b_high = vim.g.un_b_high or p.b_high
p.f_low = vim.g.un_f_low or p.f_low
p.f_med = vim.g.un_f_med or p.f_med
p.f_high = vim.g.un_f_high or p.f_high

--- Interface

h('ColorColumn', { bg = p.b_med })
h('CurSearch', { link = 'IncSearch' })
h('CursorColumn', { bg = p.b_med })
h('CursorLine', { bg = p.b_med })
h('CursorLineNr', { fg = p.f_high })
h('ErrorMsg', { fg = p.error })
h('IncSearch', { bg = p.accent, fg = p.on_accent })
h('LineNr', { fg = p.f_low })
h('MatchParen', { bg = p.accent, fg = p.on_accent })
h('NonText', { fg = p.f_low })
h('Normal', { bg = p.b_low, fg = p.f_high })
h('Pmenu', { bg = p.b_med, fg = p.f_med })
h('PmenuSbar', { bg = p.b_high })
h('PmenuSel', { bg = p.b_high, fg = p.f_high })
h('PmenuThumb', { bg = p.f_low })
h('Question', { fg = p.f_med })
h('Search', { bg = p.b_high })
h('SignColumn', { bg = p.b_low })
h('StatusLine', { bg = p.b_med, fg = p.f_med })
h('Title', { fg = p.f_high })
h('VertSplit', { fg = p.b_med })
h('Visual', { bg = p.b_high })
h('WarningMsg', { fg = p.warn })
h('WinSeperator', { link = 'VertSplit' })

--- Syntax

h('Boolean', { fg = p.info })
h('Character', { fg = p.f_low })
h('Comment', { fg = p.f_low, italic = true })
h('Conditional', { fg = p.accent })
h('Constant', { fg = p.f_med })
h('Debug', { fg = p.f_low })
h('Define', { fg = p.f_low })
h('Delimiter', { fg = p.f_low })
h('Directory', { fg = p.f_med })
h('Error', { fg = p.error })
h('Exception', { fg = p.f_low })
h('Float', { fg = p.f_low })
h('Function', { fg = p.error })
h('FoldColumn', { fg = p.error })
h('Folded', { fg = p.f_med })
h('Identifier', { fg = p.f_med })
h('Include', { fg = p.hint })
h('Keyword', { fg = p.hint })
h('Label', { fg = p.f_high })
h('Macro', { fg = p.f_low })
h('Number', { fg = p.hint })
h('Operator', { fg = p.hint })
h('PreCondit', { fg = p.f_med })
h('PreProc', { fg = p.f_med })
h('Repeat', { fg = p.f_low })
h('Special', { fg = p.f_low })
h('SpecialChar', { link = 'Special' })
h('SpecialComment', { link = 'Special' })
h('SpecialKey', { link = 'Special' })
h('Statement', { fg = p.f_high })
h('StorageClass', { fg = p.f_low })
h('String', { fg = p.info })
h('Structure', { fg = p.f_low })
h('Tag', { fg = p.f_med })
h('Todo', { fg = p.f_low })
h('Type', { fg = p.f_high })
h('Typedef', { fg = p.f_low })

--- Treesitter syntax

h('TSBoolean', { link = 'Boolean' })
h('TSConstant', { link = 'Constant' })
h('TSConstructor', { fg = p.f_med })
h('TSField', { fg = p.f_low })
h('TSFunction', { link = 'Function' })
h('TSInclude', { link = 'Include' })
h('TSKeyword', { link = 'Keyword' })
h('TSLabel', { link = 'Label' })
h('TSMethod', { fg = p.f_med })
h('TSNote', { fg = p.accent })
h('TSNumber', { link = 'Number' })
h('TSParameter', { fg = p.f_high })
h('TSProperty', { link = 'TSField' })
h('TSPunctBracket', { fg = p.f_low })
h('TSPunctDelimiter', { link = 'Delimiter' })
h('TSPunctSpecial', { link = 'Special' })
h('TSString', { link = 'String' })
h('TSStringEscape', { link = 'String' })
h('TSTag', { link = 'Tag' })
h('TSTagDelimiter', { link = 'Delimiter' })
h('TSText', { fg = p.f_high })
h('TSTitle', { link = 'Title' })
h('TSType', { link = 'Type' })
h('TSURI', { link = 'String' })
h('TSVariable', { fg = p.f_high })
h('TSVariableBuiltin', { link = 'TSVariable' })
h('TSWarning', { fg = p.warn })

h('@constructor', { fg = p.other })
h('@parameter', { fg = p.warn })
h('@property', { fg = p.other })
h('@tag', { fg = p.other, italic = false })
h('@tag.attribute', { fg = p.accent })
h('@type', { fg = p.f_high, italic = true })
h('@function', { fg = p.error })
h('@number', { fg = p.accent })
h('@text', { fg = p.f_high })
h('@type.definition', { fg = p.warn })
h('@variable', { fg = p.f_high, italic = true })
h('@conditional.ternary', { link = 'Operator' })

-- h('@variablebuiltin', { fg = p.warn, italic = true })

--- Diagnostics

h('DiagnosticError', { fg = p.error })
h('DiagnosticHint', { fg = p.hint })
h('DiagnosticInfo', { fg = p.info })
h('DiagnosticWarn', { fg = p.warn })
h('DiagnosticUnderlineError', { undercurl = true, sp = p.error })
h('DiagnosticUnderlineHint', { undercurl = true, sp = p.hint })
h('DiagnosticUnderlineInfo', { undercurl = true, sp = p.info })
h('DiagnosticUnderlineWarn', { undercurl = true, sp = p.warn })

--- Plugins

-- gitsigns.nvim
h('SignAdd', { fg = p.info })
h('SignChange', { fg = p.warn })
h('SignDelete', { fg = p.error })
h('GitSignsAdd', { link = 'SignAdd' })
h('GitSignsChange', { link = 'SignChange' })
h('GitSignsDelete', { link = 'SignDelete' })

-- indent-blankline.nvim
h('IndentBlanklineChar', { fg = p.b_high })

-- barbar.nvim
h('BufferTabPageFill', { bg = p.b_low })
h('BufferCurrent', { fg = p.f_high, bg = p.b_med, italic = true })
h('BufferCurrentIndex', { fg = p.f_high, bg = p.b_med })
h('BufferCurrentMod', { fg = p.warn, bg = p.b_med })
h('BufferCurrentSign', { fg = p.f_low, bg = p.b_med })
h('BufferInactive', { fg = p.f_low })
h('BufferInactiveIndex', { fg = p.f_low })
h('BufferInactiveMod', { fg = p.info })
h('BufferInactiveSign', { fg = p.f_low })
h('BufferVisible', { link = 'BufferInactive' })
h('BufferVisibleIndex', { link = 'BufferInactiveIndex' })
h('BufferVisibleMod', { link = 'BufferInactiveMod' })
h('BufferVisibleSign', { link = 'BufferInactiveSign' })

-- nvim-tree.lua
h('NvimTreeSpecialFile', { link = 'Normal' })
h('NvimTreeFolderName', { fg = p.f_med, bold = true })
h('NvimTreeEmptyFolderName', { fg = p.f_low, bold = true })
h('NvimTreeOpenedFolderName', { bold = true, italic = true })
h('NvimTreeOpenedFile', { fg = p.f_high })

h('NvimTreeNormal', { fg = p.f_med })
h('NvimTreeSymlink', { fg = p.f_med, italic = true })
h('NvimTreeFolderIcon', { fg = p.f_med })

h('NvimTreeGitNew', { link = 'SignAdd' })
h('NvimTreeGitDirty', { link = 'SignChange' })
h('NvimTreeGitDeleted', { link = 'SignDelete' })
h('NvimTreeGitStaged', { fg = p.hint })
h('NvimTreeGitRenamed', { fg = p.accent })

-- telescope.nvim
h('TelescopeBorder', { fg = p.f_low })
h('TelescopeMatching', { fg = p.accent })
h('TelescopeNormal', { fg = p.f_low })
h('TelescopeTitle', { fg = p.f_low })
h('TelescopeSelection', { fg = p.f_high, bg = p.b_high })
h('TelescopePromptNormal', { fg = p.f_high })
h('TelescopePromptPrefix', { fg = p.f_med })

-- nvim-cmp
h('CmpItemKind', { fg = p.accent })
h('CmpItemAbbr', { fg = p.f_med })
h('CmpItemAbbrMatch', { fg = p.f_high, bold = true })
h('CmpItemAbbrMatchFuzzy', { link = 'CmpItemAbbrMatch' })
h('CmpItemAbbrDeprecated', { fg = p.f_low, strikethrough = true })
h('CmpItemKindVariable', { fg = p.other })
h('CmpItemKindClass', { fg = p.warn })
h('CmpItemKindInterface', { fg = p.warn })
h('CmpItemKindFunction', { fg = p.hint })
h('CmpItemKindMethod', { fg = p.hint })
h('CmpItemKindSnippet', { fg = p.hint })
