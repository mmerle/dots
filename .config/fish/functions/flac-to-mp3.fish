function flac-to-mp3
    for i in *.flac
        ffmpeg -i "$i" -ab 320k (string replace -r '\.flac$' '.mp3' "$i")
    end
end
