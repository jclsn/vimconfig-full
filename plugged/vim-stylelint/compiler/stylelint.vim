"compiler to call stylelint on css file
let s:stylelint_server = expand('<sfile>:p:h') . '/../bin/stylelint-server.js'

if exists('current_compiler')
  finish
endif
let current_compiler = 'stylelint'

if exists(":CompilerSet") != 2
	command -nargs=* CompilerSet setlocal <args>
endif

"allow overriding lint on save (default is true)
if !exists('g:stylelint_onwrite')
    let g:stylelint_onwrite = 1
endif

"allow overriding default jump to first error (default is false)
if !exists('g:stylelint_goto_error')
    let g:stylelint_goto_error = 0
endif

if !exists('g:stylelint_autofix')
    let g:stylelint_autofix = 0
endif

"suppress warnings
if !exists('g:stylelint_quiet')
    let g:stylelint_quiet = 0
endif

if exists(':StyleLint') != 2
    command StyleLint :call StyleLint(0)
endif

if exists(':StyleLintFix') != 2
    command StyleLintFix :call StyleLintFix()
endif

execute 'setlocal efm=%f:%l:%c\ %m'

if g:stylelint_onwrite
    augroup css
        au!
        "au BufWritePost *.js call StyleLint(1)
        au BufWritePost *.css call StyleLint2()
        au BufWritePost *.scss call StyleLint2()
    augroup end
endif

function! StyleLint(saved)

    if !a:saved && &modified
        " Save before running
        write
    endif

	"shellpipe
    if has('win32') || has('win16') || has('win95') || has('win64')
        setlocal sp=>%s
    else
        setlocal sp=>%s\ 2>&1
    endif

    if g:stylelint_goto_error
	silent lmake
    else
	silent lmake!
    endif

    "open local window with errors
    :lwindow

endfunction

function! GetBufferText()
    "obtain contents of buffer
    let buflines = getline(1, '$')

    "replace hashbangs (in node CLI scripts)
    let linenum  = 0

    "fix offset errors caused by windows line endings
    "since 'buflines' does NOT return the line endings
    "we need to replace them for unix/mac file formats
    "and for windows we replace them with a space and \n
    "since \r does not work in node on linux, just replacing
    "with a space will at least correct the offsets
    if &ff == 'unix' || &ff == 'mac'
        let buftext = join(buflines, "\n")
    elseif &ff == 'dos'
        let buftext = join(buflines, " \n")
    else
        echom 'unknown file format' . &ff
        let buftext = join(buflines, "\n")
    endif

    return buftext

endfunction

function! StyleLint_StartServer()
	  let s:stylelint_server_job = job_start(["/bin/sh", "-c", "node " . s:stylelint_server])
endfunction

function! StyleLint_OpenChannel(wait)
    let g:stylelint_channel = ch_open('localhost:9797', {'mode': 'json',
                \'waittime': a:wait,
                \'callback': 'StyleLint_ChannelResponse' })
    let status = ch_status(g:stylelint_channel)
    "echom 'channel status =' . status
    if status == 'fail' || status == 'closed'
        return 0
    else
        return 1
    endif
endfunction

function! StyleLint_Connect()
    let g:stylelint_connected = StyleLint_OpenChannel(0)
    let tries = 1

    "start server job if unable to connect
    if !g:stylelint_connected
        call StyleLint_StartServer()
        while !g:stylelint_connected
            let g:stylelint_connected = StyleLint_OpenChannel(100)
            let tries += 1
            if tries > 20
                echom 'giving up after 20 tries to connect to stylelint server'
                break
            endif
        endwhile
    endif
endfunction

function! StyleLint2()

    "connect if necessary
    if !exists('g:stylelint_connected') || !g:stylelint_connected

        call StyleLint_Connect()

        if !g:stylelint_connected
            echom 'Failed to connect to stylelint server, status: ' .  ch_status(g:stylelint_channel)
        else
            "echom 'connected to StyleLint server'
        endif
    endif

    try
        let json = json_encode({ 'file': expand('%:p'), 'code': GetBufferText()})
    catch /^Vim\%((\a\+)\)\=:E906/
        echom 'stylelint channel closed, reopening'
        call StyleLint_Connect()
        if !g:stylelint_connected
            echom 'Failed to connect to stylelint server, status: ' .  ch_status(g:stylelint_channel)
        else
            "echom 'connected to StyleLint server'
        endif
    endtry

    call ch_sendexpr(g:stylelint_channel, json, {'callback': 'StyleLint_ChannelResponse'})

endfunction

function! StyleLint_ChannelResponse(channel, result)

    if has_key(a:result, 'error')
        echom a:result['error']
        return
    endif

    "echom 'StyleLint_ChannelResponse: ' . string(a:result)
    if has_key(a:result, 'fixed')
        let pos = winsaveview()
        let fixedCode = a:result['fixed']
        "replace code
        let @f = fixedCode
        :%d
        normal "fp
        call winrestview(pos)
    endif

    if has_key(a:result, 'errorfile') && len(a:result.errorfile)
        "show error messages
        if g:stylelint_goto_error
            exe ':lf ' . a:result.errorfile
        else
            exe ':lf! ' . a:result.errorfile
        endif
        :lope
    else
        "no errors -- close quickfix window
        :lcl
    endif

endfunction

