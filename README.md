<p align="left">
    <a href="README_CN.md">中文</a> &nbsp ｜ &nbsp English
</p>

# Stable Diffusion Installer For Mac

Assist you in quickly installing the Stable Diffusion web UI on your Mac.

Steps for Usage:

1. In the **Applications** folder, locate **Terminal** <img src="./images/terminal.png" alt="terminal" width="25"/> and open it. 
2. Copy the following command to the **terminal**, press the **Enter key** to execute the command, and the installation will start automatically. Just wait for the installation to complete.

    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/wy-luke/StableDiffusion-Installer-For-Mac/main/sd-installer.sh)"
    ```

3. ~~If prompted to input, simply press the **Enter key** and **only** that.~~
4. If you see similar content below, it indicates a successful installation.

    ![success](images/success.png)

5. Open your web browser and enter `http://127.0.0.1:7860` (the underlined part in the image above) to access the Stable Diffusion web UI.
