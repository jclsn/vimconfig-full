" Author        : Jan Claussen
" Created       : 11/10/2022
" License       : MIT
" Description   :


let g:todoKeywords = [
			\ "TODO",
			\ "FIXME",
			\ ]

function! UpdateTodoKeywords(...)
    let newKeywords = join(a:000, " ")
    let synTodo = map(filter(split(execute("syntax list"), '\n') , { i,v -> match(v, '^\w*Todo\>') == 0}), {i,v -> substitute(v, ' .*$', '', '')})
    for synGrp in synTodo
        execute "syntax keyword " . synGrp . " contained " . newKeywords
    endfor
endfunction

augroup now
    autocmd!
    autocmd Syntax * call UpdateTodoKeywords(join(todoKeywords))
augroup END

