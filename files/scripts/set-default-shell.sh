#!/usr/bin/bash
set -euo pipefail

# set-default-shell.sh
# Sets zsh as the default shell for root and future new users.
# Uses usermod instead of chsh — chsh (and other setuid account tools)
# are intentionally stripped from Fedora Atomic/Kinoite-based images
# (Aurora included), so chsh is not available even though util-linux
# still owns other files. usermod does not depend on the setuid binary
# and is the supported approach on these images.

ZSH_PATH="/usr/bin/zsh"

if [ ! -x "$ZSH_PATH" ]; then
    echo "zsh not found at $ZSH_PATH — ensure it's installed earlier in the recipe" >&2
    exit 1
fi

# Set root's default shell in the image
usermod --shell "$ZSH_PATH" root

# Make zsh the default for any newly-created user
if [ -f /etc/default/useradd ]; then
    sed -i "s|^SHELL=.*|SHELL=$ZSH_PATH|" /etc/default/useradd
else
    echo "SHELL=$ZSH_PATH" >> /etc/default/useradd
fi

echo "Default shell set to zsh for root and future new users."
