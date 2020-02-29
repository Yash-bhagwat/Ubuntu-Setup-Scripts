# Installing CUDA, CUDNN

## Installing CUDA

 - Go to the cuda downloads [website](https://developer.nvidia.com/cuda-10.0-download-archive). Tensorflow 1.14.0 is compactible with CUDA 10.0 and CUDNN 7.4.1.
 - Choose the required versions from the available ones.
 - In case of Ubuntu choose the deb (local) from the options and follow the instructions on the page.
 - **Note** the last step `sudo apt-get install cuda` installs the cuda toolkit with nvidia drivers. Hence if you already have nvidia drivers installed it might cause some problems.

 To avoid `sudo apt-get install cuda-toolkit-10.0`

 Even if you don't I suggest to not install the driver via this step. Instead visit this [page](https://www.nvidia.in/Download/index.aspx?lang=en-in) and download the required version of the driver. To install the driver:

  - Make sure you are logged out.
  - Hit Ctrl+Alt+F1 and login using your credentials.
  - kill your current X server session by typing `sudo service lightdm stop` or `sudo lightdm stop`
  - Enter runlevel 3 by typing sudo init 3
  - Install your *.run file.
you change to the directory where you have downloaded the file by typing for instance cd Downloads. If it is in another directory, go there. Check if you see the file when you type ls NVIDIA*
  - Make the file executable with `chmod +x ./your-nvidia-file.run`
  - Execute the file with `sudo ./your-nvidia-file.run`
  - You might be required to reboot when the installation finishes. If not, run sudo service lightdm start or sudo start lightdm to start your X server again.
  - It's worth mentioning, that when installed this way, you'd have to redo the steps after each kernel update.

 - After installation restart the system and check if installation works by typing the command `nvida-smi`

## Installing CUDNN
 - Go to the official [webpage](https://developer.nvidia.com/cudnn) and download the required version. Once again download 7.4.1 if you want to use tensorflow 1.14 and for the appropriate cuda version.

 - Navigate to your <cudnnpath> directory containing the cuDNN Tar file.
 - Unzip the cuDNN package.
 - `tar -xzvf <cudnn-filename>.tgz`
 - Copy the following files into the CUDA Toolkit directory, and change the file permissions.
  - `sudo cp cuda/include/cudnn.h /usr/local/cuda/include`
  - `sudo cp cuda/lib64/libcudnn* /usr/local/cuda/lib64`
  - `sudo chmod a+r /usr/local/cuda/include/cudnn.h /usr/local/cuda/lib64/libcudnn*`
 - Creating the symlink
  - Go to /usr/local/cuda/lib64
  - `sudo ln -sf libcudnn.so.7.4.2 libcudnn.so.7`

    `sudo ln -sf libcudnn.so.7 libcudnn.so`
  - Check symlinks by typing `sudo ldconfig` and you should'nt see any error.

## Final checks
  
 - Install tensorflow-gpu using pip install (please check versions)
 - **To check CUDA and CUDNN installation** run [python file](tensorflow-gpu-check.py)
