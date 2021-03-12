#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Search for Glyph
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon ↙️
# @raycast.argument1 { "type": "text", "placeholder": "Category", "optional": false }

# @raycast.author mmerle
# @raycast.authorURL https://github.com/mmerle
# @raycast.description Search for glyphs.

if [[ $1 == "arrow" ]]
then
  result="← → ⟵ ⟶ ↖ ↗ ↙ ↘ ↑ ↓ ‹ › « » ↕ ↔ ↰ ↱ ↵ ↳ ↴ ⏎ ⇤ ⇥ ↺ ↻ ↩ ↪" 
elif [[ $1 == "dash" ]]
then
  result="- – ‒ — ―" 
elif [[ $1 == "letter" ]]
then
  result="Ⓐ Ⓑ Ⓒ Ⓓ Ⓔ Ⓕ Ⓖ Ⓗ Ⓘ Ⓙ Ⓚ Ⓛ Ⓜ Ⓝ Ⓞ Ⓟ Ⓠ Ⓡ Ⓢ Ⓣ Ⓤ Ⓥ Ⓦ Ⓧ Ⓨ Ⓩ ⓪ ➀ ➁ ➂ ➃ ➄ ➅ ➆ ➇ ➈ 🄰 🄱 🄲 🄳 🄴 🄵 🄶 🄷 🄸 🄹 🄺 🄻 🄼 🄽 🄾 🄿 🅀 🅁 🅂 🅃 🅄 🅅 🅆 🅇 🅈 🅉" 
elif [[ $1 == "shape" ]]
then
  result="▲ ▼ ◄ ▶ △ ▽ ◅ ▻ ● ○ ■ □ ▢ ⬒ ⬓ ◆ ◇ ❖ ☀ ☼ ♥ ♡ ★ ☆ ✽ ✴ ✶ ✷ ✸ ✪ ✫ ✺ ✻ ⁂ ⁑" 
elif [[ $1 == "key" ]]
then
  result="⌘ ⬆ ⇧ ⌃ ⌥ ⌫ ⌦ ⌧ ⏏ ⎋" 
elif [[ $1 == "math" ]]
then
  result="+ − × ÷ ± ≈ ~ ≤ ≥ ≠" 
fi

echo ${result}
