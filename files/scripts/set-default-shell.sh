#!/usr/bin/bash
set -euo pipefail

# set-default-shell.sh
# Sets zsh as the default shell for new users (via /etc/skel-relevant defaults)
# and for root. Does NOT affect existing user accounts on rebase/rebuild —
# /etc/passwd for existing users is preserved by ostree's 3-way /etc merge.

ZSH_PATH="/usr/bin/zsh"

if [ ! -x "$ZSH_PATH" ]; then
    echo "zsh not found at $ZSH_PATH — ensure it's installed earlier in the recipe" >&2
    exit 1
fi

# Set root's default shell in the image
usermod --shell "$ZSH_PATH" root

# Make zsh the default for any newly-created user by updating useradd's default
if [ -f /etc/default/useradd ]; then
    sed -i "s|^SHELL=.*|SHELL=$ZSH_PATH|" /etc/default/useradd
else
    echo "SHELL=$ZSH_PATH" >> /etc/default/useradd
fi

echo "Default shell set to zsh for root and future new users."
