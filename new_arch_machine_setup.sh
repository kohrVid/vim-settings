#!/bin/bash

main() {
  echo "[sudo] password for $USER: "
  read -s PASSWORD
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


  mkdir -p $HOME/Documents/go $HOME/Documents/Programmes $HOME/Documents/vim

  sudo -S <<< "$PASSWORD" pacman -Syyu --noconfirm
  sudo -S <<< "$PASSWORD" pacman -S --noconfirm clamav make yay base-devel xclip

  git clone https://github.com/helixarch/debtap.git
  sudo -S <<< "$PASSWORD" ln -s $HOME/Documents/Programmes/debtap/debtap /usr/bin/debtap

  clamScan "$RUN_SCAN" "$PASSWORD"
  gitConfig "$GIT_NAME" "$GIT_EMAIL" "$PASSWORD"
  goInstall "1.12.1" "$PASSWORD"
  vimConfig "$PASSWORD"
  tmuxInstall "$IS_A_VM" "$PASSWORD"
  terraformInstall "$PASSWORD"
  rubyInstall "$INSTALL_RUBY"
  scalaInstall "$INSTALL_SCALA" "$PASSWORD"
  dockerInstall "$INSTALL_DOCKER" "$PASSWORD"
  haskellInstall "$INSTALL_HASKELL" "$PASSWORD"

  if [ `echo $IS_A_VM | awk '{print toupper($0)}'` = "N" ]
  then
    postGNOMEInstall "$PASSWORD"
  fi

  echo "Setup complete"
}

clamScan() {
  if [ `echo "$1" | awk '{print toupper($0)}'` = "N" ]
  then
    echo "Skipping scan"
  else
    echo "Running scan...."
    sudo -S <<< "$2" mkdir /clam01
    sudo -S <<< "$2" touch /run/clamav/clamd.ctl
    sudo -S <<< "$2" chown clamav:clamav /run/clamav/clamd.ctl
    sudo -S <<< "$2" freshclam
    sudo -S <<< "$2" clamscan --recursive=yes / --move=/clam01 -l /clam01.txt
  fi
}

gitConfig() {
  if [ -z "$1" -o -z "$2" ]
  then
    echo "Skipping git config due to missing params"
  else
    git config --global --replace-all user.name "$1"
    git config --global --replace-all user.email "$2"
    sudo -S <<< "$3" git config --system core.editor vim
    cp $HOME/Documents/vim/vim-settings/config/gitignore_global $HOME/.gitignore_global
    git config --global core.excludesfile $HOME/.gitignore_global
    sudo -S <<< "$3" pacman -S kdiff3
    git config --global --add merge.tool kdiff3
  fi
}

goInstall() {
  cd $HOME/Documents/Programmes/
  curl -O "https://dl.google.com/go/go$1.linux-amd64.tar.gz"
  sudo -S <<< "$2" tar -C /usr/local -xzf "go$1.linux-amd64.tar.gz"
  echo "export PATH=\$PATH:/usr/local/go/bin" >> $HOME/.bashrc
  echo "export GOROOT=/usr/local/go" >> $HOME/.bashrc
  echo "export GOPATH=$HOME/Documents/go" >> $HOME/.bashrc
  echo "export GOBIN=$GOROOT/bin" >> $HOME/.bashrc
  source $HOME/.bashrc
  sudo -S <<< "$2" chown $USER:$USER $GOBIN
}

vimConfig() {
  nodeInstall
  cd $HOME/Documents/vim
  sudo -S <<< "$1" pacman -S --noconfirm gvim


  (git clone https://github.com/kohrVid/vim-settings.git;
  cd vim-settings;
  git remote remove origin;
  git remote add origin git@github.com:kohrVid/vim-settings.git;
  ./bundle.sh)
}

