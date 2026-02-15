#!/usr/bin/env bash

tmp="$(mktemp -t "yazi-chooser-XXXXXX")"
trap 'rm -f "$tmp"' EXIT

yazi "$2" --chooser-file="$tmp"
zellij action toggle-floating-panes

if [[ -s "$tmp" ]]; then
	paths=$(while IFS= read -r line || [[ -n "$line" ]]; do printf "%q " "$line"; done < "$tmp")
	zellij action write 27 # send <Escape> key
	zellij action write-chars ":$1 $paths"
	zellij action write 13 # send <Enter> key
fi
