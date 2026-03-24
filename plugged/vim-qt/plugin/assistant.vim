vim9script

g:qt_assistant_job = v:none

def QtAssistantOpen(): void
    var cmd = [g:vimqt_assistant, '-enableRemoteControl']
    var job_options = {'in_io': 'pipe', 'out_io': 'pipe', 'err_io': 'pipe'}
    g:qt_assistant_job = job_start(cmd, job_options)
enddef

def QtAssistantSearch(): void
    if typename(g:qt_assistant_job) != 'job' && g:qt_assistant_job == v:none
        QtAssistantOpen()
    elseif job_status(g:qt_assistant_job) !=# 'run'
        QtAssistantOpen()
    endif

    var channel = job_getchannel(g:qt_assistant_job)
    ch_logfile('./channel.log', 'w')

    var keyword = expand('<cword>')
    ch_sendraw(channel, 'ActivateKeyword ' .. keyword .. "\n")
enddef

command QtAssist call QtAssistantSearch()
