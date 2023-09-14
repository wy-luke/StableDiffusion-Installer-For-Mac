#! /bin/bash

set -u

# Configurable variables #TODO: Make them configurable
installation_path=$HOME
tmp_path="$HOME/.sd-installer"
mamba_root_path="~/micromamba"
network_connected=true

# Other variables
code_path="$installation_path/stable-diffusion-webui"
brew_installer_path="$tmp_path/brew_installer.sh"

brew_pkg_path="/usr/local"
if [[ $(uname -p) == 'arm' ]]; then
    echo "Apple Silicon"
    brew_pkg_path="/opt/homebrew"
fi
brew_path="$brew_pkg_path/bin/brew"
mamba_path="$brew_pkg_path/opt/micromamba/bin/micromamba"

test_mode=0 # Only for test. 0 for no test, 1 for Network-Connected-Test, 2 for Network-Not-Connected-Test

function clean_up {
    echo "############ Clean ###################################"
    rm -rf $tmp_path
}

function echo_green {
    echo -e "\033[32m$1\033[0m"
}

function echo_red {
    echo -e "\033[31m$1\033[0m"
}

# Define a function to handle errors
function handle_error {
    if [ "$test_mode" != 0 ]; then
        echo_red "测试失败, 不重试"
        exit 1
    fi

    echo_red "安装失败, 是否重试? [y/n] "
    read -rp "Installation failed, do you want to retry? [y/n] " error_choice
    error_choice=${error_choice:-y}
    if [[ $error_choice == [yY] ]]; then
        # Retry the command

        if [ "$network_connected" == false ]; then
            /bin/bash -c "$(curl -fsSL $sd_installer_url)" -c
        else
            /bin/bash -c "$(curl -fsSL $sd_installer_url)"
        fi
    else
        clean_up
        # Exit the script
        exit 1
    fi
}
# Set the error handler
trap 'handle_error' ERR

# Last command succeeded and the command exists
function verify_installation {
    if [ $? -eq 0 ] && command -v $1 &>/dev/null; then
        echo_green "$1 has been installed successfully"
    else
        echo_red "Failed to install $1"
        exit 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
    -test | -t)
        value=${2:1}
        if [ "$value" != 1 ] && [ "$value" != 2 ]; then
            echo_red "未知选项: $1 $2"
            exit 1
        fi
        test_mode=$value
        shift # past argument
        shift # past value
        ;;
    -c)
        network_connected=false
        shift
        ;;
    # -h | --help)
    #     show_help
    #     exit 0
    #     ;;
    *)
        echo_red "未知选项: $1"
        # show_help
        exit 1
        ;;
    esac
done

if [ "$test_mode" != 0 ]; then
    if [ "$test_mode" == 1 ]; then
        network_connected=true
        echo_green "Network-Connected-Test"
    else
        network_connected=false
        echo_green "Network-Not-Connected-Test"
    fi
else
    # echo_green "For non-Chinese users, you could just ignore this and press the Enter key"
    # read -rp "网络是否顺畅? 默认y [y/n] " network_choice
    # network_choice=${network_choice:-y}
    # if [[ $network_choice == [nN] ]]; then
    #     network_connected=false
    #     echo_green "将设置国内镜像源安装, 包括 homebrew、conda-forge、pip、github 等, 但链接可能会不稳定/失效, 若失败可以重试"
    # else
    #     echo_green "网络通畅, 正常安装"
    # fi

    if [ "$network_connected" == false ]; then
        echo_green "将设置国内镜像源安装, 包括 homebrew、conda-forge、pip、github 等, 但链接可能会不稳定或失效, 若安装失败可以重试"
    else
        echo_green "恭喜网络通畅, 正常安装"
    fi
fi

brew_installer_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
sd_installer_url="https://raw.githubusercontent.com/wy-luke/StableDiffusion-Installer-For-Mac/main/sd-installer.sh"
sd_webui_url="https://github.com/AUTOMATIC1111/stable-diffusion-webui.git"

if [ "$network_connected" == false ]; then
    # raw.gitmirror.com 备份
    # brew_installer_url="https://raw.gitmirror.com/Homebrew/install/HEAD/install.sh"
    # sd_installer_url="https://raw.gitmirror.com/wy-luke/StableDiffusion-Installer-For-Mac/main/sd-installer.sh"

    brew_installer_url="https://ghproxy.com/https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    sd_installer_url="https://ghproxy.com/https://raw.githubusercontent.com/wy-luke/StableDiffusion-Installer-For-Mac/main/sd-installer.sh"
    sd_webui_url="https://ghproxy.com/https://github.com/AUTOMATIC1111/stable-diffusion-webui"
fi

echo "############ 开始安装 Stable Diffusion web UI #########" && echo

if [ ! -d $tmp_path ]; then
    mkdir -p $tmp_path
fi

