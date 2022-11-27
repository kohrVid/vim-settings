if [ ! -f ~/.vim/autoload/pathogen.vim ]
then
  mkdir -p ~/.vim/autoload
  curl -o ~/.vim/autoload/pathogen.vim https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim
  mkdir -p ~/.vim/plugged
  mkdir -p ~/.vim/colors
  cp colours/* ~/.vim/colors/
  cp ./config/vimrc ~/.vimrc
  cp ./config/coc-settings.json ~/.vim/coc-settings.json
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
  echo "Pathogen file present. Please manually add vimrc and colours scheme where needed."
fi

vim +PlugInstall +"CocInstall coc-python" +PlugClean! +qall
(vim -u NONE -c "helptags vim-rhubarb/doc" -c q;)

if [ ! -d ~/.vim/ftdetect ]
  then
    mkdir -p ~/.vim/{ftdetect,indent,syntax}
    for d in ftdetect indent syntax ; do
      curl -o ~/.vim/$d/scala.vim https://raw.githubusercontent.com/derekwyatt/vim-scala/master/$d/scala.vim
    done
fi

if [[ -z $(which pt) ]]
  then
    OS=$(uname)
    case $OS in
      'Linux')
        if [[ -n $GOPATH ]]
        then
          vim +GoInstallBinaries +qall
          mkdir -p $GOPATH/src/github.com/monochromegane/
          cd $GOPATH/src/github.com/monochromegane/
          git clone https://github.com/monochromegane/the_platinum_searcher.git
          cd the_platinum_searcher
          go mod init
          go install -v ./...
        else
          echo "Please set and export your GOPATH before trying again"
        fi
        ;;
      'Darwin')
        brew update && brew install pt
        ;;
      *)
        echo "Please install PlatinumSearcher for $OS"
        ;;
    esac
fi
