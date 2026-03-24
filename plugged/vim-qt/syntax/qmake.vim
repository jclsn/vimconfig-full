" qmake project syntax file
" Language:     qmake project
" Maintainer:   Arto Jonsson <ajonsson@kapsi.fi>
" http://gitorious.org/qmake-project-syntax-vim

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

syntax case match


" Comments
syn match qmakeComment "#.*"

syn match	qmakePath				"\s*\(\.\|\w\)*/\(\(\.\|\w\)*\(\|/\)\)*" contains=qmakeNextLine,qmakeVarDecl
syn match	qmakePathDot			"\s*\(\.\|\w\)*\.\(\(\.\|\w\)*\(\|/\)\)*" contains=qmakeNextLine,qmakeVarDecl
syn match   qmakeCppFlag            "c++\(\x\|\X\)\{2}"

" Escape characters
syn match qmakeEscapedChar /\\['"$\\]/
syn match qmakeNextLine	"\\\n\s*"

" Quoted string literals
syn region qmakeQuotedString start=/"/ end=/"/ contains=@qmakeExpansion,qmakeEscapedChar
syn region qmakeQuotedString start=/'/ end=/'/ contains=@qmakeExpansion,qmakeEscapedChar

syn region	qmakeOptionsQT			start=.QT\s*\(\|[+\-~*]\)=. skip=.\\\s*$. end=.$. keepend
                                    \ contains=qmakeOptionsQTConst,qmakeOperator,qmakeVariable,qmakeBuiltinVarName
syn keyword	qmakeOptionsQTConst		bluetooth concurrent core declarative designer designercomponents contained
syn keyword	qmakeOptionsQTConst     enginio gamepad gui qthelp multimedia multimediawidgets multimediaquick contained
syn keyword qmakeOptionsQTConst     network nfc opengl positioning printsupport qml qmltooling quick quickparticles contained
syn keyword qmakeOptionsQTConst     quickwidgets script scripttools sensors serialport sql svg test webkit contained
syn keyword qmakeOptionsQTConst     webkitwidgets websockets widgets winextras xml xmlpatterns webenginecore  contained
syn keyword qmakeOptionsQTConst     webengine webenginewidgets 3dcore 3drenderer 3dquick 3dquickrenderer 3dinput  contained
syn keyword qmakeOptionsQTConst     3danimation 3dextras geoservices webchannel texttospeech serialbus webview contained
syn keyword qmakeOptionsQTConst     charts contained

" syn region	qmakeOptionsTEMPLATE	start=.TEMPLATE\s*\(\|[+\-~*]\)=. skip=.\\\s*$. end=.$. keepend
									" \ contains=qmakeOptionsTEMPLATEConst,qmakeOperator,qmakeVariable
" syn keyword qmakeOptionsTEMPLATEConst	app lib subdirs vcapp vclib contained

" syn region	qmakeOptionsCONFIG		start=.CONFIG\s*\(\|[+\-~*]\)=. skip=.\\\s*$. end=.$. keepend
									" \ contains=qmakeOptionsCONFIGConst,qmakeOperator,qmakeVariable
syn keyword qmakeOptionsCONFIGConst	release debug debug_and_release build_all ordered precompile_header
                                    \ warn_on warn_off create_prl link_prl qt thread x11 windows console
                                    \ shared dll dylib static staticlib plugin designer uic3
                                    \ no_lflags_merge resources 3dnow exceptions mmx rtti stl sse sse2
                                    \ flat embed_manifest_dll embed_manifest_exe incremental
                                    \ debug_and_release_target c++11 c++14 c++17
                                    \ ppc x86 x64 app_bundle lib_bundle largefile separate_debug_info contained

" QMake variable declarations
syn match qmakeVarDecl /\(\i\|\.\)\+\s*=/he=e-1 contains=qmakeBuiltinVarName nextgroup=qmakeVarAssign
syn match qmakeVarDecl /\(\i\|\.\)\+\s*\(+\|-\||\|*\|\~\)=/he=e-2 contains=qmakeBuiltinVarName nextgroup=qmakeVarAssign

" QMake variable assignments
syn region qmakeVarAssign start=/\s*\ze[^[:space:]}]/ skip=/\\$/ end=/\(\ze}\|$\)/ contained contains=@qmakeData,qmakeNextLine,qmakePathDot,qmakePath,qmakeOptionsQTConst,qmakeOptionsCONFIGConst,qmakeOptionsQT,qmakeCppFlag


