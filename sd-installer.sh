#! /bin/bash

set -u

echo "开始安装 Stable Diffusion web UI ......"

root_path=$(pwd)

# Define a function to handle errors
function handle_error {
    echo_red "安装失败，是否重试？"
    read -rp "Installation failed, do you want to retry? [y/n] " choice
    if [[ $choice == [yY] ]]; then
        # Retry the command
        bash "$root_path/sd-installer.sh"
    else
        # Exit the script
        exit 1
    fi
}
# Set the error handler
trap 'handle_error' ERR

function verify_installation {
    if [ $? -eq 0 ] && command -v $1 &>/dev/null; then
        echo_green "$1 has been installed successfully"
    else
        echo_red "Failed to install $1"
        exit 1
    fi
}

function echo_green {
    echo -e "\033[32m$1\033[0m"
}

function echo_red {
    echo -e "\033[31m$1\033[0m"
}

echo "############ Check and install Homebrew ##############"
# Homebrew: The missing package manager for macOS
# More: https://brew.sh/
eval "$(/opt/homebrew/bin/brew shellenv)"
if ! command -v brew &>/dev/null; then
    if curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o install_brew.sh && [ -f $root_path/install_brew.sh ]; then
        chmod +x "$root_path/install_brew.sh"
        yes | /bin/bash -c "$root_path/install_brew.sh"
        eval "$(/opt/homebrew/bin/brew shellenv)"
        verify_installation brew
    else
        echo_red "Homebrew 安装文件下载失败，请检查网络连接"
        echo_red "Failed to download Homebrew installation script, please check your network connection"
        exit 1

    fi
else
    echo_green "Homebrew has already been installed"
fi

echo

echo "############ Check and install micromamba ############"
# About mamba: A super fast Python package and environment manager (compared to conda)
# About micromamba: A tiny version of the mamba. No base environment nor a default version of Python
# More: https://mamba.readthedocs.io/en/latest/index.html
export MAMBA_ROOT_PREFIX="~/micromamba" # Optional, use default value
eval "$(/opt/homebrew/bin/micromamba shell hook -s bash)"
if ! command -v micromamba &>/dev/null; then
    # Install micromamba
    brew install micromamba
    # Activate micromamba in current shell
    eval "$(/opt/homebrew/bin/micromamba shell hook -s bash)"
    verify_installation micromamba
    # # Init micromamba
    # micromamba shell init -s bash -p ~/micromamba
    # if [ -f ~/.profile ]; then
    #     source ~/.profile
    # fi
    # if [ -f ~/.bash_profile ]; then
    #     source ~/.bash_profile
    # fi
    # if [ -f ~/.bashrc ]; then
    #     source ~/.bashrc
    # fi
    # Set default channels for micromamba
    micromamba config append channels conda-forge
    micromamba config append channels nodefaults
    micromamba config set channel_priority strict

    echo_green "micromamba has been configed"
else
    echo_green "micromamba has already been installed"
fi
echo

echo "############ Check and install Git ###################"
# Git: A free and open source distributed version control system
# More: https://git-scm.com/
if ! command -v git &>/dev/null; then
    brew install git
    verify_installation git
else
    echo_green "Git has already been installed"
fi
echo

echo "############ Download code ###########################"
# Check if stable-diffusion-webui's folder exits
if [ ! -d "stable-diffusion-webui" ]; then
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
    echo_green "Code has been installed successfully"
else
    echo_green "Code has already been downloaded"
fi
# Enter the SD's folder
cd stable-diffusion-webui
echo

echo "############ Create virtual env ######################"
# Check if the env exits
if micromamba env list | grep sd >/dev/null; then
    echo_green "The sd env already exists"
else
    yes | micromamba create -n sd python=3.10.6
    echo_green "The sd env has been created successfully"
fi
# Activate sd env
echo_green "Activate sd env"
micromamba activate sd
# Activate pyvenv to update pip to avoid some errors
python -m venv venv
source venv/bin/activate
pip install --upgrade pip
# Delete pip cache to avoid some errors
pip cache purge

# Install Stable Diffusion
echo "开始安装 Stable Diffusion"
echo "Start to install Stable Diffusion"
./webui.sh
