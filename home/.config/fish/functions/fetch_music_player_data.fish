function fetch_music_player_data
    playerctl -a metadata --format "{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"<i><span color='#a6da95'>{{playerName}}</span></i>: <b><span color='#f5a97f'>{{artist}}</span> - <span color='#c6a0f6'>{{markup_escape(title)}}</span></b>\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}" -F
end