" QMake variable values / macro expansions
syn match qmakeVarValue /$$\(\i\|\.\)\+/ contains=qmakeBuiltinVarVal,qmakeBuiltinMacro nextgroup=qmakeMacroArgs
syn match qmakeVarValue /$${\(\i\|\.\)\+}/ contains=qmakeBuiltinVarVal
syn region qmakeMacroArgs matchgroup=qmakeMacroParens start=/(/ skip=/\\$/ excludenl end=/)\|$/ contained contains=@qmakeData,qmakeMacroComma
syn match qmakeMacroComma /,/ contained

" Environment variable values
syn match qmakeEnvValue /$(\(\i\|\.\)\+)/
syn match qmakeEnvValue /$$(\(\i\|\.\)\+)/

" QMake property values
syn match qmakePropValue /$$\[\(\i\|\.\)\+\]/ contains=qmakeBuiltinProp

" All possible variable/macro/property expansions
syn cluster qmakeExpansion contains=qmakeVarValue,qmakeEnvValue,qmakePropValue

" All possible data values
syn cluster qmakeData contains=@qmakeExpansion,qmakeQuotedString,qmakeEscapedChar


" User-defined macros
syn keyword qmakeUserMacroDecl defineReplace nextgroup=qmakeUserMacroName
syn region qmakeUserMacroName matchgroup=none start=/\s*(/ end=/)\|$/ contained

" User-defined functions
syn keyword qmakeUserFuncDecl defineTest nextgroup=qmakeUserFuncName
syn region qmakeUserFuncName matchgroup=none start=/\s*(/ end=/)\|$/ contained
syn keyword qmakeFuncReturn return nextgroup=qmakeFuncReturnArgs
syn region qmakeFuncReturnArgs matchgroup=none start=/\s*(/ skip='\\$' end=/)\|$/ contained contains=@qmakeData


" Function arguments
syn region qmakeFuncArgs start=/(/ skip=/\\$/ excludenl end=/)\|$/ contains=@qmakeData,qmakeBuiltinVarName,qmakeOptionsCONFIGConst,qmakeVarDecl



