source "${BASH_SOURCE%/*}"/../setup.sh

X="expand(\"<sfile>\"), expand(\"<slnum>\")"

cat >>$vimtestdir/test.vim <<EOL

function! CreateScene(scene, mode)
	if len(v:errors)
		return
	endif
	execute("normal! \<esc>ggdG")
	let @" = a:scene
	execute("normal! p")
	if a:mode == "visual"
		execute("normal! gg/<\<CR>xm</>\<CR>hxphxm>gv")
	elseif a:mode == "inv-visual"
		execute("normal! gg/<\<CR>xm>/>\<CR>hxphxm<gv")
	else
		execute("normal! gg/<\<CR>x/>\<CR>hxphx")
	endif
	redraw
endfunction

function! Assert(exp, got, msg, sfile, slnum)
	if a:exp != a:got
		let v:errors += [a:sfile . ' line ' . a:slnum . ': ' . a:msg . '. Expected ' . string(a:exp) . ' but got ' . string(a:got)]
	endif
endfunction

function! AssertScene(scene, mode, sfile, slnum)
	if len(v:errors)
		return
	endif
	let actual = [getpos("v"), getpos("."), mode(), getline(line('.'), line('$'))]
	call CreateScene(a:scene, a:mode)
	let expected = [getpos("v"), getpos("."), mode(), getline(line('.'), line('$'))]
	call Assert(expected[0], actual[0], "\"v\"", a:sfile, a:slnum)
	call Assert(expected[1], actual[1], "\".\"", a:sfile, a:slnum)
	call Assert(expected[2], actual[2], "\"mode\"", a:sfile, a:slnum)
	call Assert(expected[3], actual[3], "\"text\"", a:sfile, a:slnum)
endfunction

"embedded paranthesis'
call CreateScene("foo(<a>b, ab, (ab, ab, (ab), ab), ab)", "normal")
call MoveForward(1)
call AssertScene("foo(ab, <a>b, (ab, ab, (ab), ab), ab)", "normal", $X)
call MoveForward(1)
call AssertScene("foo(ab, ab, <(>ab, ab, (ab), ab), ab)", "normal", $X)
call MoveForward(1)
call AssertScene("foo(ab, ab, (ab, ab, (ab), ab), <a>b)", "normal", $X)
call MoveForward(1)
call AssertScene("foo(ab, ab, (ab, ab, (ab), ab), <a>b)", "normal", $X)
call MoveBackward(1)
call AssertScene("foo(ab, ab, <(>ab, ab, (ab), ab), ab)", "normal", $X)
call MoveBackward(1)
call AssertScene("foo(ab, <a>b, (ab, ab, (ab), ab), ab)", "normal", $X)
call MoveBackward(1)
call AssertScene("foo(<a>b, ab, (ab, ab, (ab), ab), ab)", "normal", $X)
call MoveBackward(1)
call AssertScene("foo(<a>b, ab, (ab, ab, (ab), ab), ab)", "normal", $X)

"ultra short
call CreateScene("(<,>,(,,(),),)", "normal")
call MoveForward(1)
call AssertScene("(,<,>(,,(),),)", "normal", $X)
call MoveForward(1)
call AssertScene("(,,<(>,,(),),)", "normal", $X)
call MoveForward(1)
call AssertScene("(,,(,,(),),<)>", "normal", $X)
call MoveForward(1)
call AssertScene("(,,(,,(),),<)>", "normal", $X)
call MoveBackward(1)
call AssertScene("(,,<(>,,(),),)", "normal", $X)
call MoveBackward(1)
call AssertScene("(,<,>(,,(),),)", "normal", $X)
call MoveBackward(1)
call AssertScene("(<,>,(,,(),),)", "normal", $X)
call MoveBackward(1)
call AssertScene("(<,>,(,,(),),)", "normal", $X)

" Move with count:
call CreateScene("(<a>a,bb,cc,dd)", "normal")
call MoveForward(2)
call AssertScene("(aa,bb,<c>c,dd)", "normal", $X)
call MoveForward(2)
call AssertScene("(aa,bb,cc,<d>d)", "normal", $X)
call MoveForward(2)
call AssertScene("(aa,bb,cc,<d>d)", "normal", $X)
call MoveBackward(2)
call AssertScene("(aa,<b>b,cc,dd)", "normal", $X)
call MoveBackward(2)
call AssertScene("(<a>a,bb,cc,dd)", "normal", $X)
call MoveBackward(2)
call AssertScene("(<a>a,bb,cc,dd)", "normal", $X)

"multi line
call CreateScene("(\n\t<a>a,\n\tbb,\n\tcc,\n\tdd\n)", "normal")
call MoveForward(1)
call AssertScene("(\n\taa,\n\t<b>b,\n\tcc,\n\tdd\n)", "normal", $X)
call MoveForward(1)
call AssertScene("(\n\taa,\n\tbb,\n\t<c>c,\n\tdd\n)", "normal", $X)
call MoveForward(1)
call AssertScene("(\n\taa,\n\tbb,\n\tcc,\n\t<d>d\n)", "normal", $X)
call MoveForward(1)
call AssertScene("(\n\taa,\n\tbb,\n\tcc,\n\t<d>d\n)", "normal", $X)
call MoveBackward(1)
call AssertScene("(\n\taa,\n\tbb,\n\t<c>c,\n\tdd\n)", "normal", $X)
call MoveBackward(1)
call AssertScene("(\n\taa,\n\t<b>b,\n\tcc,\n\tdd\n)", "normal", $X)
call MoveBackward(1)
call AssertScene("(\n\t<a>a,\n\tbb,\n\tcc,\n\tdd\n)", "normal", $X)
call MoveBackward(1)
call AssertScene("(\n\t<a>a,\n\tbb,\n\tcc,\n\tdd\n)", "normal", $X)

