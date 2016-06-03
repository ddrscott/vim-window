# Overview
This aims to make Vim window layouts a easier.
The default mappings and commands make managing more than a couple windows
difficult:

- Rotating windows `<C-w>r` only works on linear layouts.
- Exchanging windows `<C-w>x` only works on linear layouts.
- No concept of moving a buffer from one window to another.
  - This is achieved by going into a window, `:b 1`, then moving to another
    buffer and `:b 2`. `:b#` can't be used because windows remember previous
    buffer independently.
- Joining windows together is not possible as a single command.

This plugin provides functions which can be mapped to anything you want to
overcome these difficulties. Happy vimming!

# Buffer Rotation
Same as the default `nmap <C-w>r`, but works across any window layout.

`function! window#rotate(direction * v:count1)`

```
   Rotate Clockwise: ]r
 
+-----------+       +-----------+
|       | B |       |       | A |
|       |---|       |       |---|
|   A   | C |  -->  |   D   | B |
|       |---|       |       |---|
|       | D |       |       | C |
+-----------+       +-----------+
```

```
   Rotate Counter-clockwise: [r

+-----------+       +-----------+
|       | B |       |       | C |
|       |---|       |       |---|
|   A   | C |  -->  |   B   | D |
|       |---|       |       |---|
|       | D |       |       | A |
+-----------+       +-----------+
```

# Exchange Window Buffers

The default is to exchange with the previous window as defined by
`<C-w>p`/`winnr('#')`. If a count is specified before the mapping
the current window will exchange with the `v:count` window.

The following examples shows feature. If the current window is `A`
go to window `C`, then `<C-w>x` and the 2 buffers will swap. If you don't want
to first move to `C`, we can do `3<C-w>x`. I show my `winnr` in the status line
for exactly this reason. It's also useful to jump directly to window numbers by
using `{n}<C-w><C-w>`

```
        Exchange: <C-w>x

+-----------+       +-----------+
|       | B |       |       | B |
|       |---|       |       |---|
|   A   | C |  -->  |   C   | A |
|       |---|       |       |---|
|       | D |       |       | D |
+-----------+       +-----------+
```

# Glue Windows Together
Similar to iTerms "Move Session to Split Pane". Can also be thought of as
"join", but `<C-w>j` and `<C-w>J` are taken by Vim defaults. There are `<C-w>g`
mappings, too, but none that chain out to `hjkl`. So "[g]lue" becomes are new
pneumonic.

Here's the effect of some window glueing. All diagrams assume the previous
window is `D` and the current window is `A`.

```
        Glue to right: <C-w>gl   
                 
+---------------+     +-------------+
|        |  B   |     |    |   |    |
|        |------|     |    |   | B  |
|   A    |  C   | --> | A  | D#|----|
|   ^    |------|     |    |   |    |
|        |  D#  |     |    |   | C  |
+---------------+     +-------------+
```

```
        Glue to left: <C-w>gh   

+---------------+     +-------------+
|        |  B   |     |    |   |    |
|        |------|     |    |   | B  |
|   A    |  C   | --> | D# | A |----|
|   ^    |------|     |    |   |    |
|        |  D#  |     |    |   | C  |
+---------------+     +-------------+
```

```
        Glue to above: <C-w>gk

+---------------+     +-------------+
|        |  B   |     |        |    |
|        |------|     |   D#   | B  |
|   A    |  C   | --> |--------|----|
|   ^    |------|     |        |    |
|        |  D#  |     |   A    | C  |
+---------------+     +-------------+
```

```
        Glue to below: <C-w>gj

+---------------+     +-------------+
|        |  B   |     |        |    |
|        |------|     |   A    | B  |
|   A    |  C   | --> |--------|----|
|   ^    |------|     |        |    |
|        |  D#  |     |   D#   | C  |
+---------------+     +-------------+
```

# Window Layouts
I'm pretty picky about window layout when I have more than a couple buffers.
I like to have one primary window and the rest of the buffers/windows in a
linear layout pinned to the right.

