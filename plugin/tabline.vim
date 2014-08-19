
" vim-tinytabs - Tiny tab line for Vim
" Maintainer: Rafael Bodill <justrafi@gmail.com>
" Version:    0.5
"-------------------------------------------------

" Runtime {{{1
set tabline=%!TlDrawTabs()

" Main tabline function. Draws the whole tabline
function! TlDrawTabs() " {{{1
	let s = '%#TabLineProject# %{TlFindProjectName()} %#TabLineProjectRe#⮀%#TabLine#  '
	let nr = tabpagenr()
	for i in range(tabpagenr('$'))
		if i + 1 == nr
			let s .= '%#TabLineSel#'
		else
			let s .= '%#TabLine#'
		endif
		" Set the tab page number (for mouse clicks)
		let s .= '%'.(i + 1).'T'
		let s .= ' %{TlTabLabel('.(i + 1).')} '
		if i + 1 == nr
			let s .= '%#TabLineSelRe#⮀ '
		else
			let s .= ' '
		endif
	endfor

	" After the last tab fill with TabLineFill and reset tab page nr
	let s .= '%#TabLineFill#%T'
	return s
endfunction

" Finds the project name from tab current directory.
" It tries to find the root path of a git repository.
function! TlFindProjectName() " {{{1
	" Use the cached (tab scope) variable unless the current dir changed
	if !exists('t:project_name') || ! (exists('t:project_dir') && t:project_dir == getcwd())
		" Store the current dir for caching
		let t:project_dir = getcwd()
		let t:project_name = t:project_dir
		" Find a .git directory, traverse to parents if needed
		if !isdirectory('.git')
			let t:project_name = substitute(finddir('.git', '.;'), '/.git', '', '')
			if t:project_name == ''
				let t:project_name = t:project_dir
			endif
		endif
		" Use the tail of the path (last component of the path)
		if len(t:project_name) > 1
			let t:project_name = fnamemodify(t:project_name, ':t')
		endif
	endif
  return t:project_name
endfunction

" Returns a specific tab's label
function! TlTabLabel(n) " {{{1
	let buflist = tabpagebuflist(a:n)
	let winnr = tabpagewinnr(a:n)
	let filepath = bufname(buflist[winnr - 1])
	if len(filepath) == 0
		let label = '[No Name]'
	else
		let pre = ''
		let project_dir = gettabvar(a:n, 'project_dir')
		if strridx(filepath, project_dir) == 0
			let filepath = strpart(filepath, len(project_dir))
			let pre .= gettabvar(a:n, 'project_name').'‡'
		endif

		" Shorten dir names
		let short = substitute(filepath, "[^/]\\{3}\\zs[^/]\*\\ze/", "", "g")
		" Decrease dir count
		let parts = split(short, '/')
		if len(parts) > 3
			let parts = parts[-3-1 : ]
		endif
		let filepath = join(parts, '/')

		" Prepend the project name
		let label = pre.filepath
	endif
	return label
endfunction

" }}}
