#!/usr/bin/env bash

# Ensure we're in the Nix shell
if [ -z "$IN_NIX_SHELL" ]; then
    echo "Launching VS Code through Nix shell..."
    nix develop -c bash -c "code-dev $*"
else
    echo "Launching VS Code..."
    code-dev "$@"
fi