"multi line v2
call CreateScene("(\n\t<a>a\n\t, bb\n\t, cc\n\t, dd\n)", "normal")
call MoveForward(1)
call AssertScene("(\n\taa\n\t, <b>b\n\t, cc\n\t, dd\n)", "normal", $X)
call MoveForward(1)
call AssertScene("(\n\taa\n\t, bb\n\t, <c>c\n\t, dd\n)", "normal", $X)
call MoveForward(1)
call AssertScene("(\n\taa\n\t, bb\n\t, cc\n\t, <d>d\n)", "normal", $X)
call MoveForward(1)
call AssertScene("(\n\taa\n\t, bb\n\t, cc\n\t, <d>d\n)", "normal", $X)
call MoveBackward(1)
call AssertScene("(\n\taa\n\t, bb\n\t, <c>c\n\t, dd\n)", "normal", $X)
call MoveBackward(1)
call AssertScene("(\n\taa\n\t, <b>b\n\t, cc\n\t, dd\n)", "normal", $X)
call MoveBackward(1)
call AssertScene("(\n\t<a>a\n\t, bb\n\t, cc\n\t, dd\n)", "normal", $X)
call MoveBackward(1)
call AssertScene("(\n\t<a>a\n\t, bb\n\t, cc\n\t, dd\n)", "normal", $X)

"no bounds
call CreateScene("<a>a,bb,cc,dd", "normal")
call MoveForward(1)
call AssertScene("aa,<b>b,cc,dd", "normal", $X)
call MoveForward(1)
call AssertScene("aa,bb,<c>c,dd", "normal", $X)
call MoveForward(1)
call AssertScene("aa,bb,cc,<d>d", "normal", $X)
call MoveForward(1)
call AssertScene("aa,bb,cc,<d>d", "normal", $X)
call MoveBackward(1)
call AssertScene("aa,bb,<c>c,dd", "normal", $X)
call MoveBackward(1)
call AssertScene("aa,<b>b,cc,dd", "normal", $X)
call MoveBackward(1)
call AssertScene("aa,<b>b,cc,dd", "normal", $X)

"no bounds, with count
call CreateScene("<a>a,bb,cc,dd", "normal")
call MoveForward(2)
call AssertScene("aa,bb,<c>c,dd", "normal", $X)
call MoveForward(2)
call AssertScene("aa,bb,cc,<d>d", "normal", $X)
call MoveForward(2)
call AssertScene("aa,bb,cc,<d>d", "normal", $X)
call MoveBackward(1)
call AssertScene("aa,bb,<c>c,dd", "normal", $X)
call MoveBackward(2)
call AssertScene("aa,<b>b,cc,dd", "normal", $X)
call MoveBackward(2)
call AssertScene("aa,<b>b,cc,dd", "normal", $X)

call CreateScene("(aaa,b<b>b)", "normal")
call MoveForward(1)
call AssertScene("(aaa,b<b>b)", "normal", $X)
call CreateScene("(a<a>a,bbb)", "normal")
call MoveBackward(1)
call AssertScene("(a<a>a,bbb)", "normal", $X)

call CreateScene("(aaa, bbb, c<c>c, ddd, eee)", "visual")
call MoveForwardVisual(1)
call AssertScene("(aaa, bbb,< ccc,> ddd, eee)", "visual", $X)
call MoveForwardVisual(1)
call AssertScene("(aaa, bbb,< ccc, ddd,> eee)", "visual", $X)
call MoveForwardVisual(1)
call AssertScene("(aaa, bbb<, ccc, ddd, eee>)", "visual", $X)
call MoveForwardVisual(1)
call AssertScene("(aaa, bbb<, ccc, ddd, eee>)", "visual", $X)
call MoveBackwardVisual(1)
call AssertScene("(aaa, bbb,< ccc, ddd,> eee)", "visual", $X)
call MoveBackwardVisual(1)
call AssertScene("(aaa, bbb,< ccc,> ddd, eee)", "visual", $X)

call CreateScene("(,,<,>,,)", "visual")
call MoveForwardVisual(1)
call AssertScene("(,,<,,>,)", "visual", $X)
call MoveForwardVisual(1)
call AssertScene("(,,<,,,>)", "visual", $X)
call MoveForwardVisual(1)
call AssertScene("(,,<,,,>)", "visual", $X)

call CreateScene("(aaa, bbb, c<c>c, ddd, eee)\n(,,,,,,,,,,,,,,,,)", "visual")

EOL

HOME=$vimtestdir vim -X a.txt

popd > /dev/null
source "${BASH_SOURCE%/*}"/../tear_down.sh
exit 0

syntax match CursorMarker /\(<\|>\)/ conceal contained
syntax match Cursor /<.*>/ contained contains=CursorMarker
set conceallevel=2
syntax region CursorFuncInner matchgroup=CursorFunc start="\(Create\|Assert\)Scene(\"" end="\",.*)" contains=Cursor
hi link CursorFunc vimUserFunc
hi link CursorFuncInner vimString
hi link Cursor vimTodo

vim:tw=78:ts=4:ft=vim:
