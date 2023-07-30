#! /bin/bash

echo "############ Check and install Homebrew ############"
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew already installed."
fi
echo

echo "############ Check and install micromamba ############"
if ! command -v micromamba &>/dev/null; then
    brew install micromamba
    micromamba shell init -s bash -p ~/micromamba
    source ~/.bash_profile
    source ~/.bashrc
    micromamba config append channels conda-forge
    micromamba config append channels nodefaults
    micromamba config set channel_priority strict
else
    echo "micromamba already installed."
fi
echo

echo "############ Check and install Git ############"
if ! command -v git &>/dev/null; then
    brew install git
else
    echo "Git already installed."
fi
echo

echo "############ Download code ############"
# Check if sd folder exits
if [ ! -d "stable-diffusion-webui" ]; then
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
else
    echo "Code already downloaded."
fi
cd stable-diffusion-webui
echo

echo "############ Create virtual env ############"
# Activate micromamba
export MAMBA_ROOT_PREFIX="~/micromamba" # Optional
eval "$(micromamba shell hook -s posix)"

#if micromamba env list | grep ".*sd.*" >/dev/null 2>&1; then
micromamba create -n sd python=3.10.6
#fi
micromamba activate sd
python -m venv venv
source venv/bin/activate
pip install --upgrade pip

# Install sd
./webui.sh
