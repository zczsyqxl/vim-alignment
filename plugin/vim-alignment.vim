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
	map <unique> <leader>a <Plug>(Alignment)
endif

let g:vim_alignment_offset = get(g:, 'vim_alignment_offset', 1)

vnoremap <unique> <silent> <Plug>(Alignment)  :<c-u>call <SID>Alignment("visual", v:count1)<cr>
nnoremap <unique> <silent> <Plug>(Alignment)  :<c-u>call <SID>Alignment("normal", v:count1)<cr>


let s:maxAlColLast = 0

function! s:Alignment(mode, count)

	let l:alMode = nr2char(getchar())

	if (l:alMode ==# 'm')
		call s:ExecuteAlignment(a:mode, a:count)
		return
	elseif (l:alMode ==# 'e') 
		let l:alStr = input("Please type the string/pattern(very no majic) for alignment after it: ")

		if (l:alStr ==# '')
			return
		endif

		call s:ExecuteAlignment(a:mode, a:count, l:alStr, 'end')
		return
	elseif (l:alMode ==# 's')
		let l:alStr = input("Please type the string/pattern(very no majic) for alignment before it: ")

		if (l:alStr ==# '')
			return
		endif
	else
		let l:alStr = l:alMode
		if (l:alStr ==# '')
			return
		endif
	endif

	call s:ExecuteAlignment(a:mode, a:count, l:alStr)
endfunction

function! s:ExecuteAlignment(mode, count, ...)

	let s:alPos = {}
	let s:maxAlCol = 0

	if (a:mode ==# 'visual')
		execute "'<,'>call s:CollectAlPos(" . string(a:000) . ")"

		if (a:count ># s:maxAlCol)
			let s:maxAlCol = a:count
		endif
		let s:maxAlColLast = s:maxAlCol

		execute "'<,'>call s:AlignmentLine(" . string(a:000) . ")"
	else
		call s:CollectAlPos(a:000)

		if (a:count ># s:maxAlCol)
			let s:maxAlCol = a:count
		elseif (s:maxAlColLast ># s:maxAlCol)
			let s:maxAlCol = s:maxAlColLast
		else
			let s:maxAlColLast = s:maxAlCol
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
				let l:curPattern = '\V\^\s\*#define\s\+\w\+\(\s\+\|(\.\{-})\s\+\)\zs\S\+'
				let l:pos = match(l:linestr, l:curPattern)
				if(l:pos ==# -1)
					return
				endif
				let l:prePattern = '\V\^\s\*#define\s\+\w\+\(\zs\s\+\|(\.\{-})\zs\s\+\)\S\+'
				let l:maxPos = match(l:linestr, l:prePattern)
				if(l:maxPos ==# -1)
					return
				endif
				let l:maxPos = l:maxPos-1
			endif
		else
			let l:curPattern = '\V\^\.\*\zs\\\s\*\$'
			let l:pos = match(l:linestr, l:curPattern)
			if(l:pos ==# -1)
				return
			endif
			let l:prePattern = '\V\s\*\\\s\*\$'
			let l:maxPos = match(l:linestr, l:prePattern)
			if(l:maxPos ==# -1)
				return
			elseif(l:maxPos >=# 1)
				let l:maxPos = l:maxPos-1
			endif
		endif
	else
		let l:curPattern = '\V' . a:1[0]
		let l:matList = matchstrpos(l:linestr, l:curPattern, 0)
		if l:matList[1] ==# -1
			return 0
		else
			if (len(a:1) ==# 2) && (a:1[1] == 'end')
				let l:maxPos = l:matList[2] - 1
				let l:aftPattern = '\V' . a:1[0] . '\s\*\zs\S' 
				let l:pos = match(l:linestr, l:aftPattern, 0)
				if(l:pos ==# -1)
					return
				endif
			else
				let l:pos = l:matList[1]
				let l:prePattern = '\V\s\*' . a:1[0]
				let l:maxPos = match(l:linestr, l:prePattern, 0)
				if(l:maxPos ==# -1)
					return
				elseif(l:maxPos >=# 1)
					let l:maxPos = l:maxPos-1
				endif
			endif
		endif
	endif

	let l:col = virtcol([line('.'), l:pos]) + 1
	let l:maxCol = virtcol([line('.'), l:maxPos]) + 1
	execute "let s:alPos." . line('.') . "=" . l:col

	if s:maxAlCol < l:maxCol + g:vim_alignment_offset
		let s:maxAlCol = l:maxCol + g:vim_alignment_offset
	endif
endfunction


function! s:AlignmentLine(...)
	if has_key(s:alPos, line('.'))

		execute "silent normal! " . s:alPos[line('.')] . "|"

		if virtcol('.') ># s:maxAlCol
			execute "silent normal! geldw"
		endif

		if virtcol('.') <=# s:maxAlCol
			let l:spacenu = s:maxAlCol - virtcol('.') + 1
			execute "silent normal! " . l:spacenu . "i \<esc>0"
		endif
	endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