echo "############ Check and install Homebrew ##############"
# Homebrew: The missing package manager for macOS
# More: https://brew.sh/

# Try to activate homebrew first
eval "$($brew_path shellenv)"

if ! command -v brew &>/dev/null; then
    if curl -fsSL $brew_installer_url -o $brew_installer_path && [ -f $brew_installer_path ]; then

        # Grant the permission to install Homebrew
        sudo dseditgroup -o edit -a $(whoami) -t user admin
        sudo dseditgroup -o edit -a $(whoami) -t user wheel

        # Grant the permission to execute the installation script
        chmod +x $brew_installer_path

        if [ "$network_connected" == false ]; then
            export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
            export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
            export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
            export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
        fi

        yes | /bin/bash -c $brew_installer_path
        eval "$($brew_path shellenv)"
        verify_installation brew
    else
        echo_red "Homebrew 安装文件下载失败, 请检查网络连接"
        echo_red "Failed to download Homebrew installation script, please check your network connection"
        exit 1

    fi
else
    echo_green "Homebrew has already been installed"
fi

if [ "$network_connected" == false ]; then
    export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
    export HOMEBREW_PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
fi
brew update

echo_green "Install the packages required"
brew install cmake protobuf rust git wget
# brew install --cask cmake

echo

echo "############ Check and install micromamba ############"
# About mamba: A super fast Python package and environment manager (compared to conda)
# About micromamba: A tiny version of the mamba. No base environment nor a default version of Python
# More: https://mamba.readthedocs.io/en/latest/index.html

# Try to activate micromamba first
export MAMBA_ROOT_PREFIX=$mamba_root_path
eval "$($mamba_path shell hook -s posix)"

if ! command -v micromamba &>/dev/null; then
    # Install micromamba
    brew install micromamba
    # Activate micromamba in current shell
    eval "$($mamba_path shell hook -s posix)"
    verify_installation micromamba
else
    echo_green "micromamba has already been installed"
fi

# Set default channels for micromamba
if [ "$network_connected" == false ]; then
    micromamba config prepend channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
    # micromamba config prepend channels http://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/
else
    micromamba config prepend channels nodefaults
    micromamba config prepend channels conda-forge
fi
micromamba config set channel_priority strict
micromamba clean -i

echo_green "micromamba has been configed"

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
if [ ! -d $code_path ]; then
    cd $installation_path
    git clone --depth=1 $sd_webui_url
    echo_green "Code has been installed successfully"
else
    echo_green "Code has already been downloaded"
fi
# Enter the SD's folder
cd $code_path

# TODO: Optional
git pull

if [ "$network_connected" == false ]; then
    sed -i '' "s/https:\/\/github.com/https:\/\/ghproxy.com\/github.com/g" modules/launch_utils.py
else
    sed -i '' "s/https:\/\/ghproxy.com\/github.com/https:\/\/github.com/g" modules/launch_utils.py
fi

echo

echo "############ Create virtual env ######################"
# Check if the env exits
if micromamba env list | grep sd >/dev/null; then
    echo_green "The sd env already exists"
else
    yes | micromamba create -n sd python=3.10
    echo_green "The sd env has been created successfully"
fi

# Activate sd env
echo_green "Activate sd env"
eval "$($mamba_path shell hook --shell posix)"
micromamba activate sd

# micromamba install basicsr=1.4.2 xformers=0.0.20

if [ ! -d "venv" ]; then
    # Activate pyvenv to update pip to avoid some errors
    python -m venv venv
fi
source venv/bin/activate

# Delete pip cache to avoid some errors
pip cache purge

if [ "$network_connected" == false ]; then
    # Tsinghua mirror has no tb-nightly package, which is needed by basicsr
    # TODO: reset in clean_up
    pip config set global.index-url https://mirrors.aliyun.com/pypi/simple
    pip config set global.extra-index-url https://pypi.tuna.tsinghua.edu.cn/simple

    # pip install torch
else
    pip config set global.index-url https://pypi.org/simple
fi

if [[ $(uname -p) != 'arm' ]]; then
    pip install --upgrade pip setuptools
    pip install basicsr==1.4.2
fi

# Install required packages via micromamba
# micromamba install --yes --file requirements_versions.txt

# Fix issue https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/12210
if [ "$network_connected" == false ]; then
    echo >>webui-macos-env.sh
    echo "export TORCH_COMMAND=\"pip install wheel==0.41.1 torch==2.0.1 torchvision==0.15.2 cython && pip install git+https://ghproxy.com/https://github.com/TencentARC/GFPGAN.git@8d2447a2d918f8eba5a4a01463fd48e45126a379 --prefer-binary\"" >>webui-macos-env.sh
fi

# Install Stable Diffusion
echo "############ 开始安装 Stable Diffusion ################"
echo "############ Start to install Stable Diffusion ######"

./webui.sh

clean_up
echo "############ Install Stable Diffusion successfully ###"
