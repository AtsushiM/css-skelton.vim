"AUTHOR:   Atsushi Mizoue <asionfb@gmail.com>
"WEBSITE:  https://github.com/AtsushiM/css-skelton.vim
"VERSION:  0.9
"LICENSE:  MIT

if !exists('g:cssskelton_type')
    let g:cssskelton_type = "css"
endif
if !exists('g:cssskelton_indent')
    let g:cssskelton_indent = "    "
endif
if !exists('g:cssskelton_ignoretags')
    let g:cssskelton_ignoretags = ['head', 'title', 'meta', 'link', 'style', 'script', 'noscript', 'object', 'br', 'hr', 'embed', 'area', 'base', 'col', 'keygen', 'param', 'source']
endif
if !exists('g:cssskelton_ignoreclass')
    let g:cssskelton_ignoreclass = ['clearfix']
endif
if !exists('g:cssskelton_ignoreid')
    let g:cssskelton_ignoreid = []
endif

command! CssSkeltonMono call cssskelton#CssSkeltonMono()
command! CssSkelton call cssskelton#CssSkelton()
command! CssOutput call cssskelton#CssOutput()
