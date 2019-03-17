#!/bin/bash

main() {
  sudo apt-get update
  sudo apt-get install git vim clamav ssh make
  mkdir -p ~/Documents/go ~/Documents/Programmes ~/Documents/vim
  echo "Please enter your full name..."
  read GIT_NAME
  echo "Please enter your Github email address..."
  read GIT_EMAIL
  echo "Is this machine a VM? (Y/N)"
  read IS_A_VM
  echo "Run an AV scan (Could take up to 30 mins)? (Y/N)"
  read RUN_SCAN

  clamScan "$RUN_SCAN"
  gitConfig "$GIT_NAME" "$GIT_EMAIL"
  goInstall "1.12.1"
  vimConfig
  tmuxInstall

  if [ `echo $IS_A_VM | awk '{print toupper($0)}'` = "N" ]
  then
    postGNOMEInstall
  fi
}

clamScan() {
  if [ `echo "$1" | awk '{print toupper($0)}'` = "N" ]
  then
    echo "Skipping scan"
  else
    echo "Running scan...."
    sudo mkdir /clam01
    sudo clamscan --recursive=yes / --move=/clam01 -l /clam01.txt
  fi
}

gitConfig() {
  if [ -z $1 -o -z $2 ]
  then
    echo "Skipping git config due to missing params"
  else
    git config --global --replace-all user.name $1
    git config --global --replace-all user.email $2
    git config --system core.editor vim
    echo "*.swp" >> ~/.gitignore_global
    echo "*.swo" >> ~/.gitignore_global
  fi
}

goInstall() {
  cd ~/Documents/Programmes/
  curl -O "https://dl.google.com/go/go$1.linux-amd64.tar.gz"
  sudo tar -C /usr/local -xzf "go$1.linux-amd64.tar.gz"
  echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
  echo "export GOPATH=$HOME/Documents/go" >> ~/.bashrc
}

vimConfig() {
  (cd ~/Documents/vim;
  git clone https://github.com/kohrVid/vim-settings.git;
  cd vim-settings;
  git remote remove origin;
  git remote add origin git@github.com:kohrVid/vim-settings.git;
  ./bundle.sh)
}

tmuxInstall() {
  cd ~/Documents/Programmes/
  sudo apt-get install gcc pkg-config autogen automake libevent-dev libncurses5-dev
  git clone https://github.com/tmux/tmux.git
  cd tmux
  git remote remove origin
  git remote add origin git@github.com:tmux/tmux.git
  sh autogen.sh
  ./configure && make
  sudo ln -s ~/Documents/Programmes/tmux/tmux /usr/bin/tmux
  cp ~/Documents/vim/vim-settings/config/tmux.conf ~/.tmux.conf
}

postGNOMEInstall() {
  cd ~/Documents/Programmes
  sudo apt-get install conky
  cp ~/Documents/vim/vim-settings/config/conkyrc ~/.conkyrc
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  cp ~/Documents/vim/vim-settings/config/zshrc ~/.zshrc
  guiAppInstall
}

guiAppInstall() {
  cd ~/Documents/Programmes
  curl -O http://www.giuspen.com/software/cherrytree_0.38.8-0_all.deb
  sudo dpkg -i cherrytree_0.38.8-0_all.deb
  curl -O https://downloads.slack-edge.com/linux_releases/slack-desktop-3.3.8-amd64.deb
  sudo dpkg -i slack-desktop-3.3.8-amd64.deb
}

main
