# StableDiffusion-Installer-For-Mac

帮助你快速地将 Stable Diffusion web UI 安装在你的 mac 上。

使用步骤：

1. 在**应用程序**中，找到**终端**并打开 <img src="./images/terminal.png" alt="terminal" width="25"/>
2. 复制下面的命令到终端中，按**回车键**执行命令，然后安装就会自动开始，只需等待安装完成

    ```bash
    /bin/bash -c  "$(curl -fsSL  https://raw.githubusercontent.com/wy-luke/StableDiffusion-Installer-For-Mac/main/sd-installer.sh)"
    ```

3. 如果提示输入，需且**只需**按**回车键**
4. 如果出现类似下面的内容，即为安装成功

    ![success](images/success.png)

5. 打开浏览器，输入 `http://127.0.0.1:7860`(即上图划线部分)，即可打开 Stable Diffusion web UI
