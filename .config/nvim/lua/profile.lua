local M = {}

local profiles = {
  default = { autoformat = true, indent = 2 },
  work = { autoformat = false, indent = 4 },
}

local profile_names = vim.tbl_keys(profiles)
table.sort(profile_names)

M.name = 'default'

function M.get()
  return profiles[M.name]
end

local function apply_to_buffer(bufnr, profile)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then return end
  if vim.bo[bufnr].buftype ~= '' then return end

  vim.bo[bufnr].tabstop = profile.indent
  vim.bo[bufnr].shiftwidth = profile.indent
  vim.bo[bufnr].softtabstop = profile.indent
  vim.b[bufnr].autoformat = nil
end

function M.apply(name, quiet)
  local profile = profiles[name]
  if not profile then
    vim.notify('Unknown profile: ' .. name, vim.log.levels.ERROR)
    return
  end

  M.name = name
  vim.g.autoformat = profile.autoformat
  vim.opt.tabstop = profile.indent
  vim.opt.shiftwidth = profile.indent
  vim.opt.softtabstop = profile.indent

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    apply_to_buffer(bufnr, profile)
  end

  if not quiet then vim.notify('Profile: ' .. name) end
end

vim.api.nvim_create_user_command('Profile', function(args)
  if args.args == '' then
    vim.notify('Profile: ' .. M.name)
    return
  end

  M.apply(args.args)
end, {
  nargs = '?',
  complete = function()
    return profile_names
  end,
  desc = 'Switch editing profile',
  force = true,
})

M.apply('default', true)

return M
