#!/bin/bash

main() {
  echo "Please enter your full name..."
  read GIT_NAME
  echo "Please enter your Github email address..."
  read GIT_EMAIL
  echo "Is this machine a VM? (Y/N)"
  read IS_A_VM
  echo "Run an AV scan (Could take up to 30 mins)? (Y/N)"
  read RUN_SCAN
  echo "Would you like to install ruby? (Y/N)"
  read INSTALL_RUBY
  echo "Would you like to install scala? (Y/N)"
  read INSTALL_SCALA
  echo "Would you like to install docker? (Y/N)"
  read INSTALL_DOCKER
  echo "Would you like to install haskell? (Y/N)"
  read INSTALL_HASKELL

  sudo pacman -Syyu
  sudo pacman -S --noconfirm clamav make yay base-devel

  mkdir -p $HOME/Documents/go $HOME/Documents/Programmes $HOME/Documents/vim

  git clone https://github.com/helixarch/debtap.git
  sudo ln -s $HOME/Documents/Programmes/debtap/debtap /usr/bin/debtap

  clamScan "$RUN_SCAN"
  gitConfig "$GIT_NAME" "$GIT_EMAIL"
  goInstall "1.12.1"
  vimConfig
  tmuxInstall "$IS_A_VM"
  terraformInstall
  rubyInstall "$INSTALL_RUBY"
  scalaInstall "$INSTALL_SCALA"
  dockerInstall "$INSTALL_DOCKER"
  haskellInstall "$INSTALL_HASKELL"

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
  if [ -z "$1" -o -z "$2" ]
  then
    echo "Skipping git config due to missing params"
  else
    git config --global --replace-all user.name $1
    git config --global --replace-all user.email $2
    sudo git config --system core.editor vim
    mv config/gitignore_global $HOME/.gitignore_global
    git config --global core.excludesfile $HOME/.gitignore_global
    sudo apt-get install kdiff3
    git config --global --add merge.tool kdiff3
  fi
}

goInstall() {
  cd $HOME/Documents/Programmes/
  curl -O "https://dl.google.com/go/go$1.linux-amd64.tar.gz"
  sudo tar -C /usr/local -xzf "go$1.linux-amd64.tar.gz"
  echo "export PATH=\$PATH:/usr/local/go/bin" >> $HOME/.bashrc
  echo "export GOPATH=$HOME/Documents/go" >> $HOME/.bashrc
  source $HOME/.bashrc
}

vimConfig() {
  nodeInstall
  cd $HOME/Documents/vim

  (git clone https://github.com/vim/vim.git &&
  cd vim/src;
  ./configure --enable-luainterp \
            --enable-perlinterp \
            --enable-pythoninterp \
            --enable-rubyinterp
  make && sudo make install)

  (git clone https://github.com/kohrVid/vim-settings.git;
  cd vim-settings;
  git remote remove origin;
  git remote add origin git@github.com:kohrVid/vim-settings.git;
  ./bundle.sh)
}

tmuxInstall() {
  if [[ -z $(which yacc) ]]
    then
      sudo pacman -S --noconfirm bison
      alias yacc="bison"
  fi

  cd $HOME/Documents/Programmes/
  sudo pacman -S --noconfirm gcc pkg-config autogen automake libevent-dev libncurses5-dev
  git clone https://github.com/tmux/tmux.git
  cd tmux
  git remote remove origin
  git remote add origin git@github.com:tmux/tmux.git
  sh autogen.sh
  ./configure && make
  sudo ln -s $HOME/Documents/Programmes/tmux/tmux /usr/bin/tmux

  if [ `echo "$1" | awk '{print toupper($0)}'` = "Y" ]
  then
    cp $HOME/Documents/vim/vim-settings/config/tmux_vm.conf $HOME/.tmux.conf
  else
    cp $HOME/Documents/vim/vim-settings/config/tmux.conf $HOME/.tmux.conf
  fi
}

rubyInstall() {
  if [ `echo "$1" | awk '{print toupper($0)}'` = "Y" ]
  then
    cd $HOME/Documents/Programmes/
    echo "Installing ruby...."
    gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    \curl -sSL https://get.rvm.io | bash -s stable --rails
    source $HOME/.bashrc
    rvm pkg install openssl
    gem install solargraph
    rm -rf $HOME/.yarn
    vim "+CocInstall coc-solargraph" "+qall"
  else
    echo "Skipping ruby installation"
  fi
}