tmuxInstall() {
  if [[ -z $(which yacc) ]]
    then
      sudo -S <<< "$2" pacman -S --noconfirm bison
      alias yacc="bison"
  fi

  cd $HOME/Documents/Programmes/
  sudo -S <<< "$2" pacman -S --noconfirm gcc pkg-config autogen automake
  git clone https://github.com/tmux/tmux.git
  cd tmux
  git remote remove origin
  git remote add origin git@github.com:tmux/tmux.git
  sh autogen.sh
  ./configure && make
  sudo -S <<< "$2" ln -s $HOME/Documents/Programmes/tmux/tmux /usr/bin/tmux

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
    sudo -S <<< "$2" pacman -S --noconfirm default-jre default-jdk
    curl -O https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz
    sudo -S <<< "$2" tar xvf openjdk-11.0.1_linux-x64_bin.tar.gz --directory /usr/lib/jvm/
    /usr/lib/jvm/jdk-11.0.1/bin/java -version
    java_home="export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\nexport PATH=\$JAVA_HOME/bin/:\$PATH"
    echo $java_home >> $HOME/.bashrc
    sudo -S <<< "$2" echo $java_home >> /etc/environment
    sudo -S <<< "$2" pacman -S --noconfirm scala
    echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
    sudo -S <<< "$2" apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
    sudo -S <<< "$2" pacman -Syyu --noconfirm
    sudo -S <<< "$2" pacman -S --noconfirm  sbt
    vimMetals "$2"
  else
    echo "Skipping scala installation"
  fi
}

vimMetals() {
  cd /usr/bin
  sudo -S <<< "$1" curl -L -o coursier https://git.io/coursier
  sudo -S <<< "$1" chmod +x coursier

  sudo -S <<< "$1" coursier bootstrap \
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
  sudo -S <<< "$1" ln -s $HOME/Documents/Programmes/terraform /usr/bin/terraform
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/wata727/tflint/v0.7.5/install_linux.sh)"
}

dockerInstall() {
  if [ `echo "$1" | awk '{print toupper($0)}'` = "Y" ]
  then
    sudo -S <<< "$2" pacman -Syyu --noconfirm
    sudo -S <<< "$2" pacman -S --noconfirm docker
    sudo -S <<< "$2" systemctl start docker # Note, any VPNs must be switched off first
  else
    echo "Skipping docker installation"
  fi
}

haskellInstall() {
  if [ `echo "$1" | awk '{print toupper($0)}'` = "Y" ]
  then
    sudo -S <<< "$2" pacman -S --noconfirm ghc
    cd Documents/Programmes
    curl -sSL https://get.haskellstack.org/ | sh
    git clone https://github.com/haskell/haskell-ide-engine --recurse-submodules
    cd haskell-ide-engine
    stack ./install.hs hie-8.4.4
    stack ./install.hs build-doc
    stack ./install.hs cabal-ghcs
    sudo -S <<< "$2" ln -s $HOME/.local/bin/hie-wrapper /usr/bin/hie-wrapper
  else
    echo "Skipping haskell installation"
  fi
}

postGNOMEInstall() {
  cd $HOME/Documents/Programmes
  sudo -S <<< "$1" pacman -S --noconfirm conky
  cp $HOME/Documents/vim/vim-settings/config/conkyrc $HOME/.conkyrc
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  cp $HOME/Documents/vim/vim-settings/config/zshrc $HOME/.zshrc
  cp $HOME/Documents/vim/vim-settings/config/zshenv_arch $HOME/.zshenv
  guiAppInstall $1
}

guiAppInstall() {
  cd $HOME/Documents/Programmes
  echo 1 | yay --noconfirm --answerdiff=None cherrytree
  anacondaInstall "$1"
  sudo -S <<< "$1" pacman -S --noconfirm community/slack-web-jak
  spotifyInstall "$1"
  pacman -S python2
  #echo 1 | yay --noconfirm --answerdiff=None gnome-python-desktop
}

anacondaInstall() {
  cd $HOME/Documents/Programmes
  sudo -S <<< "$1" pacman -Sy libxau libxi libxss libxtst libxcursor libxcomposite libxdamage libxfixes libxrandr libxrender mesa-libgl  alsa-lib libglvnd
  curl -O https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh
  sudo -S <<< "$1" chmod +x ./Anaconda3-2019.10-Linux-x86_64.sh
  ./Anaconda3-2019.10-Linux-x86_64.sh
  source $HOME/.zshrc
  echo "y" | conda install -c anaconda-cluster scala
  echo "y" | conda install -c r r-irkernel rpy2
  echo "y" | conda install jupyter
  mv $HOME/anaconda3/compiler_compat/ld $HOME/anaconda3/compiler_compat/ldOld
  echo "y" | conda install -c anaconda psycopg2
}

spotifyInstall() {
  cd $HOME/Documents/Programmes
  git clone https://aur.archlinux.org/spotify.git
  cd spotify
  curl -sS https://download.spotify.com/debian/pubkey.gpg | gpg --import -
  echo "$1" | makepkg -s --noconfirm
}

main
