function update
    ~
    echo "[update] Homebrew"
    brew update
    brew upgrade

    echo "[update] Cleaning Homebrew cache"
    brew cleanup -s

    echo "[update] Global packages"
    pnpm update -g

    echo "[update] Mac App Store"
    mas upgrade
end