```
            +----------------+
            |         |  B   |
            |         |------|
            |    A    |  C   |
            |         |------|
            |         |  D   |
            +----------------+
```

There are many ways to achieve this but they all require multiple steps.  `:ball
| wincmd H` is probably the easiest one or `:vert ball | wincmd J`. The problem
with these naive approaches is knowing which buffer will be the main one. After
each `ball` command, it is hard to know which window will come into focus for
the `wincmd H` split. The `window#layout` function aims to keep the current
window or `v:count` window as the main after executing the new layout.

Here's a few interesting commands:

```vim
" This is my preferred layout 
command! -nargs=* BallH call window#layout('ball', 'H', <args>)

" Use it with where the number is optional.
:BallH 3

" Same layout but only effect current windows instead of all buffers.
command! -nargs=* WinH call window#layout('windo wincmd J', 'H', <args>)

" Example use is, here I've omitted the optional arg which
" which keeps the current window as primary.
:WinH
```

Here's of starting Vim with your new layout command:

```sh
# How about from shell
vim +BallH $(git diff --name-only)
```

# Window Isolation
An improved `<C-w>o`. I hit this all the time by accident when trying to a
previous window using `<C-w>p`. But never disabled it because sometimes, that's
what I actually want. We have a function which can be mapped to `<C-w>o` which
will simply performs a `:tab sp` when there is more than 1 window. This will
make a copy of the buffer and put it into it's own tab while maintaining the
original layout if the previous tab.

```vim
" Improve window only, to split to new tab instead
nnoremap <C-w>o :call window#only()<cr>
nnoremap <C-w><c-o> :call window#only()<cr>
```

# All Recommended Mappings
Here's all the recommended mapping in one place. Feel free to copy them into
your own `$MYVIMRC`. Make adjustments as needed or make more sweet command
combos.


```vim
" Unimpaired mapping
nnoremap ]r :<C-U>call window#rotate(-1 * v:count1)<cr>
nnoremap [r :<C-U>call window#rotate(1 * v:count1)<cr>

" Improved window rotate to work with all layouts
nmap <C-w>r ]r
nmap <C-w><C-r> ]r

" Improve window exchange to work with all layouts
nnoremap <C-w>x :<C-U>call window#exchange(v:count)<cr>
nnoremap <C-w><c-x> :<C-U>call window#exchange(v:count)<cr>

" [g]lue windows together.
"    l = glue to right side
"    h = glue to left side
"    j = glue to bottom
"    k = glue to top
"
" `normal! 100zh` scrolls window contents into view since it gets messy when
" narrower window tries refocuses its cursor.
nnoremap <C-w>gl :<C-U>call window#join('rightbelow vsplit', v:count) <BAR>normal! 100zh<CR>
nnoremap <C-w>gh :<C-U>call window#join('leftabove vsplit', v:count)  <BAR>normal! 100zh<CR>
nnoremap <C-w>gj :<C-U>call window#join('belowright split', v:count)  <BAR>normal! 100zh<CR>
nnoremap <C-w>gk :<C-U>call window#join('aboveleft split', v:count)   <BAR>normal! 100zh<CR>

" Force a primary window layout.
" The capital HJKL forces the primary window to a specific direction.
command! -nargs=* LayoutH call window#layout('ball', 'H', <args>)
command! -nargs=* LayoutJ call window#layout('vertical ball', 'J', <args>) 
command! -nargs=* LayoutK call window#layout('vertical ball', 'K', <args>) 
command! -nargs=* LayoutL call window#layout('ball', 'L', <args>)

" Map the layout commands to something if that's your style.
nnoremap <C-w>gH :<C-U>LayoutH v:count<CR>
nnoremap <C-w>gJ :<C-U>LayoutJ v:count<CR>
nnoremap <C-w>gK :<C-U>LayoutK v:count<CR>
nnoremap <C-w>gL :<C-U>LayoutL v:count<CR>

" Improve window only, to split to new tab instead
nnoremap <C-w>o :call window#only()<cr>
nnoremap <C-w><c-o> :call window#only()<cr>
```
