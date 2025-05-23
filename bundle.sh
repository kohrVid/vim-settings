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
vim +PlugInstall +"CocInstall coc-pairs" +PlugClean! +qall
vim +PlugInstall +"CocInstall coc-solargraph" +PlugClean! +qall
vim +PlugInstall +"CocInstall coc-tsserver" +PlugClean! +qall
(vim -u NONE -c "helptags vim-rhubarb/doc" -c q;)

if [ ! -d ~/.vim/ftdetect ]
  then
    mkdir -p ~/.vim/{ftdetect,indent,syntax}
    for d in ftdetect indent syntax ; do
      curl -o ~/.vim/$d/scala.vim https://raw.githubusercontent.com/derekwyatt/vim-scala/master/$d/scala.vim
    done
fi
