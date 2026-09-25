#!/bin/bash

set -u

# Paths installed by sd-installer.sh
sd_path="$HOME/stable-diffusion-webui"
mamba_env_path="$HOME/micromamba/envs/sd"
tmp_path="$HOME/.sd-installer"

function echo_green {
    echo -e "\033[32m$1\033[0m"
}

function echo_red {
    echo -e "\033[31m$1\033[0m"
}

echo "############ Uninstall Stable Diffusion web UI #########"
echo
echo "The following paths will be removed:"
echo "  $sd_path"
echo "  $mamba_env_path"
echo "  $tmp_path"
echo
echo "Note: Homebrew and the packages installed by it will not be removed."
echo
read -rp "Are you sure you want to uninstall? [y/N] " uninstall_choice
uninstall_choice=${uninstall_choice:-n}

if [[ $uninstall_choice == [yY] ]]; then
    rm -rf "$sd_path" "$mamba_env_path" "$tmp_path"
    echo_green "Stable Diffusion web UI has been uninstalled successfully"
else
    echo_red "Uninstallation cancelled"
    exit 0
fi
