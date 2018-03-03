ROOT=$PWD
vimtestdir=$(mktemp -d)
mkdir $vimtestdir/.vim
cp -r ~/.vim/bundle/list_item_motion.vim/* $vimtestdir/.vim

succes_cmd=${succes_cmd:-"echom \"unittest succeded\""}

cat >$vimtestdir/.vimrc <<EOL
syntax on
set laststatus=2
set statusline=
set statusline +=%4*\ %t%*            "filename
set statusline +=%2*%m%r%w%*          "modified flag, read only,
set statusline +=\ UNITTESTING\ $0
set statusline +=%=
set statusline +=\ %1*line:\ %l%*     "current line
set statusline +=%2*/%L,\ \ %*        "total lines
set statusline +=%1*row:\ %c\ %*      "virtual column number
set errorformat=%f\ line\ %l:\ %m
nnoremap q :qall!<CR>
set tabstop=4
set aw

call timer_start(500, {-> <SID>Test()})

function! s:Test()
	source test.vim
	cgetexpr v:errors
	if len(v:errors)
		copen
	else
		$succes_cmd
	endif
endfunction

EOL

pushd $vimtestdir > /dev/null

return
vim:tw=78:ts=4:ft=vim:
