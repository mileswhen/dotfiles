" A simple, lightweight neovim config for academics, Python and c/c++ development
" author @mileswhen
" last edit: 10/09/2022
"{{{ Editor behavior and appearance
set encoding=utf8
set mouse=a
set foldmethod=marker
set clipboard^=unnamed,unnamedplus "sync system and unamed clipboards
autocmd FileType cpp setlocal cinoptions+=L0 "disable automatic label dedent
set expandtab "autoexpand tabs to spaces
syntax on
set number relativenumber
set cursorline
"}}}

"{{{ Plugins
call plug#begin('~/.config/nvim/plugged') 
Plug 'joshdick/onedark.vim' "Neovim theme
Plug 'itchyny/lightline.vim' "lightline vim
Plug 'ap/vim-css-color', {'for': ['html', 'css', 'sass', 'scss']} "higlight css colors (optional)
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']} "markdown preview (preview markdown files in the browser) (lazy loading for .md)
Plug 'tpope/vim-fugitive' "git integration
Plug 'kyazdani42/nvim-tree.lua', {'on': 'NvimTreeToggle'} "browse files
Plug 'kyazdani42/nvim-web-devicons' " optional, for file icons in nvim-tree
Plug 'neovim/nvim-lspconfig'
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'} "completion engine
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'} "snippets
Plug 'folke/trouble.nvim' "diagnostics
call plug#end()
"}}}

"{{{ LSP config for completion
lua <<EOF
vim.g.coq_settings = {auto_start = 'shut-up'}

require'lspconfig'.pyright.setup{}
local lsp = require "lspconfig"
local coq = require("coq")
lsp.cssls.setup(coq.lsp_ensure_capabilities())
lsp.cssls.setup(coq().lsp_ensure_capabilities())

-- lspconfig bindings
local bufopts = { noremap=true, silent=true, buffer=bufnr }
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
vim.keymap.set('n', '<space>wl', function()
print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, bufopts)
vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)

-- only show warnings
vim.diagnostic.config({
  virtual_text = false,
  signs = {severity = {min = vim.diagnostic.severity.WARN}},
  underline = {severity = {min = vim.diagnostic.severity.WARN}}
})

-- trouble for diagnostics
require'trouble'.setup{
  position = "bottom",
  mode = "document_diagnostics",
}
EOF
"}}}

"{{{ Colors and aesthetics
"onedark
if (has("autocmd"))
  augroup colorextend
    autocmd!
    " Make comment gray lighter 
    autocmd ColorScheme * call onedark#extend_highlight("Comment", { "fg":{"gui": "#848d9c"}})
  augroup END
endif

colorscheme onedark
"}}}

"{{{ Nvim tree
lua << EOF
require("nvim-tree").setup({
  renderer = {
    icons = {
      show = {file=false, folder=false, folder_arrow=false}
    }
  }
}
)
EOF
"}}}

"{{{ Start screen
"{{{2 Startify
""center header
"let g:startify_custom_header =
"  \ 'startify#center(startify#fortune#cowsay())'
"
"highlight StartifyHeader guifg=#d19a66
"
"let g:startify_lists = [
"  \ { 'type': 'commands',  'header': ['   Commands']       },
"  \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
"  \ { 'type': 'files',     'header': ['   Recent']         },
"  "\ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
"  "\ { 'type': 'sessions',  'header': ['   Sessions']       },
"  \ ]
"
"let g:startify_bookmarks = [
"  \ '~/Library/Mobile\ Documents/com~apple~CloudDocs/Notes', 
"  \ '~/Documents/Classes',
"  \ ]
"
"let g:startify_commands = [
"  \ ['New journal entry', 'call JournalEntry()'],
"  \ ]
"
"let g:startify_custom_header_quotes =
"      \ startify#fortune#predefined_quotes() + [['quote 1', 'quote 2']]
"}}}2
"}}}

"{{{ Mappings
"leader
let mapleader = ";"

"comments out code in visual mode
vnoremap <leader>h :norm i# <CR>

"nvimtree
nmap <silent> <C-t> :NvimTreeToggle<CR>

"markdown 
nmap <C-p> <Plug>MarkdownPreviewToggle
command Md2pdf !pandoc -s -o %:r.pdf %
map md2pdf :Md2pdf

"split-pane navigation
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

"compile and run C++
command Clang !clang++ % -o %:r
command ClangRun !clang++ % -o %:r && ./%:r
nnoremap cppr :ClangRun
command Gpprun !g++ -std=c++11 % -o %:r && ./%:r
nnoremap gppr :Gpprun

"{{{2 Code completion (COC)

"Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by another plugin.
"inoremap <silent><expr> <TAB>
"inoremap <silent><expr> <TAB>
"      \ pumvisible() ? "\<C-n>" :
"      \ <SID>check_back_space() ? "\<TAB>" :
"      \ coc#refresh()
"inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
"
"" Used in the tab autocompletion for coc
"function! s:check_back_space() abort
"  let col = col('.') - 1
"  return !col || getline('.')[col - 1]  =~# '\s'
"endfunction
"
"" expand coc-snippet
"imap <C-l> <Plug>(coc-snippets-expand)
"
"" Highlight the symbol and its references when holding the cursor.
"autocmd CursorHold * silent call CocActionAsync('highlight')
"
"" Use K to show documentation in preview window.
"nnoremap <silent> K :call ShowDocumentation()<CR>
"
"function! ShowDocumentation()
"  if CocAction('hasProvider', 'hover')
"    call CocActionAsync('doHover')
"  else
"    call feedkeys('K', 'in')
"  endif
"endfunction
"}}}2
"}}}

"{{{ Functions

"create file in notes directory
function JournalEntry()
  execute "e " . "~/Library/Mobile Documents/com~apple~CloudDocs/Notes/" . strftime("%Y%m%d") . ".md"
endfunction
"}}}

