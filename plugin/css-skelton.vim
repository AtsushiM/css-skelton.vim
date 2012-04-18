"AUTHOR:   Atsushi Mizoue <asionfb@gmail.com>
"WEBSITE:  https://github.com/AtsushiM/css-skelton.vim
"VERSION:  0.9
"LICENSE:  MIT

if exists("g:loaded_css_skelton")
    finish
endif
let g:loaded_css_skelton = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? CssSkeltonMono call cssskelton#CssSkeltonMono(<f-args>)
command! -nargs=? CssSkelton call cssskelton#CssSkelton(<f-args>)
command! CssPaste call cssskelton#CssPaste()

let &cpo = s:save_cpo
