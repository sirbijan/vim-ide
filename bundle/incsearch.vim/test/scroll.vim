let s:suite = themis#suite('scroll')
let s:assert = themis#helper('assert')

map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

" Helper:
function! s:add_line(str)
    put! =a:str
endfunction
function! s:add_lines(lines)
    for line in reverse(a:lines)
        put! =line
    endfor
endfunction
function! s:get_pos_char()
    return getline('.')[col('.')-1]
endfunction

function! s:suite.before_each()
    set wrapscan&
    let h = winheight(0)
    normal! ggdG
    call s:add_lines(
    \     ['pattern1 pattern2 pattern3']
    \   + range(h * 2)
    \   + ['pattern4 pattern5 pattern6']
    \ )
    normal! Gdd
    normal! gg0zt
endfunction

function! s:suite.after()
    set wrapscan&
endfunction


function! s:suite.scroll_f_works()
    call s:assert.equals(s:get_pos_char(), 'p')
    exec "normal /pattern\\zs\\d\<CR>"
    normal! gg0
    exec "normal /pattern\\zs\\d\<C-j>\<CR>"
    call s:assert.equals(s:get_pos_char(), '4')
    normal! gg0
    exec "normal /pattern\\zs\\d\<Tab>\<C-j>\<Tab>\<CR>"
    call s:assert.equals(s:get_pos_char(), '5')
endfunction

function! s:suite.scroll_b_works()
    normal! G$
    call s:assert.equals(getline('.'), 'pattern4 pattern5 pattern6')
    normal! gg
    call s:assert.equals(getline('.'), 'pattern1 pattern2 pattern3')
    normal! G$
    call s:assert.equals(s:get_pos_char(), '6')
    normal! G$zt
    call s:assert.equals(s:get_pos_char(), '6')
    exec "normal ?pattern\\zs\\d\<C-k>\<CR>"
    call s:assert.equals(s:get_pos_char(), '3')
endfunction

function! s:suite.wrapscan_scroll_reverse__move_cursor()
    call s:assert.equals(s:get_pos_char(), 'p')
    exec "normal /pattern\\zs\\d\<C-k>\<CR>"
    call s:assert.equals(s:get_pos_char(), '6')
endfunction

function! s:suite.nowrapscan_scroll_reverse_move_cursor_to_the_last_pattern()
    set nowrapscan
    normal! G0
    call s:assert.equals(s:get_pos_char(), 'p')
    exec "normal /pattern\\zs\\d\<C-k>\<CR>"
    call s:assert.not_equals(s:get_pos_char(), '3')
    call s:assert.equals(s:get_pos_char(), '6')
    normal! gg$
    call s:assert.equals(s:get_pos_char(), '3')
    exec "normal ?pattern\\zs\\d\<C-j>\<CR>"
    call s:assert.not_equals(s:get_pos_char(), '4')
    call s:assert.equals(s:get_pos_char(), '1')
endfunction
