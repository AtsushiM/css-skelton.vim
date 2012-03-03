"AUTHOR:   Atsushi Mizoue <asionfb@gmail.com>
"WEBSITE:  https://github.com/AtsushiM/RetinaResize.vim
"VERSION:  0.9
"LICENSE:  MIT

let g:cssskelton_ignoretags = ['script', 'noscript','br', 'img']
let g:cssskelton_outputselecter = ['tag', 'id', 'class']

function! s:CssSkelton()
    let block_end = 0
    let tag_count = 0
    let tag_dict = {'tag':[], 'id':[], 'class':[]}
    let line_no = line('.')

    while block_end != 1
        let line = getline(line_no)
        let line_end = 0
        " let block_end = 1

        while line_end != 1
            let tags = matchlist(line, '\v(.{-})(\<)(.{-})(\>)(.*)')

            if tags != []
                let tag_name = tags[3]
                let chk = matchlist(tag_name, '\v(^!--.*)')

                if chk == []
                    let chk = matchlist(tag_name, '\v(^/.*)')
                    if chk == []
                        let chk = matchlist(tag_name, '\v(.*/$)')
                        if chk == []
                            let tag_count = tag_count + 1
                        endif

                        let tag_val = matchlist(tag_name, '\v(.{-})\s+(.*)')
                        let tag_props = ''

                        if tag_val != []
                            let tag_name = tag_val[1]
                            let tag_props = tag_val[2]
                            let tag_prop_end = 0

                            while tag_prop_end != 1
                                let tag_prop = matchlist(tag_props, '\v.{-}(class|id)\="(.{-})"(.*)')
                                if tag_prop != []
                                    let dict = tag_dict[tag_prop[1]]

                                    for e in split(tag_prop[2], '\s')
                                        if count(dict, e) == 0
                                            let dict = add(dict, e)
                                        endif
                                    endfor

                                    let tag_props = tag_prop[3]
                                else
                                    let tag_prop_end = 1
                                endif
                            endwhile
                        endif

                        let dict = tag_dict['tag']
                        if count(g:cssskelton_ignoretags, tag_name) == 0 && count(dict, tag_name) == 0
                            let dict = add(dict, tag_name)
                        endif
                    else
                        let tag_count = tag_count - 1

                        if tag_count <= 0
                            let block_end = 1
                        endif
                    endif
                endif

                let line = tags[5]
            else
                let line_end = 1
                let line_no = line_no + 1
            endif
        endwhile
    endwhile

    " echo skelton
    let ret = ''
    if count(g:cssskelton_outputselecter, 'tag')
        for e in tag_dict['tag']
            let ret = ret.e." {}\n"
        endfor
    endif
    if count(g:cssskelton_outputselecter, 'id')
        for e in tag_dict['id']
            let ret = ret.'#'.e." {}\n"
        endfor
    endif
    if count(g:cssskelton_outputselecter, 'class')
        for e in tag_dict['class']
            let ret = ret.'.'.e." {}\n"
        endfor
    endif

    if ret != ''
        let @@ = ret
    endif
endfunction

command! CssSkelton call s:CssSkelton()