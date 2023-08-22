#! /bin/bash

echo "开始安装 Stable Diffusion web UI ......"

# Define a function to handle errors
function handle_error {
    echo "An error occurred"
    read -p "Do you want to retry? [y/n] " choice
    if [[ $choice == [yY] ]]; then
        # Retry the command
        $last_command
    else
        # Exit the script
        exit 1
    fi
}
# Set the error handler
trap 'handle_error' ERR

echo "############ Check and install Homebrew ##############"
# Homebrew: The missing package manager for macOS
# More: https://brew.sh/
if ! command -v brew &>/dev/null; then
    # TODO: Force install without confirmation
    # echo "请下面按照提示，按回车键"
    if curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o install.sh && [ -s install.sh ]; then
        yes | /bin/bash install.sh
        if [ $? -eq 0 ]; then
            echo "Homebrew has been installed successfully"
        else
            echo "Failed to install Homebrew"
            exit 1
        fi
    else
        echo "Homebrew 安装文件下载失败，请检查网络连接"
        echo "Failed to download Homebrew installation script, please check your network connection"
        exit 1
    fi
else
    echo "Homebrew has already been installed"
fi
echo

echo "############ Check and install micromamba ############"
# About mamba: A super fast Python package and environment manager (compared to conda)
# About micromamba: A tiny version of the mamba. No base environment nor a default version of Python
# More: https://mamba.readthedocs.io/en/latest/index.html
if ! command -v micromamba &>/dev/null; then
    # Install micromamba
    brew install micromamba
    # Init micromamba
    micromamba shell init -s bash -p ~/micromamba
    source ~/.bash_profile
    source ~/.bashrc
    # Set default channels for micromamba
    micromamba config append channels conda-forge
    micromamba config append channels nodefaults
    micromamba config set channel_priority strict
    echo "micromamba has been installed successfully"
else
    echo "micromamba has already been installed"
fi
echo

echo "############ Check and install Git ###################"
# Git: A free and open source distributed version control system
# More: https://git-scm.com/
if ! command -v git &>/dev/null; then
    brew install git
    echo "Git has been installed successfully"
else
    echo "Git has already been installed"
fi
echo

echo "############ Download code ###########################"
# Check if stable-diffusion-webui's folder exits
if [ ! -d "stable-diffusion-webui" ]; then
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
    echo "Code has been installed successfully"
else
    echo "Code has already been downloaded"
fi
# Enter the SD's folder
cd stable-diffusion-webui
echo

echo "############ Create virtual env ######################"
# Activate micromamba in current shell
export MAMBA_ROOT_PREFIX="~/micromamba" # Optional, use default value
eval "$(micromamba shell hook -s posix)"

# Check if the env exits
if micromamba env list | grep sd >/dev/null; then
    echo "The sd env already exists"
else
    micromamba create -n sd python=3.10.6
    echo "The sd env has been created successfully"
fi
# Activate sd env
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
