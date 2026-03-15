# Claude Code Sandbox
# Builds from the official Node.js image and installs Claude Code via npm

FROM node:20-bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code globally (as root, before switching user)
RUN npm install -g @anthropic-ai/claude-code

# The node user already exists in the official Node.js image (uid 1000)
# Switch to it for safer execution
USER node

# ~/.claude will be mounted from the host at /home/node/.claude
# This preserves authentication and configuration across container runs

ENTRYPOINT ["claude", "--dangerously-skip-permissions"]
