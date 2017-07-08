execute pathogen#infect()
syntax on
filetype plugin indent on
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
inoremap <S-Tab> <C-D>
vnoremap > >gv
vnoremap < <gv
autocmd vimenter * NERDTree

:silent !mkdir %:p:h

set nu
set t_Co=256
set ruler
colorscheme tyk

let g:colorscheme_switcher_exclude = ["default", "dw_red", "murphy", "koehler", "morning", "pablo", "peachpuff", "ron", "shine", "slate", "torte", "zellner", "blue", "darkblue", "delek", "desert", "elflord", "evening", "industry"]

let g:NERDTreeWinSize=20
let g:user_emmet_settings = { "haml" : { "extends" : "html" }, "erb" : { "extends" : "html" } }
let g:html_indent_inctags = "html,body,head,tbody,p"
let g:go_fmt_command = "goimports"
let g:EasyMotion_leader_key = "<Leader>"
"in vagrant, use:
"let g:NERDTreeDirArrowExpandable = '►' "'>>'
"let g:NERDTreeDirArrowCollapsible = '▼'

set shiftwidth=2
"set tabstop=3
set softtabstop=2
set expandtab
set backspace=2 " make backspace work like most other apps (Mac only)
"set completeopt=longest,menu,preview
"filetype plugin on
set omnifunc=syntaxcomplete#Complete
"In Debian based systems, use:
"set clipboard=unnamedplus
set runtimepath^=~/.vim/bundle/ctrlp.vim

au FileType php setl ofu=phpcomplete#CompletePHP
au FileType ruby,eruby setl ofu=rubycomplete#Complete
au FileType html,xhtml setl ofu=htmlcomplete#CompleteTags
au FileType c setl ofu=ccomplete#CompleteCpp
au FileType css setl ofu=csscomplete#CompleteCSS
au BufNewFile,BufRead *.handlebars set filetype=html
autocmd BufNewFile,BufRead *.md set filetype=markdown
autocmd FileType text,markdown let b:vcm_tab_complete = 'dict'
