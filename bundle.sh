if [ ! -f ~/.vim/autoload/pathogen.vim ]
then
  mkdir -p ~/.vim/autoload 
  curl -o ~/.vim/autoload/pathogen.vim https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim
  mkdir -p ~/.vim/colors
  cp ./tyk.vim ~/.vim/colors
  cp ./vimrc ~/.vimrc
else
  echo "Pathogen file present. Please manually add vimrc and colours scheme where needed."
fi

test -d "~/.vim/bundle" && echo "Bundle folder present" || mkdir -p ~/.vim/bundle

(cd ~/.vim/bundle;
git clone git://github.com/ajh17/VimCompletesMe.git;
git clone https://github.com/mattn/emmet-vim.git;
git clone https://github.com/claco/jasmine.vim.git;
git clone https://github.com/scrooloose/nerdtree.git;
git clone https://github.com/jwalton512/vim-blade.git;
git clone https://github.com/kchmck/vim-coffee-script.git;
git clone https://github.com/xolox/vim-colorscheme-switcher.git;
git clone https://github.com/fatih/vim-go.git;
git clone https://github.com/briancollins/vim-jst.git;
git clone https://github.com/xolox/vim-misc.git;
git clone git://github.com/uarun/vim-protobuf.git;
git clone https://github.com/vim-ruby/vim-ruby.git;
git clone https://github.com/slim-template/vim-slim.git;
git clone https://github.com/mzlogin/vim-markdown-toc.git;
git clone https://github.com/ctrlpvim/ctrlp.vim.git;
git clone https://github.com/EvanDotPro/nerdtree-chmod.git;
git clone https://github.com/scrooloose/nerdcommenter.git;
git clone https://github.com/tpope/vim-fugitive.git;
git clone https://github.com/gregsexton/gitv.git;
git clone https://github.com/jiangmiao/auto-pairs.git;
git clone https://github.com/easymotion/vim-easymotion.git;
git clone https://github.com/mileszs/ack.vim.git;
)

OS=$(uname)
case $OS in
  'Linux')
    sudo aptitude install silversearcher-ag
    ;;
  'Darwin')
    brew install ag
    ;;
  *)
    echo "Please install SilverSearcher for $OS"
    ;;
esac
