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

  sudo -S <<< "$PASSWORD" apt-get update
  sudo -S <<< "$PASSWORD" apt-get install software-properties-common systemd-services git ssh make rsync gnupg2
  mkdir -p $HOME/Documents/go $HOME/Documents/Programmes $HOME/Documents/vim

  clamScan "$RUN_SCAN" "$PASSWORD"
  gitConfig "$GIT_NAME" "$GIT_EMAIL" "$PASSWORD"
  goInstall "1.19.3" "$PASSWORD"
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
}

clamScan() {
  sudo -S <<< "$2" apt-get install clamav

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
    git config --system core.editor vim
    cp $HOME/Documents/vim/vim-settings/config/gitignore_global $HOME/.gitignore_global
    git config --global core.excludesfile $HOME/.gitignore_global
    sudo -S <<< "$3" apt-get install kdiff3
    git config --global --add merge.tool kdiff3
    git config --global commit.verbose true
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
  sudo -S <<< "$2" chown $USER:$USER -R $GOBIN
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
  make && sudo -S <<< "$1" make install)

  if [ ! -d $HOME/Documents/vim/vim-settings ]
  then
    git clone https://github.com/kohrVid/vim-settings.git;
  fi

  cd vim-settings;
  git remote remove origin;
  git remote add origin git@github.com:kohrVid/vim-settings.git;
  ./bundle.sh)
  # vim-gtk and xclip are needed for clipboard support from vim and tmux
  sudo -S <<< "$1" aptitude install vim-gtk xclip
}

tmuxInstall() {
  if [[ -z $(which yacc) ]]
    then
      sudo -S <<< "$2" apt-get install bison
      alias yacc="bison"
  fi

  cd $HOME/Documents/Programmes/
  sudo -S <<< "$2" apt-get install gcc pkg-config autogen automake libevent-dev libncurses5-dev
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
    sudo -S <<< "$2" apt-get install default-jre default-jdk
    curl -O https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz
    sudo -S <<< "$2" tar xvf openjdk-11.0.1_linux-x64_bin.tar.gz --directory /usr/lib/jvm/
    /usr/lib/jvm/jdk-11.0.1/bin/java -version
    java_home="export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\nexport PATH=\$JAVA_HOME/bin/:\$PATH"
    echo $java_home >> $HOME/.bashrc
    sudo -S <<< "$2" echo $java_home >> /etc/environment
    sudo -S <<< "$2" apt-get install scala
    echo "deb https://dl.bintray.com/sbt/debian /" | sudo -S <<< "$2" tee -a /etc/apt/sources.list.d/sbt.list
    sudo -S <<< "$2" apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
    sudo -S <<< "$2" apt-get update
    sudo -S <<< "$2" apt-get install sbt
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
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
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
    sudo -S <<< "$2" apt-get -y remove docker docker-engine docker.io containerd runc
    sudo -S <<< "$2" apt-get -y update

    sudo -S <<< "$2" apt-get -y install \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg-agent \
      software-properties-common

    curl -fsSL https://download.docker.com/linux/`whatIsMyDistro`/gpg | sudo -S <<< "$2" apt-key add -

    sudo -S <<< "$2" add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/`whatIsMyDistro` \
     $(lsb_release -cs) \
     stable"

    sudo -S <<< "$2" apt-get -y update
    sudo -S <<< "$2" apt-get -y install docker-ce docker-ce-cli containerd.io
  else
    echo "Skipping docker installation"
  fi
}

haskellInstall() {
  if [ `echo "$1" | awk '{print toupper($0)}'` = "Y" ]
  then
    sudo -S <<< "$2" apt install libicu-dev libtinfo-dev libgmp-dev
    sudo -S <<< "$2" apt-install ghc
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
  sudo -S <<< "$1" apt-get install conky
  cp $HOME/Documents/vim/vim-settings/config/conkyrc $HOME/.conkyrc
  cp -R $HOME/Documents/vim/vim-settings/config/conky_lua $HOME/.conky
  zshInstall "$1"
  guiAppInstall "$1"
}

zshInstall() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  curl -O https://github.com/eosrei/twemoji-color-font/releases/download/v13.1.0/TwitterColorEmoji-SVGinOT-Linux-13.1.0.tar.gz
  sudo -S <<< "$1" apt-get install ttf-bitstream-vera
  tar zxf TwitterColorEmoji-SVGinOT-Linux-13.1.0.tar.gz
  (cd TwitterColorEmoji-SVGinOT-Linux-13.1.0; ./install.sh)
  cp $HOME/Documents/vim/vim-settings/config/zshrc $HOME/.zshrc
  cp $HOME/Documents/vim/vim-settings/config/zshenv $HOME/.zshenv
}

guiAppInstall() {
  cd $HOME/Documents/Programmes
  curl -O http://www.giuspen.com/software/cherrytree_0.38.8-0_all.deb
  sudo -S <<< "$1" dpkg -i cherrytree_0.38.8-0_all.deb
  anacondaInstall "$1"
  curl -O https://downloads.slack-edge.com/linux_releases/slack-desktop-3.3.8-amd64.deb
  sudo -S <<< "$1" dpkg -i slack-desktop-3.3.8-amd64.deb
  spotifyInstall "$1"
}

anacondaInstall() {
  cd $HOME/Documents/Programmes
  curl -O https://repo.anaconda.com/archive/Anaconda3-2018.12-Linux-x86_64.sh
  sudo -S <<< "$1" chmod +x Anaconda3-2018.12-Linux-x86_64.sh
  ./Anaconda3-2018.12-Linux-x86_64.sh
  conda install -c anaconda-cluster scala
  conda install -c r r-irkernel rpy2
  conda install jupyter
}

spotifyInstall() {
  sudo -S <<< "$1" apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
  echo deb http://repository.spotify.com stable non-free | sudo -S <<< "$1" tee /etc/apt/sources.list.d/spotify.list
  sudo -S <<< "$1" apt-get update
  sudo -S <<< "$1" apt-get install spotify-client
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
