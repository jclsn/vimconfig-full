vim9script

def LangList(ArgLead: string, CmdLine: string, CursorPos: number): list<string>

	var lang_list = [ 
			\ "Bash", 
			\ "C/C++", 
			\ "C/C++ remote", 
			\ "C#", 
			\ "Docker",
			\ "Go", 
			\ "Jai", 
			\ "Javascript/Typescript", 
			\ "Java", 
			\ "Lua", 
			\ "PHP", 
			\ "Python", 
			\ "Python remote", 
			\ "Rust" 
			\ ]

	return lang_list
enddef

def CreateConfig(lang: string)

	const template_path: string = expand('<script>>:p:h')[ : -32] .. "templates/"
	vert new
	setfiletype jsonc

	if lang == "Bash"
		put =readfile(template_path .. "bash.template")
	elseif lang == "C/C++"
		put =readfile(template_path .. "c.template")
	elseif lang == "C/C++ remote"
		put =readfile(template_path .. "c-remote.template")
	elseif lang == "C#"
		put =readfile(template_path .. "csharp.template")
	elseif lang == "Docker"
		put =readfile(template_path .. "docker.template")
	elseif lang == "Go"
		put =readfile(template_path .. "go.template")
	elseif lang == "Jai"
		put =readfile(template_path .. "jai.template")
	elseif lang == "Javascript/Typescript"
		put =readfile(template_path .. "javascript.template")
	elseif lang == "Java"
		put =readfile(template_path .. "java.template")
	elseif lang == "Lua"
		put =readfile(template_path .. "lua.template")
	elseif lang == "PHP"
		put =readfile(template_path .. "php.template")
	elseif lang == "Python"
		put =readfile(template_path .. "python.template")
	elseif lang == "Python remote"
		put =readfile(template_path .. "python-remote.template")
	elseif lang == "Rust"
		put =readfile(template_path .. "rust.template")
	endif
enddef

command -nargs=1 -complete=customlist,LangList VimspectorCreateConfig CreateConfig(<q-args>)

