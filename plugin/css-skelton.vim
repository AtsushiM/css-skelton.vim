"AUTHOR:   Atsushi Mizoue <asionfb@gmail.com>
"WEBSITE:  https://github.com/AtsushiM/css-skelton.vim
"VERSION:  0.9
"LICENSE:  MIT

command! -nargs=? CssSkeltonMono call cssskelton#CssSkeltonMono(<f-args>)
command! -nargs=? CssSkelton call cssskelton#CssSkelton(<f-args>)
command! CssPaste call cssskelton#CssPaste()
