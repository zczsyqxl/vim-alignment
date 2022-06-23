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

if !hasmapto('<Plug>(Alignment)')
	map <unique> <leader>l <Plug>(Alignment)
endif

let g:vim_alignment_offset = get(g:, 'vim_alignment_offset', 1)

" mapping
vnoremap <unique> <silent> <Plug>(Alignment)  :<c-u>call <SID>Alignment("visual", v:count1)<cr>
nnoremap <unique> <silent> <Plug>(Alignment)  :<c-u>call <SID>Alignment("normal", v:count1)<cr>


let s:maxAlColLast = 0

function! s:Alignment(mode, count)

	let l:alMode = nr2char(getchar())

	if (l:alMode ==# 'm')
		let l:alMode = 'Macro'
		call s:ExecuteAlignment(a:mode, a:count, l:alMode)
		return
	elseif (l:alMode ==# 'e') 
		let l:alStr = input("Please type the string/pattern(very no majic) for alignment after it: ")
		if (l:alStr ==# '')
			return
		endif
		if (1 ==# strchars(l:alStr)) 
			let l:alMode = 'AfterSingleChar'
		else
			let l:alMode = 'AfterPattern'
		endif

	elseif (l:alMode ==# 's')
		let l:alStr = input("Please type the string/pattern(very no majic) for alignment before it: ")
		if (l:alStr ==# '')
			return
		endif
		if (1 ==# strchars(l:alStr)) 
			let l:alMode = 'FromSingleChar'
		else
			let l:alMode = 'FromPattern'
		endif
	else
		let l:alStr = l:alMode
		if (l:alStr ==# '')
			return
		endif
		let l:alMode = 'FromSingleChar'
	endif

	call s:ExecuteAlignment(a:mode, a:count, l:alMode, l:alStr ) 
endfunction

function! s:ExecuteAlignment(mode, ...)

	let s:alPos = {}
	let s:maxAlCol = 0

	if (a:mode ==# 'visual')
		execute "'<,'>call s:CollectAlPos(" . string(a:000) . ")"

		if ('FromSingleChar' !=# a:2) && ('AfterSingleChar' !=# a:2)
			if (a:1 ># s:maxAlCol)
				let s:maxAlCol = a:1
			endif
		endif

		let s:maxAlColLast = s:maxAlCol

		execute "'<,'>call s:AlignmentLine(" . string(a:000) . ")"
	else
		call s:CollectAlPos(a:000)

		if ('FromSingleChar' !=# a:2) && ('AfterSingleChar' !=# a:2)
			if (a:1 ># s:maxAlCol)
				let s:maxAlCol = a:1
			elseif (s:maxAlColLast ># s:maxAlCol)
				let s:maxAlCol = s:maxAlColLast
			else
				let s:maxAlColLast = s:maxAlCol
			endif
		endif

		call s:AlignmentLine(a:000)
	endif

endfunction

function! s:CollectAlPos(args)
	let l:linestr = getline('.')

	if ('Macro' ==# a:args[1])
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
		if ('FromSingleChar' ==# a:args[1])
			let l:posPattern = '\V\(\.\{-}\zs' . a:args[2] . '\)\{' . a:args[0] . '\}'
			let l:maxPosPattern = '\V\(\.\{-}\S\?\zs\s\*' . a:args[2] . '\)\{' . a:args[0] . '}'
		elseif ('AfterSingleChar' ==# a:args[1])
			let l:posPattern = '\V\(\.\{-}' . a:args[2] . '\)\{' . a:args[0] . '}\s\*\zs\S'
			let l:maxPosPattern = '\V\(\.\{-}' . a:args[2] . '\zs\)\{' . a:args[0] . '}'
		elseif ('FromPattern' ==# a:args[1])
			let l:posPattern = '\V' . a:args[2]
			let l:temPos = match(l:linestr, l:posPattern, 0) + 1
			let l:temCol = virtcol([line('.'), l:temPos])
			let l:maxPosPattern = '\V\S\zs\s\*\%' . l:temCol . 'v'
		elseif ('AfterPattern' ==# a:args[1])
			let l:posPattern = '\V' . a:args[2] .'\s\*\zs\S'
			let l:maxPosPattern = '\V' . a:args[2] . '\zs'
		endif

		let l:pos = match(l:linestr, l:posPattern, 0)

		if(l:pos ==# -1)
			return
		endif

		let l:maxPos = match(l:linestr, l:maxPosPattern, 0)

		if(l:maxPos ==# -1)
			return
		elseif(l:maxPos >=# 1)
			let l:maxPos = l:maxPos - 1
		endif

	endif

	let l:col = virtcol([line('.'), l:pos + 1])
	let l:maxCol = virtcol([line('.'), l:maxPos + 1])
	execute "let s:alPos." . line('.') . "=" . l:col

	if s:maxAlCol < l:maxCol + g:vim_alignment_offset
		let s:maxAlCol = l:maxCol + g:vim_alignment_offset
	endif

endfunction


function! s:AlignmentLine(args)

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
