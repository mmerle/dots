function update
    ~
    and echo "[update] Homebrew"
    and brew update
    and brew upgrade

    and echo "[update] Cleaning Homebrew cache"
    and brew cleanup -s

    and echo "[update] Global packages"
    and pnpm update -g

    and echo "[update] Fish plugins"
    and fisher update

    and echo "[update] Mac App Store"
    and fisher update
end
