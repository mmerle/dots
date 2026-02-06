return {
  filetypes = { 'lua' },
  settings = {
    Lua = {
      telemetry = {
        enable = false
      },
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = {
          'vim',
          'require',
          'hs',
        },
      },
    },
  },
}
