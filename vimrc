execute pathogen#infect()
colorscheme tyk
let g:colorscheme_switcher_exclude = ["default", "dw_red", "murphy", "koehler", "morning", "pablo", "peachpuff", "ron", "shine", "slate", "torte", "zellner", "blue", "darkblue", "delek", "desert", "elflord", "evening", "industry"]
syntax on
autocmd vimenter * NERDTree

set backspace=2 " make backspace work like most other apps (Mac only)
set expandtab
set nu
set paste
set ruler
set shiftwidth=2
set softtabstop=2
set t_Co=256
"set completeopt=longest,menu,preview
set omnifunc=syntaxcomplete#Complete
set runtimepath^=~/.vim/bundle/ctrlp.vim
"In Debian based systems, use:
"set clipboard=unnamedplus
let g:NERDTreeWinSize=30

silent! mkdir %:p:h

let g:EasyMotion_leader_key = "<Leader>"
let g:go_fmt_command = "goimports"
let g:html_indent_inctags = "html,body,head,tbody,p"
let g:user_emmet_settings = { "haml" : { "extends" : "html" }, "erb" : { "extends" : "html" } }
"in vagrant, use:
"let g:NERDTreeDirArrowExpandable = '►' "'>>'
"let g:NERDTreeDirArrowCollapsible = '▼'
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

filetype plugin indent on
inoremap <S-Tab> <C-D>
nnoremap <S-Tab> <<_
nnoremap <Tab> >>_
vnoremap < <gv
vnoremap > >gv

au BufNewFile,BufRead *.handlebars set filetype=html
au BufNewFile,BufRead *.md set filetype=markdown
au FileType c setl ofu=ccomplete#CompleteCpp
au FileType css setl ofu=csscomplete#CompleteCSS
au FileType html,xhtml setl ofu=htmlcomplete#CompleteTags
au FileType php setl ofu=phpcomplete#CompletePHP
au FileType ruby,eruby setl ofu=rubycomplete#Complete
au FileType text,markdown let b:vcm_tab_complete = 'dict'
