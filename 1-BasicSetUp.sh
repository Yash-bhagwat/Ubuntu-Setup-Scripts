#!/bin/bash


set -e

spatialPrint() {
    echo ""
    echo ""
    echo "$1"
	echo "================================"
}

# To note: the execute() function doesn't handle pipes well
execute () {
	echo "$ $*"
	OUTPUT=$($@ 2>&1)
	if [ $? -ne 0 ]; then
        echo "$OUTPUT"
        echo ""
        echo "Failed to Execute $*" >&2
        exit 1
    fi
}

# Speed up the process
# Env Var NUMJOBS overrides automatic detection
if [[ -n $NUMJOBS ]]; then
    MJOBS=$NUMJOBS
elif [[ -f /proc/cpuinfo ]]; then
    MJOBS=$(grep -c processor /proc/cpuinfo)
elif [[ "$OSTYPE" == "darwin"* ]]; then
	MJOBS=$(sysctl -n machdep.cpu.thread_count)
else
    MJOBS=4
fi

execute sudo apt-get update -y
if [[ ! -n $CIINSTALL ]]; then
    sudo apt-get dist-upgrade -y
    sudo apt-get install ubuntu-restricted-extras -y
fi

# Choice for terminal that will be adopted: Tilda+tmux
# Not guake because tilda is lighter on resources
# Not terminator because tmux sessions continue to run if you accidentally close the terminal emulator
execute sudo apt-get install git wget curl -y
execute sudo apt-get install tilda tmux -y
execute sudo apt-get install gimp -y
execute sudo apt-get install xclip -y # this is used for the copying tmux buffer to clipboard buffer
execute sudo apt-get install vim-gui-common vim-runtime -y
cp ./config_files/vimrc ~/.vimrc
execute sudo snap install micro --classic
mkdir -p ~/.config/micro/
cp ./config_files/micro_bindings.json ~/.config/micro/bindings.json

# refer : [http://www.rushiagr.com/blog/2016/06/16/everything-you-need-to-know-about-tmux-copy-pasting-ubuntu/] for tmux buffers in ubuntu
cp ./config_files/tmux.conf ~/.tmux.conf
cp ./config_files/tmux.conf.local ~/.tmux.conf.local
mkdir -p ~/.config/tilda
cp ./config_files/config_0 ~/.config/tilda/

#Checks if ZSH is partially or completely Installed to Remove the folders and reinstall it
rm -rf ~/.z*
zsh_folder=/opt/.zsh/
if [[ -d $zsh_folder ]];then
	sudo rm -r /opt/.zsh/*
fi

spatialPrint "Setting up Zsh + Zim now"
# Ubuntu 16.04 has older zsh in repository
if [[ $(cat /etc/os-release | grep "VERSION_ID" | grep -o -E '[0-9][0-9]' | head -n 1) -le 16 ]]; then
    wget https://gist.githubusercontent.com/rsnk96/87229bd910e01f2ee7c35f96d7cb2f6c/raw/f068812ebd711ed01ebc4c128c8624730ab0dc81/build-zsh.sh -O extras/build-zsh.sh
    # Install latest zsh release
    sed -i '/cd zsh/a git checkout $(git tag | tail -1)' extras/build-zsh.sh
    bash extras/build-zsh.sh
else
    execute sudo apt-get install zsh -y
fi

sudo mkdir -p /opt/.zsh/ && sudo chmod ugo+w /opt/.zsh/
export ZIM_HOME=/opt/.zsh/zim
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
# Change default shell to zsh
command -v zsh | sudo tee -a /etc/shells
sudo chsh -s "$(command -v zsh)" "${USER}"

execute sudo apt-get install aria2 -y

# Create bash aliases
cp ./config_files/bash_aliases /opt/.zsh/bash_aliases
ln -s /opt/.zsh/bash_aliases ~/.bash_aliases

{
    echo "if [ -f ~/.bash_aliases ]; then"
    echo "  source ~/.bash_aliases"
    echo "fi"

    echo "# Switching to 256-bit colour by default so that zsh-autosuggestion's suggestions are not suggested in white, but in grey instead"
    echo "export TERM=xterm-256color"

    echo "# Setting the default text editor to micro, a terminal text editor with shortcuts similar to what you'd encounter in an IDE"
    echo "export VISUAL=micro"
} >> ~/.zshrc

# Now create shortcuts
execute sudo apt-get install run-one xbindkeys xbindkeys-config wmctrl xdotool -y
cp ./config_files/xbindkeysrc ~/.xbindkeysrc

# Now download and install bat
spatialPrint "Installing bat, a handy replacement for cat"
latest_bat_setup=$(curl --silent "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep "deb" | grep "browser_download_url" | head -n 1 | cut -d \" -f 4)
aria2c --file-allocation=none -c -x 10 -s 10 --dir /tmp -o bat.deb $latest_bat_setup
execute sudo dpkg -i /tmp/bat.deb
execute sudo apt-get install -f


# echo "*************************** NOTE *******************************"
# echo "If you ever mess up your anaconda installation somehow, do"
# echo "\$ conda remove anaconda matplotlib mkl mkl-service nomkl openblas"
# echo "\$ conda clean --all"
# echo "Do this for each environment as well as your root. Then reinstall all except nomkl"

# For utilities such as lspci
execute sudo apt-get install pciutils


spatialPrint "The script has finished."
if [[ ! -n $CIINSTALL ]]; then
    su - $USER
fi
