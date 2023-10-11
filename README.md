<p align="left">
    <a href="README_CN.md">中文</a> &nbsp ｜ &nbsp English
</p>

# Stable Diffusion Installer For Mac

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org) ![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/t/wy-luke/StableDiffusion-Installer-For-Mac) ![GitHub release (with filter)](https://img.shields.io/github/v/release/wy-luke/StableDiffusion-Installer-For-Mac) [![Test](https://github.com/wy-luke/StableDiffusion-Installer-For-Mac/actions/workflows/test.yml/badge.svg)](https://github.com/wy-luke/StableDiffusion-Installer-For-Mac/actions/workflows/test.yml)

Install Stable Diffusion web UI on your Mac **with one sigle command**:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/wy-luke/StableDiffusion-Installer-For-Mac/main/sd-installer.sh)"
```

Use mamba to create virtual environment, so it won't conflict with and won't pollute the Python environment in your system. Keep your Mac system untouched. And the uninstallation script is on the way.

Theoretically, it should work on both Apple Silicon and Intel CPU with any version of macOS.

If you encounter any issues or want some new features, feel free to contact me via [here](https://github.com/wy-luke/StableDiffusion-Installer-For-Mac/issues/new).

## Detailed usage

1. In the **Applications** folder, locate **Terminal** <img src="./images/terminal.png" alt="terminal" width="25"/> and open it.

   > Note: It's in the `/Applications/Utilities` folder. If you still can't find it, search it by name!

2. Copy the following command to the **terminal**, press the **Enter key** to execute the command, and the installation will start automatically. Just wait for the installation to complete.

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/wy-luke/StableDiffusion-Installer-For-Mac/main/sd-installer.sh)"
   ```

3. At the beginning, you will be prompted to enter password, just type your login password.

   > Note: Your password will be invisible when you type, just type it, and press Enter after completion.

4. If you see similar content below, it indicates a successful installation.

   ![success](images/success.png)

5. Open your web browser and enter `http://127.0.0.1:7860` (the underlined part in the image above) to access the Stable Diffusion web UI.

   > Note 1: Normally, it will automatically open the web browser.

   > **Note 2: Don't close the terminal app while using Stable Diffusion web UI, just keep it running background. If you accidentally close the terminal, see Re-run section below.**

6. If the installation fails, you will be prompted to select whether to retry. Type `y` or just simply **press the Enter key** to try again. Type `n` to exit.

## Re-run

Keep the terminal running while using SD. When you don't use it anymore, just close the brower page and the terminal.

If you want to re-run SD after the first usage, use the command below to **re-run** Stable Diffusion web UI.

```bash
/bin/bash $HOME/stable-diffusion-webui/webui.sh
```

If you move the `stable-diffusion-webui` folder to another path, you need to change the command above accordingly. Besides, you need always append `/webui.sh` in the end.

```bash
/bin/bash /your/path/of/stable-diffusion-webui/webui.sh
```

## Troubleshooting

### \*\*\*\* not implemented for 'Half'

Most likely, this is due to poor compatibility with AMD graphics cards.

The solution is simple. Run the command below, then execute the **re-run** command above again to start SD.

```bash
echo 'export COMMANDLINE_ARGS="--upcast-sampling --no-half-vae --use-cpu interrogate --precision full --no-half --skip-torch-cuda-test"' > $HOME/stable-diffusion-webui/webui-user.sh
```

### MPS backend out of memory

This issue is caused by insufficient memory. You can reduce the memory requirement by adding `PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.7` before the **re-run** command to make SD run correctly.

> Note: This will result in longer processing time to generate a image. You could adjust the value of `PYTORCH_MPS_HIGH_WATERMARK_RATIO` according to your mac performance.

Replace the **re-run** command with:

```bash
PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.7 /bin/bash $HOME/stable-diffusion-webui/webui.sh
```

If you still encounter this issue, you can try further reducing the value, such as:

```bash
PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.5 /bin/bash $HOME/stable-diffusion-webui/webui.sh
```

## Download models

Place the models downloaded to `stable-diffusion-webui/models/Stable-diffusion` folder. Then refresh the Stable Diffusion web UI page in the browser and you will see it in the list.

