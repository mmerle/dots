const directions = [
  { name: "tmux.navigate.left", key: "ctrl+h", flag: "-L" },
  {
    name: "tmux.navigate.down",
    key: "ctrl+j",
    flag: "-D",
    modal: "dialog.select.next",
    autocomplete: "prompt.autocomplete.next",
  },
  {
    name: "tmux.navigate.up",
    key: "ctrl+k",
    flag: "-U",
    modal: "dialog.select.prev",
    autocomplete: "prompt.autocomplete.prev",
  },
  { name: "tmux.navigate.right", key: "ctrl+l", flag: "-R" },
]

const tui = async (api) => {
  if (!process.env.TMUX) return

  api.keymap.registerLayer({
    commands: directions.map((direction) => ({
      name: direction.name,
      run() {
        const mode = api.mode.current()
        if (mode === "autocomplete") {
          if (direction.autocomplete) api.keymap.dispatchCommand(direction.autocomplete)
          return
        }
        if (mode === "modal" || api.ui.dialog.open) {
          if (direction.modal) api.keymap.dispatchCommand(direction.modal)
          return
        }
        if (mode !== "base") return

        Bun.spawn(["tmux", "select-pane", direction.flag], {
          stdout: "ignore",
          stderr: "ignore",
        })
      },
    })),
    bindings: directions.map((direction) => ({
      key: direction.key,
      cmd: direction.name,
      desc: `Navigate tmux ${direction.name.split(".").at(-1)}`,
    })),
  })
}

export default {
  id: "tmux-navigator",
  tui,
}