" Built-in variables (as of Qt 5.8)
let s:builtInVars = [ 'CONFIG', 'DEFINES', 'DEF_FILE', 'DEPENDPATH', 'DEPLOYMENT_PLUGIN', 'DESTDIR', 'DISTFILES',
                    \ 'DLLDESTDIR', 'FORMS', 'GUID', 'HEADERS', 'ICON', 'IDLSOURCES', 'INCLUDEPATH', 'INSTALLS', 'LEXIMPLS',
                    \ 'LEXOBJECTS', 'LEXSOURCES', 'LIBS', 'LITERAL_HASH', 'MAKEFILE', 'MAKEFILE_GENERATOR', 'MOC_DIR',
                    \ 'OBJECTS', 'OBJECTS_DIR', 'POST_TARGETDEPS', 'PRE_TARGETDEPS', 'PRECOMPILED_HEADER', 'PWD',
                    \ 'OUT_PWD', 'QMAKE', 'QMAKESPEC', 'QMAKE_AR_CMD', 'QMAKE_BUNDLE_DATA', 'QMAKE_BUNDLE_EXTENSION',
                    \ 'QMAKE_CC', 'QMAKE_CFLAGS', 'QMAKE_CFLAGS_DEBUG', 'QMAKE_CFLAGS_RELEASE', 'QMAKE_CFLAGS_SHLIB',
                    \ 'QMAKE_CFLAGS_THREAD', 'QMAKE_CFLAGS_WARN_OFF', 'QMAKE_CFLAGS_WARN_ON', 'QMAKE_CLEAN', 'QMAKE_CXX',
                    \ 'QMAKE_CXXFLAGS', 'QMAKE_CXXFLAGS_DEBUG', 'QMAKE_CXXFLAGS_RELEASE', 'QMAKE_CXXFLAGS_SHLIB',
                    \ 'QMAKE_CXXFLAGS_THREAD', 'QMAKE_CXXFLAGS_WARN_OFF', 'QMAKE_CXXFLAGS_WARN_ON', 'QMAKE_DISTCLEAN',
                    \ 'QMAKE_EXTENSION_SHLIB', 'QMAKE_EXTENSION_STATICLIB', 'QMAKE_EXT_MOC', 'QMAKE_EXT_UI',
                    \ 'QMAKE_EXT_PRL', 'QMAKE_EXT_LEX', 'QMAKE_EXT_YACC', 'QMAKE_EXT_OBJ', 'QMAKE_EXT_CPP', 'QMAKE_EXT_H',
                    \ 'QMAKE_EXTRA_COMPILERS', 'QMAKE_EXTRA_TARGETS', 'QMAKE_FAILED_REQUIREMENTS',
                    \ 'QMAKE_FRAMEWORK_BUNDLE_NAME', 'QMAKE_FRAMEWORK_VERSION', 'QMAKE_HOST', 'QMAKE_INCDIR',
                    \ 'QMAKE_INCDIR_EGL', 'QMAKE_INCDIR_OPENGL', 'QMAKE_INCDIR_OPENGL_ES2', 'QMAKE_INCDIR_OPENVG',
                    \ 'QMAKE_INCDIR_X11', 'QMAKE_INFO_PLIST', 'QMAKE_LFLAGS', 'QMAKE_LFLAGS_CONSOLE',
                    \ 'QMAKE_LFLAGS_DEBUG', 'QMAKE_LFLAGS_PLUGIN', 'QMAKE_LFLAGS_RPATH', 'QMAKE_LFLAGS_REL_RPATH',
                    \ 'QMAKE_REL_RPATH_BASE', 'QMAKE_LFLAGS_RPATHLINK', 'QMAKE_LFLAGS_RELEASE', 'QMAKE_LFLAGS_APP',
                    \ 'QMAKE_LFLAGS_SHLIB', 'QMAKE_LFLAGS_SONAME', 'QMAKE_LFLAGS_THREAD', 'QMAKE_LFLAGS_WINDOWS',
                    \ 'QMAKE_LIBDIR', 'QMAKE_LIBDIR_FLAGS', 'QMAKE_LIBDIR_EGL', 'QMAKE_LIBDIR_OPENGL',
                    \ 'QMAKE_LIBDIR_OPENVG', 'QMAKE_LIBDIR_X11', 'QMAKE_LIBS', 'QMAKE_LIBS_EGL', 'QMAKE_LIBS_OPENGL',
                    \ 'QMAKE_LIBS_OPENGL_ES1,', 'QMAKE_LIBS_OPENGL_ES2', 'QMAKE_LIBS_OPENVG', 'QMAKE_LIBS_THREAD',
                    \ 'QMAKE_LIBS_X11', 'QMAKE_LIB_FLAG', 'QMAKE_LINK_SHLIB_CMD', 'QMAKE_LN_SHLIB',
                    \ 'QMAKE_OBJECTIVE_CFLAGS', 'QMAKE_POST_LINK', 'QMAKE_PRE_LINK', 'QMAKE_PROJECT_NAME',
                    \ 'QMAKE_MAC_SDK', 'QMAKE_MACOSX_DEPLOYMENT_TARGET', 'QMAKE_MAKEFILE', 'QMAKE_QMAKE',
                    \ 'QMAKE_RESOURCE_FLAGS', 'QMAKE_RPATHDIR', 'QMAKE_RPATHLINKDIR', 'QMAKE_RUN_CC',
                    \ 'QMAKE_RUN_CC_IMP', 'QMAKE_RUN_CXX', 'QMAKE_RUN_CXX_IMP', 'QMAKE_SONAME_PREFIX', 'QMAKE_TARGET',
                    \ 'QMAKE_TARGET_COMPANY', 'QMAKE_TARGET_DESCRIPTION', 'QMAKE_TARGET_COPYRIGHT',
                    \ 'QMAKE_TARGET_PRODUCT', 'QT', 'QTPLUGIN', 'QT_VERSION', 'QT_MAJOR_VERSION', 'QT_MINOR_VERSION',
                    \ 'QT_PATCH_VERSION', 'RC_FILE', 'RC_CODEPAGE', 'RC_DEFINES', 'RC_ICONS', 'RC_LANG',
                    \ 'RC_INCLUDEPATH', 'RCC_DIR', 'REQUIRES', 'RESOURCES', 'RES_FILE', 'SIGNATURE_FILE', 'SOURCES',
                    \ 'SUBDIRS', 'TARGET', 'TEMPLATE', 'TRANSLATIONS', 'UI_DIR', 'VERSION', 'VERSION_PE_HEADER',
                    \ 'VER_MAJ', 'VER_MIN', 'VER_PAT', 'VPATH', 'WINRT_MANIFEST', 'YACCSOURCES',
                    \ '_PRO_FILE_', '_PRO_FILE_PWD_' ]
execute "syn keyword qmakeBuiltinVarName ".join(s:builtInVars)." contained"
execute "syn keyword qmakeBuiltinVarVal ".join(s:builtInVars)." contained"
syn match qmakeBuiltinVarName /\v<(TARGET_(EXT|x(\.y\.z)?))>/ contained
syn match qmakeBuiltinVarVal /\v<(TARGET_(EXT|x(\.y\.z)?))>/ contained

