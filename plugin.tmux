#!/usr/bin/env zsh

CURRENT_DIR="$(cd "$( dirname "${(%):-%x}" )" && pwd)"

REQUIRED_BINARIES=("bw" "fzf" "jq")

main() {
  for binary in "${REQUIRED_BINARIES[@]}"; do
    command -v "$binary" &> /dev/null
    if [[ ! $? -eq 0 ]]; then
      echo "nein"
      tmux display-message -d 5000 "tmux-bw ${binary} does not exist, please install"
      return 1
    fi
  done

  key=${$(tmux show-option -gqv "@bw-key"):-"b"}
  tmux bind-key $key split-window -l 10 "$CURRENT_DIR/scripts/tmux-macos-bw.zsh"
}

main "$@"
