#! /bin/bash

set -u

# Configurable variables #TODO: Make them configurable
installation_path=$HOME
tmp_path="$HOME/.sd-installer"
mamba_root_path="~/micromamba"
net_connected=true

# Other variables
brew_installer_path="$tmp_path/brew_installer.sh"
test_mode=0 # Only for test. 0 for no test, 1 for yes-test, 2 for no-test

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
        /bin/bash -c "$(curl -fsSL $sd_installer_url)"
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
    -1 | -2)
        test_mode=${1:1}
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
        net_connected=true
        echo_green "Yes-test"
    else
        net_connected=false
        echo_green "No-test"
    fi
else
    echo_green "For non-Chinese users, you could just ignore this and press the Enter key"
    read -rp "网络是否顺畅? 默认y [y/n] " net_choice
    net_choice=${net_choice:-y}
    if [[ $net_choice == [nN] ]]; then
        net_connected=false
        echo_green "将会设置国内镜像源安装, 链接可能会不稳定 / 失效"
    else
        echo_green "网络通畅, 正常安装"
    fi
fi

brew_installer_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
sd_installer_url="https://raw.githubusercontent.com/wy-luke/StableDiffusion-Installer-For-Mac/main/sd-installer.sh"
sd_webui_url="https://github.com/AUTOMATIC1111/stable-diffusion-webui.git"

if ! $net_connected; then
    brew_installer_url="https://raw.fastgit.org/Homebrew/install/HEAD/install.sh"
    sd_installer_url="https://raw.fastgit.org/wy-luke/StableDiffusion-Installer-For-Mac/main/sd-installer.sh"
    sd_webui_url="https://ghproxy.com/github.com/AUTOMATIC1111/stable-diffusion-webui.git"
fi

echo "############ 开始安装 Stable Diffusion web UI #########" && echo

if [ ! -d $tmp_path ]; then
    mkdir -p $tmp_path
fi

echo "############ Check and install Homebrew ##############"
# Homebrew: The missing package manager for macOS
# More: https://brew.sh/

# Try to activate homebrew first
eval "$(/opt/homebrew/bin/brew shellenv)"

if ! command -v brew &>/dev/null; then
    if curl -fsSL $brew_installer_url -o $brew_installer_path && [ -f $brew_installer_path ]; then

        # Grant the permission to install Homebrew
        sudo dseditgroup -o edit -a $(whoami) -t user admin
        sudo dseditgroup -o edit -a $(whoami) -t user wheel

        # Grant the permission to execute the installation script
        chmod +x $brew_installer_path

        if ! $net_connected; then
            export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
            export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
            export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
        fi

        yes | /bin/bash -c $brew_installer_path
        eval "$(/opt/homebrew/bin/brew shellenv)"
        verify_installation brew

        if ! $net_connected; then
            export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
            export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
            export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
            export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
            export HOMEBREW_PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
            brew update
        fi
    else
        echo_red "Homebrew 安装文件下载失败, 请检查网络连接"
        echo_red "Failed to download Homebrew installation script, please check your network connection"
        exit 1

    fi
else
    echo_green "Homebrew has already been installed"
fi

echo_green "Install the packages required"
brew install cmake protobuf rust wget
# brew install --cask cmake

echo

echo "############ Check and install micromamba ############"
# About mamba: A super fast Python package and environment manager (compared to conda)
# About micromamba: A tiny version of the mamba. No base environment nor a default version of Python
# More: https://mamba.readthedocs.io/en/latest/index.html

# Try to activate micromamba first
export MAMBA_ROOT_PREFIX=$mamba_root_path
eval "$(/opt/homebrew/bin/micromamba shell hook -s bash)"

if ! command -v micromamba &>/dev/null; then
    # Install micromamba
    brew install micromamba
    # Activate micromamba in current shell
    eval "$(/opt/homebrew/bin/micromamba shell hook -s bash)"
    verify_installation micromamba

    # Set default channels for micromamba
    micromamba config append channels conda-forge
    micromamba config append channels nodefaults
    micromamba config set channel_priority strict

    if ! $net_connected; then
        conda config --set show_channel_urls yes
        micromamba config prepend channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
        # micromamba config prepend channels http://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/
        conda clean -i
    fi

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
if [ ! -d "$installation_path/stable-diffusion-webui" ]; then
    cd $installation_path
    git clone --depth=1 $sd_webui_url
    echo_green "Code has been installed successfully"
else
    echo_green "Code has already been downloaded"
fi
# Enter the SD's folder
cd "$installation_path/stable-diffusion-webui"
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
eval "$(micromamba shell hook --shell bash)"
micromamba activate sd

if [ ! -d "stable-diffusion-webui" ]; then
    # Activate pyvenv to update pip to avoid some errors
    python -m venv venv
fi
source venv/bin/activate

if ! $net_connected; then
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
fi

pip install --upgrade pip setuptools wheel
pip install basicsr==1.4.1

# Delete pip cache to avoid some errors
pip cache purge

# Install required packages via micromamba
# micromamba install --yes --file requirements_versions.txt

# Fix issue https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/12210
if ! $net_connected; then
    echo >>webui-macos-env.sh
    echo "export TORCH_COMMAND=\"pip install wheel==0.41.1 torch==2.0.1 torchvision==0.15.2 cython && pip install git+https://ghproxy.com/https://github.com/TencentARC/GFPGAN.git@8d2447a2d918f8eba5a4a01463fd48e45126a379 --prefer-binary\"" >>webui-macos-env.sh
fi

# Install Stable Diffusion
echo "############ 开始安装 Stable Diffusion ################"
echo "############ Start to install Stable Diffusion ######"
./webui.sh

clean_up

echo "############ Install Stable Diffusion successfully ###"
