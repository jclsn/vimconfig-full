vim9script

def g:QtOpenDocumentation(qt_version: string = g:qt_version)
    var word = tolower(expand('<cword>'))
    var url = 'https://doc.qt.io/' .. qt_version .. '/' .. word .. '.html'
    silent! call system('xdg-open ' .. shellescape(url) .. ' &')
enddef

command QtDoc call QtOpenDocumentation()
