" Vim global plugin for alignment
" Last Change:	2021 May 11
" Maintainer:	Zhang, Yingqi <zczsyqxl@163.com>
" License:	This file is placed in the public domain.

if exists("g:loaded_vim_alignment")
	finish
endif

let g:loaded_vim_alignment = 1

let s:save_cpo = &cpo
set cpo&vim

if !hasmapto('<Plug>AlignmentViaChar')
	map <unique> <leader>a <Plug>AlignmentViaChar
endif

if !hasmapto('<Plug>AlignmentViaStr')
	map <unique> <leader><leader>a <Plug>AlignmentViaStr
endif

if !hasmapto('<Plug>AlignmentViaStrEnd')
	map <unique> <leader><leader>e <Plug>AlignmentViaStrEnd
endif

vnoremap <unique> <silent> <Plug>AlignmentViaChar  :<c-u>call <SID>Alignment("visual", v:count1)<cr>
nnoremap <unique> <silent> <Plug>AlignmentViaChar  :<c-u>call <SID>Alignment("normal", v:count1)<cr>

vnoremap <unique> <silent> <Plug>AlignmentViaStr  :<c-u>call <SID>Alignment("visual", v:count1, "str")<cr>
nnoremap <unique> <silent> <Plug>AlignmentViaStr  :<c-u>call <SID>Alignment("normal", v:count1, "str")<cr>

vnoremap <unique> <silent> <Plug>AlignmentViaStrEnd  :<c-u>call <SID>Alignment("visual", v:count1, "str", "end")<cr>
nnoremap <unique> <silent> <Plug>AlignmentViaStrEnd  :<c-u>call <SID>Alignment("normal", v:count1, "str", "end")<cr>

let s:maxAlColLast = 0

function! s:Alignment(mode, count, ...)
	if (a:0 ># 0) && (a:1 ==# 'str')
		let l:alStr = input("Please type the string/pattern(very no majic) for alignment: ")
		if (a:0 ># 1) && (a:2 ==# 'end')
			call s:ExecuteAlignment(a:mode, a:count, l:alStr, a:2)
			return
		endif
	else
		let l:alStr = nr2char(getchar())
		if (l:alStr ==# 'm')
			call s:ExecuteAlignment(a:mode, a:count)
			return
		endif
	endif

	call s:ExecuteAlignment(a:mode, a:count, l:alStr)
endfunction

function! s:ExecuteAlignment(mode, count, ...)

	let s:alPos = {}
	let s:maxAlClo = 0

	if (a:mode ==# 'visual')
		execute "'<,'>call s:CollectAlPos(" . string(a:000) . ")"

		if (a:count ># s:maxAlClo)
			let s:maxAlClo = a:count
		endif
		let s:maxAlColLast = s:maxAlClo

		execute "'<,'>call s:AlignmentLine(" . string(a:000) . ")"
	else
		call s:CollectAlPos(a:000)

		if (a:count ># s:maxAlClo)
			let s:maxAlClo = a:count
		elseif (s:maxAlColLast ># s:maxAlClo)
			let s:maxAlClo = s:maxAlColLast
		else
			let s:maxAlColLast = s:maxAlClo
		endif

		call s:AlignmentLine(a:000)
	endif

endfunction

function! s:CollectAlPos(...)
	let l:linestr = getline('.')

	if (len(a:1)==# 0)
		if match(l:linestr, '\v\\\s*$') ==# -1
			if match(l:linestr, '\v^\s*\#\s*define\s+') ==# -1
				return 
			else
				execute	"silent normal! 0fdwel"
				if l:linestr[col('.')-1] ==# "("
					execute	"silent normal! %l"
				endif
				if virtcol('.') ==# len(l:linestr)
					if l:linestr[col('.')-1] ==# " "
						let l:offset = 4
					else
						let l:offset = 5
					endif
					if s:maxAlClo <  virtcol('.') + l:offset
						let s:maxAlClo = virtcol('.') + l:offset
					endif
					return
				endif
			endif
		else
			execute	"silent normal! $F\\"
			if l:linestr[col('.')-2] != " "
				execute	"silent normal! i "
			endif
			execute	"silent normal! gel"
		endif
		execute "let s:alPos." . line('.') . "=" . virtcol('.')
	else
		let l:matList = matchstrpos(l:linestr, '\V' . a:1[0] , 0)

		if l:matList[1] ==# -1
			return 0
		else
			if (len(a:1) ==# 2) && (a:1[1] == 'end')
				let l:pos = l:matList[2] + 1
			else
				let l:pos = l:matList[1] + 1
			endif
			execute "let s:alPos." . line('.') . "=" . virtcol([line('.'), l:pos])
		endif
	endif

	if s:maxAlClo < s:alPos[line('.')] + 4
		let s:maxAlClo = s:alPos[line('.')] + 4
	endif
endfunction


function! s:AlignmentLine(...)
	if has_key(s:alPos, line('.'))

		if (len(a:1) ==# 0)
			execute "silent normal! " . s:alPos[line('.')] . "|dw"
		else
			execute "silent normal! " . s:alPos[line('.')] . "|"
		endif

		if virtcol('.') <# s:maxAlClo
			let l:spacenu = s:maxAlClo - virtcol('.')
			execute "silent normal! " . l:spacenu . "i \<esc>0"
		endif
	endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
