# Usage message shown when -h flag is used.
usage() {
  message=$(
    cat <<EOF
Remember to set PROJECT_ROOT (needs to be a directory).
Otherwise, sessionizer falls back to HOME.
EOF
  )
  echo "$message"
}

preview_helper() {
  # fzf selected dir
  local dir="$1"

  # find readme file
  local readme
  readme=$(find "$dir" -maxdepth 1 -type f -iname 'README.*' | head -n1)

  # if readme, bat it
  if [[ -n "$readme" ]]; then
    bat --style=plain --color=always "$readme"
  else
    echo "No readme :("
  fi
}

# Make the helper available in sub-processes (sub-shell spawning fzf)
export -f preview_helper

while getopts 'hnp' opt; do
  case "$opt" in
  h)
    usage
    exit 0
    ;;
  n)
    # TODO: add functionality to create new dir for new project
    echo "Would you like to create a new directory?"
    exit 1 # not implemented yet. exit
    ;;
  p)
    #TODO: allow overriding PROJECT_ROOT with a command flag.
    echo "wanna override PROJECT_ROOT?"
    exit 1 # not implemented yet. exit
    ;;
  *)
    usage >&2
    exit 1
    ;;
  esac
done

# TEST: add unit tests

# Check whether Project root is set. Fall back to HOME otherwise.
# Exit 1 if neither is set.
if [[ -v PROJECT_ROOT ]]; then
  PROJECTS=$PROJECT_ROOT
elif [[ -v HOME ]]; then
  PROJECTS=$HOME
else
  usage >&2
  exit 1
fi

# TEST: add unit tests

# Similarly, check whether HOME as fallback is a directory.
# Exit 1 otherwise.
if [[ ! -d "$PROJECTS" ]]; then
  usage >&2
  exit 1
fi

# TODO: enable adding multiple project dirs
# add logic to create new dir if not exist (for n flag)
# NOTE: PROJECTS_LIST returns a string with each project folder seperated by a new line
PROJECTS_LIST=$(fd . -t d -d 1 "$PROJECTS")

# Display selection differently based on run within a tmux session or not.
# manually invoke bash with preview, to make sure exported helper works
# TODO: add display flavour (maybe only display basename or highlight it)
if [[ -v TMUX ]]; then
  selected=$(echo "$PROJECTS_LIST" | fzf --tmux --preview 'bash -c "preview_helper {}"')
else
  selected=$(echo "$PROJECTS_LIST" | fzf --height 40% --layout reverse --border --preview 'bash -c "preview_helper {}"')
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
