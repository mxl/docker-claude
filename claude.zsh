# Claude Code — sandboxed Docker launcher
# Add to your ~/.zshrc:  source /path/to/claude.zsh
# Or copy-paste the function directly.

claude() {
  local project_name
  project_name="$(basename "$(pwd)")"

  # Ensure ~/.claude.json exists on host to avoid Docker creating it as a directory
  touch "${HOME}/.claude.json"

  local ssh_args=()
  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS: Docker Desktop runs in a VM so host SSH_AUTH_SOCK is inaccessible.
    # Use the special passthrough socket provided by Docker Desktop instead.
    local socket=/run/host-services/ssh-auth.sock
    local socket_gid
    socket_gid=$(docker run --rm -v "${socket}:${socket}" node:20-bookworm-slim \
      stat -c '%g' "${socket}" 2>/dev/null || true)
    ssh_args=(-v "${socket}:/ssh-agent" -e SSH_AUTH_SOCK=/ssh-agent)
    [[ -n "$socket_gid" ]] && ssh_args+=(--group-add "$socket_gid")
  elif [[ -n "${SSH_AUTH_SOCK:-}" && -S "${SSH_AUTH_SOCK}" ]]; then
    local socket_gid
    socket_gid=$(stat -c '%g' "${SSH_AUTH_SOCK}" 2>/dev/null || true)
    ssh_args=(-v "${SSH_AUTH_SOCK}:/ssh-agent" -e SSH_AUTH_SOCK=/ssh-agent)
    [[ -n "$socket_gid" ]] && ssh_args+=(--group-add "$socket_gid")
  else
    echo "Warning: SSH_AUTH_SOCK not set or not a socket — SSH agent forwarding disabled"
  fi

  docker run --rm -it \
    --name "claude-${project_name}-$$" \
    -v "${HOME}/.claude:/home/node/.claude" \
    -v "${HOME}/.gitconfig:/home/node/.gitconfig:ro" \
    -v "${HOME}/.ssh/known_hosts:/home/node/.ssh/known_hosts:ro" \
    -v "${HOME}/.claude.json:/home/node/.claude.json" \
    -v "$(pwd):/home/node/${project_name}" \
    -w "/home/node/${project_name}" \
    "${ssh_args[@]}" \
    claude-code-sandbox \
    --dangerously-skip-permissions "$@"
}
