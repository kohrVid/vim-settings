execute pathogen#infect()
syntax on
colorscheme roo
au vimenter * NERDTree
nmap <F6> :NERDTreeToggle<CR>
silent! mkdir %:p:h
let g:NERDTreeWinSize=30
let g:colorscheme_switcher_exclude = ["default", "dw_red", "murphy", "koehler", "morning", "pablo", "peachpuff", "ron", "shine", "slate", "torte", "zellner", "blue", "darkblue", "delek", "desert", "elflord", "evening", "industry"]

set backspace=2 " make backspace work like most other apps (Mac only)
set expandtab
set nu
set omnifunc=syntaxcomplete#Complete
set ruler
set shiftwidth=2
set softtabstop=2
set t_Co=256
"set completeopt=longest,menu,preview
"set runtimepath^=~/.vim/bundle/ctrlp.vim
"In Debian based systems, use:
"set clipboard=unnamedplus

let g:go_fmt_command = "goimports"
let g:html_indent_inctags = "html,body,head,tbody,p"
let g:sneak#label = 1
let g:user_emmet_settings = { "haml" : { "extends" : "html" }, "erb" : { "extends" : "html" } }
"in vagrant, use:
"let g:NERDTreeDirArrowExpandable = '►' "'>>'
"let g:NERDTreeDirArrowCollapsible = '▼'

if executable('ag')
  " Use ag over grep
  set grepprg=pt\ --nogroup\ --nocolor
  let g:ctrlp_user_command = 'pt %s -l --nocolor -g ""'
  let g:ctrlp_use_caching = 0
endif
command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
autocmd QuickFixCmdPost *Ag* silent! cwindow
autocmd QuickFixCmdPost *grep* silent! cwindow
nmap H <C-W><CR><C-W>K<C-W>b
nmap <C-H> <C-W>f
nmap <C-V> <C-W>f<CR><C-W>L<C-W>b<C-W>L<C-W>p
nmap <C-T> <C-W><CR><C-W>T

"Quote/Unquote
vmap Q" :s/\%V"//g<CR>
vmap Q' :s/\%V'//g<CR>
vmap Q( :s/\%V(//g<CR>:s/\%V)//g<CR><CR>
vmap Q< :s/\%V<//g<CR>:s/\%V>//g<CR><CR>
vmap Q[ :s/\%V\[//g<CR>:s/\%V\]//g<CR><CR>
vmap Q{ :s/\%V{//g<CR>:s/\%V}//g<CR><CR>
vmap q" c""<ESC>P
vmap q' c''<ESC>P
vmap q( c()<ESC>P
vmap q< c<><ESC>P
vmap q[ c[]<ESC>P
vmap q{ c{}<ESC>P

filetype plugin indent on
imap <S-Tab> <C-D>
nmap <S-Tab> <<_
nmap <Tab> >>_
vmap < <gv
vmap > >gv

map <F2> :let &cc = &cc == '' ? '80' : ''<CR>
map <F3> :set cursorcolumn!<Bar>set cursorline!<CR>


nmap <silent><Leader>rs :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

au BufNewFile,BufRead *.handlebars set filetype=html
au BufNewFile,BufRead *.md set filetype=markdown
au FileType c setl ofu=ccomplete#CompleteCpp
au FileType css setl ofu=csscomplete#CompleteCSS
au FileType html,xhtml setl ofu=htmlcomplete#CompleteTags
au FileType php setl ofu=phpcomplete#CompletePHP
au FileType ruby,eruby setl ofu=rubycomplete#Complete
au FileType text,markdown let b:vcm_tab_complete = 'dict'
autocmd BufRead,BufNewFile *.sc set filetype=scala
