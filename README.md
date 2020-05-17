# fozzie.vim

## Installation

Install using your preferred vim plugin manager.

## Usage

#### NeoVim

```
" arguments -> (choice command, vim command, height of window, any extra args to pass to fozzie)
nnoremap <leader>e :call FozzieCommand("find . -type f", ":e", 15, "--lines=15")<cr>
nnoremap <leader>v :call FozzieCommand("find . -type f", ":vs", 15, "--lines=15")<cr>
nnoremap <leader>s :call FozzieCommand("find . -type f", ":sp", 15, "--lines=15")<cr>
nnoremap <leader>t :call FozzieCommand("find . -type f", ":tabe", 15, "--lines=15")<cr>

" You could also fuzzy search by ctags in the current file
nnoremap <leader>r :call FozzieCommand('ctags -f - --sort=no --excmd=number ' . expand('%:p'), ":", 15, "split --delimiter=\"\t\" -f0 -o2")<cr>
```

#### Vim

```
" arguments -> (choice command, vim command, any extra args to pass to fozzie)
nnoremap <leader>e :call FozzieCommand("find . -type f", ":e", "--lines=15")<cr>
nnoremap <leader>v :call FozzieCommand("find . -type f", ":vs", "--lines=15")<cr>
nnoremap <leader>s :call FozzieCommand("find . -type f", ":sp", "--lines=15")<cr>
nnoremap <leader>t :call FozzieCommand("find . -type f", ":tabe", "--lines=15")<cr>

" You could also fuzzy search by ctags in the current file
nnoremap <leader>r :call FozzieCommand('ctags -f - --sort=no --excmd=number ' . expand('%:p'), ":", "split --delimiter=\"\t\" -f0 -o2")<cr>
```
