# Usage message shown when -h flag is used.
usage() {
  message=$(
    cat <<EOF
Remember to set PROJECT_ROOT.
Otherwise, sessionizer falls back to HOME.
EOF
  )
  echo "$message"
}

#TODO: allow overriding PROJECT_ROOT with a command flag.
while getopts 'h' opt; do
  case "$opt" in
  h)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 1
    ;;
  esac
done

# TODO: check whether PROJECTS is a directory.
# Similarly, check whether HOME as fallback is a directory.
# Exit 1 otherwise.

# Check whether Project root is set. Fall back to HOME otherwise.
if [[ -v PROJECT_ROOT ]]; then
  PROJECTS=$PROJECT_ROOT
else
  PROJECTS=$HOME
fi

# Display selection differently based on run within a tmux session or not.
if [[ -v TMUX ]]; then
  selected=$(fd . -t d -d 1 "$PROJECTS" | fzf --tmux)
else
  selected=$(fd . -t d -d 1 "$PROJECTS" | fzf --height 40% --layout reverse --border)
fi

# Based on project selection create a sanitized name for tmux session.

# Full paths
clean_path=$(realpath "$selected")

# Select name for session
selected_name=$(basename "$selected")

# Sanitize session name
selected_name=''${selected_name//[^a-zA-Z0-9_.-]/_}

# Spin up or attach to existing tmux session.
if [[ -v TMUX ]]; then
  if tmux has-session -t="$selected_name" 2>/dev/null; then
    tmux switch-client -t "$selected_name"
    clear
  else
    tmux new-session -A -s "$selected_name" -c "$clean_path" -d
    tmux switch-client -t "$selected_name"
    clear
  fi
else
  tmux new-session -A -s "$selected_name" -c "$clean_path"
  clear
fi
