#!/usr/bin/env bash

is_authenticated() {
  # return 0 if authenticated, 1 otherwise
  [[ $(bw status | jq ".status") != "\"unauthenticated\"" ]] && true
}

is_unlocked() {
  # return 0 when vault is unlocked, 1 otherwise
  [[ $(bw status | jq ".status") == "\"unlocked\"" ]] && true
}

get_password() {
  local items=$1
  local key=$2

  password=$(echo "$items" | jq ".\"$key\"")
  echo $password | cut -d'"' -f2
}

main() {
  # if there exists a session token, export it
  # if it has expired we fail the is_unlocked check
  session=$(tmux show-option -gqv "@bw-session")
  export BW_SESSION="$session"

  if ! is_authenticated; then
    session=$(bw login | grep -o '"[^"]*"' | cut -d'"' -f2 |head -n1 2>/dev/null)
  elif ! is_unlocked; then
    session=$(bw unlock | grep -o '"[^"]*"' | cut -d'"' -f2 | head -n1 2>/dev/null)
  fi

  if [[ -n $session ]]; then
    tmux set-option -g "@bw-session" "$session"
  fi

  items=$(bw list items --session "$session" | jq -r "map({ (.name|tostring): .login.password })|add")
  key=$(echo "$items" | jq --raw-output '.|keys[]' | fzf --no-multi) || return
  password=$(get_password "$items" "$key")
  tmux send-keys -t ! "$password"
}

main "$@"
