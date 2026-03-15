# Claude Code Sandbox

Runs Claude Code with `--dangerously-skip-permissions` in an isolated Docker environment.

## Host setup

### 1. Install dependencies

```zsh
# Docker Desktop
brew install --cask docker
```

### 2. Add the claude alias

Add to your `~/.zshrc`:

```zsh
source ~/Documents/projects/docker-claude/claude.zsh

# Auto-add SSH key to agent on shell start
ssh-add ~/.ssh/id_ed25519 2>/dev/null
```

Then reload:

```zsh
source ~/.zshrc
```

### 3. Prepare host files

```zsh
# Ensure ~/.claude.json exists as a file (Docker will create it as a directory otherwise)
touch ~/.claude.json

# Add GitHub to known_hosts (prevents SSH host key verification errors)
mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts
```

### 4. Build the image

```zsh
docker compose build
```

## Usage

Run `claude` from any project directory:

```zsh
cd ~/my-project
claude                          # interactive session
claude "add OpenAPI docs"       # pass a prompt directly
```

The project directory is mounted at `/home/node/<project-name>` inside the container.

## What gets mounted

| Host | Container | Notes |
|------|-----------|-------|
| `~/.claude/` | `/home/node/.claude` | Auth tokens and Claude config |
| `~/.claude.json` | `/home/node/.claude.json` | Claude settings file |
| `~/.gitconfig` | `/home/node/.gitconfig` | Git user.name, user.email, aliases (read-only) |
| `~/.ssh/known_hosts` | `/home/node/.ssh/known_hosts` | SSH host keys (read-only) |
| `$(pwd)` | `/home/node/<project-name>` | Current project |
| SSH agent socket | `/ssh-agent` | Via Docker Desktop passthrough (macOS) |

## SSH agent forwarding

On macOS, SSH agent forwarding uses Docker Desktop's passthrough socket at `/run/host-services/ssh-auth.sock`. Make sure your key is loaded in the agent (`ssh-add -l`) before running `claude`.

On Linux, the standard `$SSH_AUTH_SOCK` is used directly.
