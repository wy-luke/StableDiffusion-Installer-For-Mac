#! /bin/bash

echo "开始安装 Stable Diffusion WebUI"
echo "如果安装失败请重试一次"

echo "############ Check and install Homebrew ##############"
# Homebrew: The missing package manager for macOS
# More: https://brew.sh/
if ! command -v brew &>/dev/null; then
    # TODO: Force install without confirmation
    echo "请下面按照提示，按回车键"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew already installed."
fi
echo

echo "############ Check and install micromamba ############"
# About mamba: A super fast Python package and environment manager (compared to conda)
# About mamba: A tiny version of the mamba. No base environment nor a default version of Python
# More: https://mamba.readthedocs.io/en/latest/index.html
if ! command -v micromamba &>/dev/null; then
    # Install micromamba
    brew install micromamba
    # Init micromamba
    micromamba shell init -s bash -p ~/micromamba
    source ~/.bash_profile
    source ~/.bashrc
    # Config micromamba, add default channels.
    micromamba config append channels conda-forge
    micromamba config append channels nodefaults
    micromamba config set channel_priority strict
else
    echo "micromamba already installed."
fi
echo

echo "############ Check and install Git ###################"
# Git: A free and open source distributed version control system
# More: https://git-scm.com/
if ! command -v git &>/dev/null; then
    brew install git
else
    echo "Git already installed."
fi
echo

echo "############ Download code ###########################"
# Check if SD's folder exits
if [ ! -d "stable-diffusion-webui" ]; then
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
else
    echo "Code already downloaded."
fi
# Enter the SD's folder
cd stable-diffusion-webui
echo

echo "############ Create virtual env ######################"
# Activate micromamba in current shell
export MAMBA_ROOT_PREFIX="~/micromamba" # Optional
eval "$(micromamba shell hook -s posix)"

# TODO: Check if the env exits
#if micromamba env list | grep ".*sd.*" >/dev/null 2>&1; then
micromamba create -n sd python=3.10.6
#fi
micromamba activate sd
# Activate pyvenv to update pip to avoid some errors
python -m venv venv
source venv/bin/activate
pip install --upgrade pip
# Delete pip cache to avoid some errors
pip cache purge

# Install Stable Diffusion
./webui.sh
