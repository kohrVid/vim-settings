#!/bin/bash

main() {
  echo "[sudo] password for $USER: "
  read -s PASSWORD
  echo "Would you like to configure git? (Y/N)"
  read CONFIGURE_GIT

  if [ `echo "$CONFIGURE_GIT" | awk '{print toupper($0)}'` = "Y" ]
  then
    git_setup $CONFIGURE_GIT
    echo "Please enter your full name..."
    read GIT_NAME
    echo "Please enter your Github email address..."
    read GIT_EMAIL
  fi

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

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

  clamScan "$RUN_SCAN" "$PASSWORD"

  gitConfig "$GIT_NAME" "$GIT_EMAIL" "$PASSWORD"
  goInstall "1.24.2" "$PASSWORD"
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
  brew install clamav
  sudo -S <<< "$2" chmod a+rw /usr/local/Cellar/clamav/0.102.2/share/clamav/
  sudo -S <<< "$2" mkdir -p /usr/local/etc/clamav/

  sudo -S <<< "$2" su
  touch /usr/local/etc/clamav/freshclam.conf
  echo "DatabaseMirror database.clamav.net" >> /opt/homebrew/etc/clamav/freshclam.conf
  exit

  if [ `echo "$1" | awk '{print toupper($0)}'` = "N" ]
  then
    echo "Skipping scan"
  else
    echo "Running scan...."
    sudo -S <<< "$2" mkdir $HOME/clam01
    sudo -S <<< "$2" freshclam
    sudo -S <<< "$2" clamscan --recursive=yes / --move=$HOME/clam01 -l $HOME/clam01.txt
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
    sudo -S <<< "$3" apt-get install kdiff3
    git config --global --add merge.tool kdiff3
    git config --global commit.verbose true
  fi
}

goInstall() {
  cd $HOME/Documents/Programmes/
  curl -O "https://dl.google.com/go/go$1.darwin-amd64.tar.gz"
  sudo -S <<< "$2" tar -C /usr/local -xzf "go$1.darwin-amd64.tar.gz"
  source $HOME/.zshrc
  sudo -S <<< "$2" chown $USER:$USER -R $GOBIN
  go install golang.org/x/tools/gopls@latest
}

vimConfig() {
  nodeInstall
  cd $HOME/Documents/vim
  brew install macvim

  if [ ! -d $HOME/Documents/vim/vim-settings ]
  then
    git clone https://github.com/kohrVid/vim-settings.git;
  fi

  cd vim-settings;
  git remote remove origin;
  git remote add origin git@github.com:kohrVid/vim-settings.git;
  ./bundle.sh
  # vim-gtk and xclip are needed for clipboard support from vim and tmux
  brew install xclip
}

tmuxInstall() {
  brew install tmux

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
    # TODO
    echo "Scala installation not implemented"
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
  #TODO
  echo "Terrafor install not implemented"
}

dockerInstall() {
  if [ `echo "$1" | awk '{print toupper($0)}'` = "Y" ]
  then
    #TODO
    echo "Docker install not implemented"
  else
    echo "Skipping docker installation"
  fi
}

haskellInstall() {
  if [ `echo "$1" | awk '{print toupper($0)}'` = "Y" ]
  then
    brew install ghc
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
  brew install conky
  cp $HOME/Documents/vim/vim-settings/config/conkyrc $HOME/.conkyrc
  cp -R $HOME/Documents/vim/vim-settings/config/conky_lua $HOME/.conky
  guiAppInstall $1
}

guiAppInstall() {
  cd $HOME/Documents/Programmes
  zshInstall "$1"
  anacondaInstall "$1"
  cherryTreeInstall "$1"
}

anacondaInstall() {
  cd $HOME/Documents/Programmes
  curl -O https://repo.anaconda.com/archive/Anaconda3-2020.02-MacOSX-x86_64.sh
  sudo -S <<< "$1" chmod +x ./Anaconda3-2020.02-MacOSX-x86_64.sh
  ./Anaconda3-2020.02-MacOSX-x86_64.sh
  source $HOME/.zshrc
  echo "y" | conda install -c anaconda-cluster scala
  echo "y" | conda install -c r r-irkernel rpy2
  echo "y" | conda install jupyter
  #mv $HOME/anaconda3/compiler_compat/ld $HOME/anaconda3/compiler_compat/ldOld
  echo "y" | conda install -c anaconda psycopg2
}

cherryTreeInstall() {
  cd $HOME/Documents/Programmes
  brew install python3
  pip3 install lxml
  brew install cmake pkg-config gtksourceviewmm3 gnome-icon-theme gspell libxml++ cpputest
  git clone https://github.com/giuspen/cherrytree.git
  mkdir cherrytree/build
  cd cherrytree/build
  cmake ../future
  make -j4
  sudo -S <<< "$PASSWORD" ln -s $HOME/Documents/Programmes/cherrytree/build/cherrytree /usr/local/bin/cherrytree
  sudo -S <<< "$PASSWORD" ln -s $HOME/Documents/Programmes/cherrytree/build/cherrytree /Applications/cherrytree.app
  echo "Remember to add the cherrytree icon maually to $HOME/Documents/Programmes/cherrytree/build/cherrytree with the GetInfo tool in Finder"
}

zshInstall() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  brew tap caskroom/fonts
  brew cask install font-twitter-color-emoji
  sudo -S <<< "$1" brew cask install ttf-bitstream-vera
  cp $HOME/Documents/vim/vim-settings/config/zshrc $HOME/.zshrc
  cp $HOME/Documents/vim/vim-settings/config/zshenv $HOME/.zshenv
}

main
