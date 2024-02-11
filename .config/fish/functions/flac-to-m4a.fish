for file in *.flac
    set output_filename (echo "$file" | sed 's/.flac/.m4a/')
    ffmpeg -i "$file" -c:a aac -b:a 256k "$output_filename"
end
