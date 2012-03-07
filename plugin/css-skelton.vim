"AUTHOR:   Atsushi Mizoue <asionfb@gmail.com>
"WEBSITE:  https://github.com/AtsushiM/RetinaResize.vim
"VERSION:  0.9
"LICENSE:  MIT

if !exists('g:cssskelton_ignoretags')
    let g:cssskelton_ignoretags = ['html', 'head', 'title', 'meta', 'link', 'style', 'body', 'script', 'noscript', 'object', 'br', 'img',  'hr', 'meta', 'input', 'embed', 'area', 'base', 'col', 'keygen', 'link', 'param', 'source']
endif
if !exists('g:cssskelton_outputselecter')
    let g:cssskelton_outputselecter = ['tag', 'class', 'id']
endif

function! s:CssSkelton()
    let block_end = 0
    let tag_count = 0
    let tag_nests = []
    let tag_dict = {'tag':[], 'id':[], 'class':[]}
    let line_no = line('.')
    let page_end = line('w$')
    let sign = {'tag':'', 'id':'#', 'class':'.'}

    while block_end != 1
        let line = getline(line_no)
        let line_end = 0
        " let block_end = 1

        while line_end != 1
            let tags = matchlist(line, '\v(.{-})(\<)(.{-})(\>)(.*)')

            if tags != []
                let tag_name = tags[3]
                let chk = matchlist(tag_name, '\v(^!.*)')

                if chk == []
                    let chk = matchlist(tag_name, '\v(^/.*)')
                    if chk == []
                        let chk = matchlist(tag_name, '\v(.*/$)')
                        if chk != []
                            let tags[5] = '</dammyskelton>'.tags[5]
                        endif
                        let tag_count = tag_count + 1

                        let tag_val = matchlist(tag_name, '\v(.{-})\s+(.*)')
                        let tag_props = ''

                        let tag_nest = {}
                        let tag_nest.tag = tag_name
                        let tag_nest.id = ''
                        let tag_nest.class = ''
                        let tag_nest.layer = tag_count

                        if tag_val != []
                            let tag_name = tag_val[1]
                            let tag_props = tag_val[2]
                            let tag_prop_end = 0

                            let tag_nest.tag = tag_name

                            while tag_prop_end != 1
                                let tag_prop = matchlist(tag_props, '\v.{-}(class|id)\="(.{-})"(.*)')
                                if tag_prop != []
                                    let dict = tag_dict[tag_prop[1]]

                                    for e in split(tag_prop[2], '\s')
                                        let tag_nest[tag_prop[1]] = e
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

                        let tag_nests = add(tag_nests, tag_nest)

                    else
                        let tag_count = tag_count - 1

                        if tag_name == '/body'
                            let tag_count = 0
                        endif

                        if tag_count <= 0
                            let block_end = 1
                        endif
                    endif
                endif

                let line = tags[5]
            else
                let line_end = 1
                let line_no = line_no + 1

                if line_no > page_end
                    let block_end = 1
                endif
            endif
        endwhile
    endwhile

    let ret = ''

    let full = ''
    let indent = '    '
    let mindent = ''
    let bindent = mindent
    let layer = 0
    for obj in tag_nests
        let i = 1
        let bindent = mindent
        if obj.layer <= layer
            let l = layer - obj.layer
            if l == 0
                let full = full.bindent."}\n"
            else
                while l + 1 > 0
                    let layer = layer - 1
                    let cl = layer
                    let mindent = ''
                    while cl > 0
                        let mindent = mindent.indent
                        let cl = cl - 1
                    endwhile
                    let full = full.mindent."}\n"
                    let l = l - 1
                endwhile
            endif
        endif
        let mindent = ''
        while i < obj.layer
            let mindent = mindent.indent
            let i = i + 1
        endwhile
        let full = full.mindent.s:getSelecterPhrase(obj)." {\n"
        let layer = obj.layer
    endfor

    let i = layer
    while i > 0
        let j = 1
        let mindent = ''
        while j < i
            let mindent = mindent.indent
            let j = j + 1
        endwhile
        let full = full.mindent."}\n"
        let i = i - 1
    endwhile

    let ret = full

    if ret != ''
        let @@ = ret
        echo 'Yanked CSS Skelton.'
    else
        echo 'No Yanked.'
    endif
endfunction

function! s:getSelecterPhrase(obj)
    let tag = a:obj.tag
    let class = a:obj.class
    let id = a:obj.id

    if class == '' && id == ''
        return tag
    else
        let tag = ''
        if class != ''
            let tag = tag.'.'.class
        endif
        if id != ''
            let tag = tag.'#'.id
        endif

        return tag
    endif
endfunction

command! CssSkelton call s:CssSkelton()
