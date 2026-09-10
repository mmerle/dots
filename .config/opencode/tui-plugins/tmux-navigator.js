import { spawn } from "node:child_process"

import { Plugin } from "@opencode/plugin/tui"

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

export default Plugin.define({
  id: "tmux-navigator",
  setup(context) {
    if (!process.env.TMUX) return

    context.keymap.layer(() => ({
      mode: "global",
      commands: directions.map((direction) => ({
        id: direction.name,
        title: `Navigate tmux ${direction.name.split(".").at(-1)}`,
        bind: direction.key,
        run() {
          const mode = context.keymap.mode.current()
          if (mode === "autocomplete") {
            if (direction.autocomplete) context.keymap.dispatch(direction.autocomplete)
            return
          }
          if (mode === "modal" || mode === "dialog") {
            if (direction.modal) context.keymap.dispatch(direction.modal)
            return
          }
          if (mode !== "base" && mode !== "global") return

          spawn("tmux", ["select-pane", direction.flag], {
            stdio: "ignore",
          })
        },
      })),
    }))
  },
})
