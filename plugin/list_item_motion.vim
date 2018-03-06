
let s:quotes=["\"\"", "''"]
let s:brachets=["()", "[]", "{}"]
" comment

function! s:CharUnderCursor()
	let col = col(".")
	let line = getline(".")
	return line[col-1]
endfunction

function! s:IsComment()
	return synIDtrans(synID(line("."), col("."), 1)) == hlID('Comment')
endfunction

function! s:IsString()
	let linenum = line(".")
	let col = col(".")
	let line = getline(linenum)
	let quote_state = ""
	for r in range(col-1)
		let c = line[r]
		if quote_state != "" && c == quote_state
			let quote_state = ""
		elseif quote_state == ""
			for q in s:quotes
				if c == q[1]
					let quote_state = q[0]
				endif
			endfor
		endif
	endfor
	return quote_state
endfunction


function! s:MoveOneForward()
	"move cursor to last char in current item
	let brachet_state = ""
	let opt = "cW"
	while(1)
		let f = search('\((\|)\|\[\|]\|{\|}\|,\)', opt)
		let opt = "W"
		if f
			if <SID>IsComment() || <SID>IsString() != ""
			else
				let c = <SID>CharUnderCursor()
				if c == ',' && brachet_state == ""
					return ','
				elseif c == ')' || c == ']' || c == '}'
					if brachet_state != ""
						let brachet_state = brachet_state[:-2]
					else
						return ')'
					endif
				elseif c == '(' || c == '[' || c == '{'
					let brachet_state .= c
				endif
			endif
		else
			return ' '
		endif
	endwhile
endfunction

function! s:MoveOneBackward()
	"move cursor to last char in previous item
	let brachet_state = ""
	let opt = "bW"
	while(1)
		let f = search('\((\|)\|\[\|]\|{\|}\|,\)', opt)
		if f
			if <SID>IsComment() || <SID>IsString() != ""
			else
				let c = <SID>CharUnderCursor()
				if c == ',' && brachet_state == ""
					return ','
				elseif c == '(' || c == '[' || c == '{'
					if brachet_state != ""
						let brachet_state = brachet_state[:-2]
					else
						return '('
					endif
				elseif c == ')' || c == ']' || c == '}'
					let brachet_state .= c
				endif
			endif
		else
			return ' '
		endif
	endwhile
endfunction

function! MoveForward(count1)
	let c = a:count1
	while (c)
		let curpos = getcurpos()[1:]
		let x = s:MoveOneForward()
		if x == ','
			let c = c - 1
			call search('\S', "W")
		else
			call cursor(curpos)
			break
		endif
	endwhile
	return
endfunction

function! MoveBackward(count1)
	let c = a:count1
	while (c)
		let curpos = getcurpos()[1:]
		let x = s:MoveOneBackward()
		if x == ','
			let x = s:MoveOneBackward()
			if x == ',' || x == '('
				let c = c - 1
				call search('\S', "W")
			elseif x == '('
				call search('\S', "W")
				break
			else
				call cursor(curpos)
				return
			endif
		else
			call cursor(curpos)
			break
		endif
	endwhile
	return
endfunction

function! MoveForwardVisual(count1)
	execute("normal! gv")
	let col0 = col(".")
	let line0 = line(".")
	let col1 = col("v")
	let line1 = line("v")
	if line0 < line1 || (line0 == line1 && col0 < col1)
		"echom "reverse range"
		execute("normal! o")
		call <SID>BeginVisual()
		call s:MoveOneForward()
		execute("normal! o")
		call s:MoveOneForward()
		call search('.', "W")
		call <SID>EndVisual()
	else
		"echom "normal range"
		call <SID>BeginVisual()
		call search('.', "W")
		call s:MoveOneForward()
		execute("normal! o")
		call s:MoveOneBackward()
		call search('.', "W")
		execute("normal! o")
		call <SID>EndVisual()
	endif
endfunction

function! MoveBackwardVisual(count1)
	execute("normal! gv")
	let col0 = col(".")
	let line0 = line(".")
	let col1 = col("v")
	let line1 = line("v")
	if line0 < line1 || (line0 == line1 && col0 < col1)
		"echom "reverse range"
		execute("normal! o")
		call <SID>BeginVisual()
		call s:MoveOneForward()
		execute("normal! o")
		call search('.', "bW")
		call s:MoveOneBackward()
		call search('.', "W")
		call <SID>EndVisual()
	else
		"echom "normal range"
		call <SID>BeginVisual()
		call s:MoveOneBackward()
		execute("normal! o")
		call s:MoveOneBackward()
		call search('.', "W")
		execute("normal! o")
		call <SID>EndVisual()
	endif
endfunction

function! s:BeginVisual()
	"execute("normal! gv")
	call search('.', "W")
	let e = <SID>CharUnderCursor()
	if e == ")" || e == "]" || e == "}"
		execute("normal! o")
		let b = <SID>CharUnderCursor()
		if b == ","
			call search('.', "W")
		endif
		execute("normal! o")
	else
		call search('.', "bW")
	endif
endfunction

function! s:EndVisual()
	"execute("normal! gv")
	let e = <SID>CharUnderCursor()
	if e == ")" || e == "]" || e == "}"
		call search('.', "bW")
		execute("normal! o")
		call search('.', "bW")
		let b = <SID>CharUnderCursor()
		if b == ","
		else
			call search('.', "W")
		endif
		execute("normal! o")
	endif
endfunction

function! s:Foo()
	call Foo(1234, 1234 , ")", (34,35), hej)
	call Foo(,,,,,,,,,)
	echom "quote_state = '" . <SID>IsString() . "'"
	echom "is comment: " . <SID>IsComment()
	echom search('\((\|)\|\[\|]\|{\|}\)', "bW")
	echom <SID>CharUnderCursor()
endfunction

function! Delete(count1)
	let curpos = getcurpos()[1:]
	let x = s:MoveOneBackward()
	if x == ',' || x == '('
		call search('.', "W")
		execute("normal! v")
		let c = a:count1
		while (c)
			let curpos = getcurpos()[1:]
			call search('.', "W")
			let x = s:MoveOneForward()
			if x == ','
				let c = c - 1
			else
				call cursor(curpos)
				break
			endif
		endwhile
	else
		call cursor(curpos)
	endif
endfunction

nnoremap <silent> <esc>z :<C-U>call MoveForward(v:count1)<CR>
nnoremap <silent> <esc>Z :<C-U>call MoveBackward(v:count1)<CR>
nnoremap <silent> y<esc>z :<C-U>call Yank(v:count1)<CR>
nnoremap <silent> y<esc>Z :<C-U>call YankBackwards(v:count1)<CR>
nnoremap <silent> d<esc>z :<C-U>call Delete(v:count1)<CR>
nnoremap <silent> d<esc>Z :<C-U>call DeleteBackwards(v:count1)<CR>
nnoremap <silent> zp :<C-U>call PutAfter(v:count1)<CR>
nnoremap <silent> zP :<C-U>call PutBefore(v:count1)<CR>
vnoremap <silent> <esc>z :<C-U>call MoveForwardVisual(v:count1)<CR>
vnoremap <silent> <esc>Z :<C-U>call MoveBackwardVisual(v:count1)<CR>
"vnoremap <silent> <esc>x :<C-U>call <SID>BeginVisual()<CR>
"vnoremap <silent> <esc>X :<C-U>call <SID>EndVisual()<CR>
" use 'o' in visual mode to go to the other end of visually selection