1. You could download all kinds of models in [Civitai](https://civitai.com/), a great site!

2. Some popular official Stable Diffusion 1.x models:

   - [Stable DIffusion 1.4](https://huggingface.co/CompVis/stable-diffusion-v-1-4-original) ([sd-v1-4.ckpt](https://huggingface.co/CompVis/stable-diffusion-v-1-4-original/resolve/main/sd-v1-4.ckpt))
   - [Stable Diffusion 1.5](https://huggingface.co/runwayml/stable-diffusion-v1-5) ([v1-5-pruned-emaonly.ckpt](https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt))
   - [Stable Diffusion 1.5 Inpainting](https://huggingface.co/runwayml/stable-diffusion-inpainting) ([sd-v1-5-inpainting.ckpt](https://huggingface.co/runwayml/stable-diffusion-inpainting/resolve/main/sd-v1-5-inpainting.ckpt))

3. Stable Diffusion 2.0 and 2.1 models:

   - [Stable Diffusion 2.0](https://huggingface.co/stabilityai/stable-diffusion-2) ([768-v-ema.ckpt](https://huggingface.co/stabilityai/stable-diffusion-2/resolve/main/768-v-ema.ckpt))
   - [Stable Diffusion 2.1](https://huggingface.co/stabilityai/stable-diffusion-2-1) ([v2-1_768-ema-pruned.ckpt](https://huggingface.co/stabilityai/stable-diffusion-2-1/resolve/main/v2-1_768-ema-pruned.ckpt))

   These models require both a model and a configuration file, and image width & height will need to be set to 768 or higher when generating images.

   For the configuration file, hold down the option key on the keyboard and click [here](https://github.com/Stability-AI/stablediffusion/raw/main/configs/stable-diffusion/v2-inference-v.yaml) to download `v2-inference-v.yaml` (it may download as `v2-inference-v.yaml.yml`). In Finder select that file then go to the menu and select `File` \> `Get Info`. In the window that appears select the filename and change it to the filename of the model, except with the file extension `.yaml` instead of `.ckpt`, press return on the keyboard (confirm changing the file extension if prompted), and place it in the same folder as the model

   E.g. if you downloaded the `768-v-ema.ckpt` model, rename it to `768-v-ema.yaml` and put it in `stable-diffusion-webui/models/Stable-diffusion` along with the model.

   - [Stable Diffusion 2.0 depth model](https://huggingface.co/stabilityai/stable-diffusion-2-depth) ([512-depth-ema.ckpt](https://huggingface.co/stabilityai/stable-diffusion-2-depth/resolve/main/512-depth-ema.ckpt)).

   Download the `v2-midas-inference.yaml` configuration file by holding down option on the keyboard and clicking [here](https://github.com/Stability-AI/stablediffusion/raw/main/configs/stable-diffusion/v2-midas-inference.yaml), then rename it with the `.yaml` extension in the same way as mentioned above and put it in `stable-diffusion-webui/models/Stable-diffusion` along with the model. Note that this model works at image dimensions of 512 width/height or higher instead of 768.

## Features

1. Use [Homebrew](https://brew.sh/) to install required dependencies. If you already have it installed, it will be used automatically. If not, it will be installed for you, but without modifying your system environment – your system will remain unchanged.

   If you wish to activate it by default, you can add `eval $(/opt/homebrew/bin/brew shellenv)` to your `.zprofile` (zsh) or `.bash_profile` (bash) file.

   You could also:

   ```bash
   # zsh
   echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/$USER/.zprofile
   eval $(/opt/homebrew/bin/brew shellenv)

   # bash
   echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/$USER/.bash_profile
   eval $(/opt/homebrew/bin/brew shellenv)
   ```

2. Use [micromamba](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html), which is a tiny version of the [mamba](https://mamba.readthedocs.io/en/latest/index.html#), as Python related package and environment manager instead of Conda.

   Compared to Conda, it has no base environment (empty) nor default version of Python, meaning that it won't interfere or contaminate your system's Python environment at all. Additionally, it's significantly faster.

   Similarly, it isn't added to the system environment either, and won't be activated automatically by default.

   But if you want, you could:

   ```bash
   # zsh
   /opt/homebrew/bin/micromamba shell init -s zsh -p ~/micromamba
   source ~/.zshrc

   # bash
   /opt/homebrew/bin/micromamba shell init -s bash -p ~/micromamba
   source ~/.bashrc
   ```

## Credit

[AUTOMATIC1111](https://github.com/AUTOMATIC1111) and [stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui)

[Homebrew](https://github.com/Homebrew/brew)

[Mamba](https://github.com/mamba-org/mamba)
