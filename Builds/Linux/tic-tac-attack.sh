#!/bin/sh
printf '\033c\033]0;%s\a' Tic Tac Attack
base_path="$(dirname "$(realpath "$0")")"
"$base_path/tic-tac-attack.x86_64" "$@"
