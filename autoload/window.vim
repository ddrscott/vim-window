" Sets window's buffer number to next/previous windows buffer number
" This effective rotates the contents of the windows instead of the
" actual window.
" It has a similar effect window#rotate, but handles all sorts of window
" layouts.
function! window#rotate(dir) abort
  let current = winnr()
  " assume left is main window
  let winnr_to_bufnr = s:winnr_bufnr_dict()
  " collect all the buffer numbers
  let max = winnr('$')
  let i = max
  while i > 0
    let dst = (a:dir + i) - 1
    let mod = s:mod(dst,max) + 1
    call window#set_winnr_to_bufnr(i, winnr_to_bufnr[mod])
    let i -= 1
  endwhile
  exec 'keepjumps '.current.'wincmd w'
endfunction

function! window#winnr_by_area()
  let largest = 0
  let size = 0

  let i = winnr('$')
  while i > 0
    let area = winheight(i) * winwidth(i)
    if area >= size
      let largest = i
      let size = area
    endif
    let i -= 1
  endwhile
  return largest
endfunction

function! window#set_winnr_to_bufnr(window_num, buffer_num)
  exec 'keepjumps '.a:window_num.'wincmd w'
  exec 'silent keepjumps buffer '.a:buffer_num
endfunction

" Similar to `wincmd x`, but works regardless of layout.
" When other is < 1, will exchange with previous window according to
" `wincmd p`.
function! window#exchange(other) abort
  let current = winnr()
  let winnr_to_bufnr = s:winnr_bufnr_dict()
  let other_winnr = s:other_winnr(a:other)
  if current == other_winnr
    return
  endif
  let other_bufnr = winnr_to_bufnr[other_winnr]
  if other_bufnr
    call window#set_winnr_to_bufnr(other_winnr, winnr_to_bufnr[current])
    call window#set_winnr_to_bufnr(current, winnr_to_bufnr[other_winnr])
  endif
endfunction

" Tab Split Current Window
" Mapping:
"   nnoremap <c-w>o :call window#only()<cr>
"   nnoremap <c-w><c-o> :call window#only()<cr>
function! window#only()
  if winnr('$') > 1
    tab split
  endif
endfunction

function! window#join(splitter, other) abort
  let current = winnr()
  let other_winnr = s:other_winnr(a:other)
  if current == other_winnr
    return
  endif
  let winnr_to_bufnr = s:winnr_bufnr_dict()
  let other_bufnr = winnr_to_bufnr[other_winnr]
  wincmd p
  exec other_winnr.'quit'
  wincmd p
  exec a:splitter
  exec 'buffer '.other_bufnr
endfunction

" Based on current window and previous window
" Usage: :call window#layout('ball', 'H', winnr())
function! window#layout(split_all, cmd, ...) abort
  " figure out the winnr before splitting, otherwise
  " original layouts winnr() could change.
  let main_winnr = a:0 > 0 ? (0 + a:1) : 0 
  let main_winnr = main_winnr < 1 ? winnr() : main_winnr

  let winnr_to_bufnr = s:winnr_bufnr_dict()
  exec a:split_all
  let bufnr_to_winnr = s:bufnr_winnr_dict()
  exec bufnr_to_winnr[winnr_to_bufnr[main_winnr]].'wincmd w'
  exec 'wincmd '. a:cmd
endfunction

" privates

" returns `other` or winnr('#')
function! s:other_winnr(other)
  let other_winnr = a:other
  if other_winnr < 1
    let other_winnr = winnr('#')
  endif
  return other_winnr
endfunction

" ensures a positive modulo
function! s:mod(n,m)
	return ((a:n % a:m) + a:m) % a:m
endfunction

" return dicitionay of winnr to bufnr mappings
function! s:winnr_bufnr_dict()
	let result = {}
	" collect all the buffer numbers
	let i = winnr('$')
	while i > 0
		let result[i] = winbufnr(i)
		let i -= 1
	endwhile
  return result
endfunction

" return dicitionay of winnr to bufnr mappings
function! s:bufnr_winnr_dict()
  let result = {}
  " collect all the buffer numbers
  let i = winnr('$')
  while i > 0
    let result[winbufnr(i)] = i
    let i -= 1
  endwhile
  return result
endfunction
