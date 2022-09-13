set shiftwidth=8
set colorcolumn=80 
let b:ale_linters = ['flake8']
let b:ale_fixers = ['yapf']
let b:ale_warn_about_trailing_whitespace = 0
let g:ale_python_flake8_options = '--max-line-length=80'
let g:ale_python_flake8_options = '--ignore=F401,E231,W503,E251,E226'