" Built-in properties (as of Qt 5.8)
let s:builtInProps = [ 'QMAKE_SPEC', 'QMAKE_VERSION', 'QMAKE_XSPEC', 'QT_HOST_BINS', 'QT_HOST_DATA', 'QT_HOST_PREFIX',
                     \ 'QT_INSTALL_ARCHDATA', 'QT_INSTALL_BINS', 'QT_INSTALL_CONFIGURATION', 'QT_INSTALL_DATA',
                     \ 'QT_INSTALL_DOCS', 'QT_INSTALL_EXAMPLES', 'QT_INSTALL_HEADERS', 'QT_INSTALL_IMPORTS',
                     \ 'QT_INSTALL_LIBEXECS', 'QT_INSTALL_LIBS', 'QT_INSTALL_PLUGINS', 'QT_INSTALL_PREFIX',
                     \ 'QT_INSTALL_QML', 'QT_INSTALL_TESTS', 'QT_INSTALL_TRANSLATIONS', 'QT_SYSROOT', 'QT_VERSION' ]
execute "syn keyword qmakeBuiltinProp ".join(s:builtInProps)." contained"

" Built-in macros (as of Qt 5.8)
let s:builtInMacros = [ 'absolute_path', 'basename', 'cat', 'clean_path', 'dirname', 'enumerate_vars', 'escape_expand',
                      \ 'find', 'first', 'format_number', 'fromfile', 'getenv', 'join', 'last', 'list', 'lower',
                      \ 'member', 'num_add', 'prompt', 'quote', 're_escape', 'relative_path', 'replace', 'sprintf',
                      \ 'resolve_depends', 'reverse', 'section', 'shadowed', 'shell_path', 'shell_quote', 'size',
                      \ 'sort_depends', 'sorted', 'split', 'str_member', 'str_size', 'system', 'system_path',
                      \ 'system_quote', 'take_first', 'take_last', 'unique', 'upper', 'val_escape' ]
execute "syn keyword qmakeBuiltinMacro ".join(s:builtInMacros)." contained"

" Built-in functions (as of Qt 5.8)
let s:builtInFuncs = [ 'cache', 'CONFIG', 'contains', 'count', 'debug', 'defined', 'equals', 'error', 'eval', 'exists',
                     \ 'export', 'files', 'for', 'greaterThan', 'if', 'include', 'infile', 'isActiveConfig', 'isEmpty',
                     \ 'isEqual', 'lessThan', 'load', 'log', 'message', 'mkpath', 'packagesExist',
                     \ 'prepareRecursiveTarget', 'qtCompileTest', 'qtHaveModule', 'requires', 'system', 'touch',
                     \ 'unset', 'warning', 'write_file' ]
execute 'syn match qmakeBuiltinFunc /\v<('.join(s:builtInFuncs, '|').')>\s*(\(.*\))@=/'


" Scopes
syn match qmakeScope /[0-9A-Za-z_+-]\+:/he=e-1
syn match qmakeScope /[0-9A-Za-z_+-]\+|\@=/
syn match qmakeScope /|\@<=[0-9A-Za-z_+-]\+/
syn match qmakeScope /[0-9A-Za-z_+-]\+\s*{/he=e-1

hi def link qmakeNextLine Statement
hi def link qmakeComment Comment
hi def link qmakeEscapedChar Special
hi def link qmakeQuotedString String
hi def link qmakeVarDecl Identifier
hi def link qmakeVarAssign String
hi def link qmakeVarValue PreProc
hi def link qmakeMacroParens PreProc
hi def link qmakeMacroArgs String
hi def link qmakeMacroComma PreProc
hi def link qmakeEnvValue PreProc
hi def link qmakePropValue PreProc
hi def link qmakeUserMacroDecl Keyword
hi def link qmakeUserMacroName Identifier
hi def link qmakeUserFuncDecl Keyword
hi def link qmakeUserFuncName Identifier
hi def link qmakeFuncReturn Keyword
hi def link qmakeFuncReturnArgs String
hi def link qmakeBuiltinVarName Keyword
hi def link qmakeBuiltinVarVal constant
hi def link qmakeBuiltinProp constant
hi def link qmakeBuiltinMacro constant
hi def link qmakeBuiltinFunc Function
hi def link qmakeScope Conditional
hi def link qmakeOptionsQTConst			constant
hi def link qmakeOptionsCONFIGConst		constant
hi def link qmakeOptionsQT Keyword
hi def link qmakePath String
hi def link qmakePathDot String
hi def link qmakeCppFlag constant
let b:current_syntax = "qmake"
