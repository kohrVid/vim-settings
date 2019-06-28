#!/bin/bash

main() {
  sudo apt-get update
  sudo apt-get install git clamav ssh make rsync gnupg2
  mkdir -p ~/Documents/go ~/Documents/Programmes ~/Documents/vim
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

  clamScan "$RUN_SCAN"
  gitConfig "$GIT_NAME" "$GIT_EMAIL"
  goInstall "1.12.1"
  vimConfig
  tmuxInstall
  terraformInstall
  rubyInstall "$INSTALL_RUBY"
  scalaInstall "$INSTALL_SCALA"
  dockerInstall "$INSTALL_DOCKER"

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
    git config --system core.editor vim
    mv config/gitignore_global ~/.gitignore_global
    git config --global core.excludesfile ~/.gitignore_global
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
  nodeInstall
  cd ~/Documents/vim

  (git clone https://github.com/vim/vim.git;
  cd vim/src;
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
      sudo apt-get install bison
      alias yacc="bison"
  fi

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

rubyInstall() {
  if [ `echo "$1" | awk '{print toupper($0)}'` = "Y" ]
  then
    cd ~/Documents/Programmes/
    echo "Installing ruby...."
    gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    \curl -sSL https://get.rvm.io | bash -s stable --rails
    source ~/.bashrc
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
    cd ~/Documents/Programmes/
    echo "Installing scala...."
    sudo apt-get install default-jre default-jdk
    curl -O https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz
    sudo tar xvf openjdk-11.0.1_linux-x64_bin.tar.gz --directory /usr/lib/jvm/
    /usr/lib/jvm/jdk-11.0.1/bin/java -version
    java_home="export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\nexport PATH=\$JAVA_HOME/bin/:\$PATH"
    echo $java_home >> ~/.bashrc
    sudo echo $java_home >> /etc/environment
    sudo apt-get install scala
    echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
    sudo apt-get update
    sudo apt-get install sbt
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

  mkdir -p ~/.cache/metals
  touch ~/.cache/metals/bsp.trace.json
}

nodeInstall() {
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
  source ~/.nvm/nvm.sh
  nvm install --lts
  nvm use --lts
}

terraformInstall() {
  cd ~/Documents/Programmes
  curl -O https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
  unzip terraform_0.11.13_linux_amd64.zip
  sudo ln -s $HOME/Documents/Programmes/terraform /usr/bin/terraform
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/wata727/tflint/v0.7.5/install_linux.sh)"
}

dockerInstall() {
  if [ `echo "$1" | awk '{print toupper($0)}'` = "Y" ]
  then
    sudo apt-get -y remove docker docker-engine docker.io containerd runc
    sudo apt-get -y update

    sudo apt-get -y install \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg-agent \
      software-properties-common

    curl -fsSL https://download.docker.com/linux/`whatIsMyDistro`/gpg | sudo apt-key add -

    sudo add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/`whatIsMyDistro` \
     $(lsb_release -cs) \
     stable"

    sudo apt-get -y update
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io
  else
    echo "Skipping docker installation"
  fi
}

postGNOMEInstall() {
  cd ~/Documents/Programmes
  sudo apt-get install conky
  cp ~/Documents/vim/vim-settings/config/conkyrc ~/.conkyrc
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  cp ~/Documents/vim/vim-settings/config/zshrc ~/.zshrc
  guiAppInstall
}

guiAppInstall() {
  cd ~/Documents/Programmes
  curl -O http://www.giuspen.com/software/cherrytree_0.38.8-0_all.deb
  sudo dpkg -i cherrytree_0.38.8-0_all.deb
  anacondaInstall
  curl -O https://downloads.slack-edge.com/linux_releases/slack-desktop-3.3.8-amd64.deb
  sudo dpkg -i slack-desktop-3.3.8-amd64.deb
  spotifyInstall
}

anacondaInstall() {
  cd ~/Documents/Programmes
  curl -O https://repo.anaconda.com/archive/Anaconda3-2018.12-Linux-x86_64.sh
  sudo chmod +x Anaconda3-2018.12-Linux-x86_64.sh
  ./Anaconda3-2018.12-Linux-x86_64.sh
  conda install -c anaconda-cluster scala
  conda install -c r r-irkernel rpy2
  conda install jupyter
}

spotifyInstall() {
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
  echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
  sudo apt-get update
  sudo apt-get install spotify-client
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