scalaInstall() {
  if [ `echo "$1" | awk '{print toupper($0)}'` = "Y" ]
  then
    cd $HOME/Documents/Programmes/
    echo "Installing scala...."
    sudo pacman -S --noconfirm default-jre default-jdk
    curl -O https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz
    sudo tar xvf openjdk-11.0.1_linux-x64_bin.tar.gz --directory /usr/lib/jvm/
    /usr/lib/jvm/jdk-11.0.1/bin/java -version
    java_home="export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\nexport PATH=\$JAVA_HOME/bin/:\$PATH"
    echo $java_home >> $HOME/.bashrc
    sudo echo $java_home >> /etc/environment
    sudo pacman -S --noconfirm scala
    echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
    sudo pacman -Syyu --noconfirm
    sudo pacman -S --noconfirm  sbt
    vimMetals
  else
    echo "Skipping scala installation"
  fi
}

vimMetals() {
  cd /usr/bin
  sudo curl -L -o coursier https://git.io/coursier
  sudo chmod +x coursier

  sudo coursier bootstrap \
    --java-opt -Xss4m \
    --java-opt -Xms100m \
    --java-opt -Dmetals.client=coc.nvim \
    org.scalameta:metals_2.12:0.5.2 \
    -r bintray:scalacenter/releases \
    -r sonatype:snapshots \
    -o /usr/local/bin/metals-vim -f

  mkdir -p $HOME/.cache/metals
  touch $HOME/.cache/metals/bsp.trace.json
}

nodeInstall() {
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
  source $HOME/.nvm/nvm.sh
  nvm install --lts
  nvm use --lts
}

terraformInstall() {
  cd $HOME/Documents/Programmes
  curl -O https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
  unzip terraform_0.11.13_linux_amd64.zip
  sudo ln -s $HOME/Documents/Programmes/terraform /usr/bin/terraform
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/wata727/tflint/v0.7.5/install_linux.sh)"
}

dockerInstall() {
  if [ `echo "$1" | awk '{print toupper($0)}'` = "Y" ]
  then
    sudo pacman -Rs docker docker-engine docker.io containerd runc
    sudo pacman -Syyu

    sudo pacman -S --noconfirm docker-ce docker-ce-cli containerd.io
  else
    echo "Skipping docker installation"
  fi
}

haskellInstall() {
  if [ `echo "$1" | awk '{print toupper($0)}'` = "Y" ]
  then
    sudo pacman -S --noconfirm ghc
    cd Documents/Programmes
    curl -sSL https://get.haskellstack.org/ | sh
    git clone https://github.com/haskell/haskell-ide-engine --recurse-submodules
    cd haskell-ide-engine
    stack ./install.hs hie-8.4.4
    stack ./install.hs build-doc
    stack ./install.hs cabal-ghcs
    sudo ln -s $HOME/.local/bin/hie-wrapper /usr/bin/hie-wrapper
  else
    echo "Skipping haskell installation"
  fi
}

postGNOMEInstall() {
  cd $HOME/Documents/Programmes
  sudo pacman -S --noconfirm conky
  cp $HOME/Documents/vim/vim-settings/config/conkyrc $HOME/.conkyrc
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  cp $HOME/Documents/vim/vim-settings/config/zshrc $HOME/.zshrc
  cp $HOME/Documents/vim/vim-settings/config/zshenv_arch $HOME/.zshenv
  guiAppInstall
}

guiAppInstall() {
  cd $HOME/Documents/Programmes
  yay cherrytree
  anacondaInstall
  sudo pacman -S --noconfirm community/slack-online
  spotifyInstall
  pacman -S python2
  yay gnome-python-desktop
}

anacondaInstall() {
  cd $HOME/Documents/Programmes
  curl -O https://repo.anaconda.com/archive/Anaconda3-2018.12-Linux-x86_64.sh
  sudo chmod +x Anaconda3-2018.12-Linux-x86_64.sh
  ./Anaconda3-2018.12-Linux-x86_64.sh
  conda install -c anaconda-cluster scala
  conda install -c r r-irkernel rpy2
  conda install jupyter
}

spotifyInstall() {
  cd $HOME/Documents/Programmes
  git clone https://aur.archlinux.org/snapd.git
  cd snapd
  makepkg -s --noconfirm
  sudo snap install spotify
}

whatIsMyDistro() {
  if [[ "`hostnamectl`" =~ 'Ubuntu' ]]
  then
    echo "ubuntu"
  elif [[ "`hostnamectl`" =~ 'Debian' ]]
  then
    echo "debian"
  #elif [[ "`hostnamectl`" =~ 'Fedora' ]]
  #then
    #echo "fedora"
  else
    echo "Unknown distro" 1>&2
    exit 1
  fi
}

main
