<p align="left">
    <a href="README.md">English</a> &nbsp ｜ &nbsp 中文
</p>

# Stable Diffusion Installer For Mac

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org) ![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/t/wy-luke/StableDiffusion-Installer-For-Mac) ![GitHub release (with filter)](https://img.shields.io/github/v/release/wy-luke/StableDiffusion-Installer-For-Mac) [![Test](https://github.com/wy-luke/StableDiffusion-Installer-For-Mac/actions/workflows/test.yml/badge.svg)](https://github.com/wy-luke/StableDiffusion-Installer-For-Mac/actions/workflows/test.yml)

帮助你**快速、轻松**地将 Stable Diffusion web UI 安装在你的 mac 上。

理论上讲，在所有的 Mac 上均可适用。

## 使用

1. 在**应用程序**中，找到**终端** <img src="./images/terminal.png" alt="terminal" width="25"/> 并打开

   > 注意：在 `/应用程序/实用工具` 文件夹中，如果还是找不到，那就使用名字搜索吧。

2. 复制下面的命令到**终端**中，按**回车键**执行命令，然后安装就会自动开始，只需等待安装完成

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/wy-luke/StableDiffusion-Installer-For-Mac/main/sd-installer.sh)"
   ```

   国内用户存在网络问题时，可以尝试使用以下命令：

   ```bash
   curl -fsSL https://raw.fastgit.org/wy-luke/StableDiffusion-Installer-For-Mac/main/sd-installer.sh | /bin/bash -s -- -c
   ```

   该命令为安装脚本添加 `-c` 参数，会在安装时自动切换为国内源，进行网络加速，包括 homebrew、conda-forge、pip、github 等, 但链接可能会不稳定或失效, 若安装失败可以重试。

3. 在安装开始时，会提示您输入密码，只需输入您的登录密码即可。

   > 注意：您的密码在输入时是不可见的，只需正常输入，完成后按 Enter 键。

4. 如果出现类似下面的内容，即为安装成功

   ![success](images/success.png)

5. 打开浏览器，输入 `http://127.0.0.1:7860`(即上图划线部分)，即可打开 Stable Diffusion web UI

6. 如果安装失败，会提示您是否重试。输入 `y` 或**按 Enter 键**重试，输入 `n` 退出安装。

## 优势

1. 使用 [Homebrew](https://brew.sh/) 来安装所需的依赖。如果已经安装，将会自动使用；如果没有，将会自动安装，但不会修改你的系统环境，你的系统将保持不变。

   如果你希望默认激活使用它，可以将 `eval $(/opt/homebrew/bin/brew shellenv)` 添加到 `.zprofile`（zsh）或 `.bash_profile`（bash）文件中。

   你也可以使用一下命令：

   ```bash
   # zsh
   echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/$USER/.zprofile
   eval $(/opt/homebrew/bin/brew shellenv)

   # bash
   echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/$USER/.bash_profile
   eval $(/opt/homebrew/bin/brew shellenv)
   ```

2. 使用 [micromamba](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html)（[mamba](https://mamba.readthedocs.io/en/latest/index.html#) 的精简版本）作为 Python 的包和环境管理工具，而不是 Conda。

   与 Conda 相比，它没有 `base` 环境（为空），也没有默认的 Python 版本，这意味着它不会干扰或污染你的系统 Python 环境。此外，它的速度更快。

   同样地，它也不会被添加到你的系统环境中，不会被自动激活。但如果你想要的话，可以使用以下命令：

   ```bash
   # zsh
   /opt/homebrew/bin/micromamba shell init -s zsh -p ~/micromamba
   source ~/.zshrc

   # bash
   /opt/homebrew/bin/micromamba shell init -s bash -p ~/micromamba
   source ~/.bashrc
   ```
