"AUTHOR:   Atsushi Mizoue <asionfb@gmail.com>
"WEBSITE:  https://github.com/AtsushiM/sass-skelton
"VERSION:  0.9
"LICENSE:  MIT

if !exists('g:cssskelton_indent')
    let g:cssskelton_indent = "    "
endif
if !exists('g:cssskelton_ignoretags')
    let g:cssskelton_ignoretags = ['head', 'title', 'meta', 'link', 'style', 'script', 'noscript', 'object', 'br', 'hr', 'embed', 'area', 'base', 'col', 'keygen', 'param', 'source']
endif

function! s:SassSkelton()
    let block_end = 0
    let tag_count = 0
    let tag_nests = []
    let tag_uniqe = []
    let fullpath = ''
    let line_no = line('.')
    let page_end = line('w$')

    while block_end != 1
        let line = getline(line_no)
        let line_end = 0

        while line_end != 1
            let tags = matchlist(line, '\v(.{-})(\<)(.{-})(\>)(.*)')

            if tags != []
                let tag_name = tags[3]
                let chk = matchlist(tag_name, '\v(^[^a-z/].*)')

                if chk == []
                    let chk = matchlist(tag_name, '\v(^/.*)')
                    if chk == []
                        let chk = matchlist(tag_name, '\v(.*/$)')

                        let tag_val = matchlist(tag_name, '\v(.{-})\s+(.*)')
                        let tag_props = ''

                        let tag_nest = {}
                        let tag_nest.tag = tag_name
                        let tag_nest.id = ''
                        let tag_nest.class = ''

                        if tag_val != []
                            let tag_name = tag_val[1]
                            let tag_props = tag_val[2]
                            let tag_prop_end = 0

                            let tag_nest.tag = tag_name

                            while tag_prop_end != 1
                                let tag_prop = matchlist(tag_props, '\v.{-}(class|id)\="(.{-})"(.*)')
                                if tag_prop != []
                                    for e in split(tag_prop[2], '\s')
                                        let tag_nest[tag_prop[1]] = e
                                    endfor

                                    let tag_props = tag_prop[3]
                                else
                                    let tag_prop_end = 1
                                endif
                            endwhile
                        endif

                        let tag_nest_ary = [tag_nest]
                        if tag_nest.id != '' && tag_nest.class != ''
                            let tag_nest_ary = add(tag_nest_ary, deepcopy(tag_nest_ary[0]))
                            let tag_nest_ary[0].id = ''
                            let tag_nest_ary[1].class = ''
                        endif

                        if count(g:cssskelton_ignoretags, tag_name) == 0
                            let tag_count = tag_count + 1
                            if chk != []
                                let tags[5] = '</'.tag_name.'>'.tags[5]
                            endif

                            let fullpath_rec = fullpath
                            for tag_nest_ary_i in tag_nest_ary
                                let tag_nest = tag_nest_ary_i
                                let tag_nest.layer = tag_count

                                let fullpath = fullpath_rec.' '.(tag_nest.layer).'-'.(tag_nest.tag).'.'.(tag_nest.class).'#'.(tag_nest.id)
                                let tag_nest.path = fullpath

                                if count(tag_uniqe, fullpath) == 0
                                    let tag_uniqe = add(tag_uniqe, fullpath)

                                    let fullpathary = split(fullpath, ' ')
                                    let nowpath = fullpathary[-1]
                                    unlet fullpathary[-1]
                                    let beforepath = join(fullpathary, ' ')
                                    if [] == matchlist(beforepath, '\v^/(.*)')
                                        let beforepath = ' '.beforepath
                                    endif

                                    if count(tag_uniqe, beforepath) == 0
                                        let tag_nests = add(tag_nests, tag_nest)
                                    else
                                        let i = 0
                                        let dlayer = -1 
                                        while i < len(tag_nests)
                                            if dlayer == -1
                                                if tag_nests[i].path == beforepath
                                                    let dlayer = tag_nests[i].layer + 1
                                                endif
                                            elseif dlayer > tag_nests[i].layer
                                                let tag_nests = insert(tag_nests, tag_nest, i)
                                                break
                                            endif
                                            let i = i + 1
                                        endwhile

                                        if i == len(tag_nests)
                                            let tag_nests = add(tag_nests, tag_nest)
                                        endif
                                    endif
                                endif
                            endfor
                        endif
                    else
                        let tag_name = matchlist(tag_name, '\v^/(.+)')[1]
                        if count(g:cssskelton_ignoretags, tag_name) == 0
                            let tag_count = tag_count - 1
                            let fullpathary = split(fullpath, ' ')
                            unlet fullpathary[-1]
                            let fullpath = join(fullpathary, ' ')
                            if [] == matchlist(fullpath, '\v^/(.*)')
                                let fullpath = ' '.fullpath
                            endif

                            if tag_name == 'body'
                                let tag_count = 0
                            endif

                            if tag_count <= 0
                                let block_end = 1
                            endif
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
    let indent = g:cssskelton_indent
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

        let phrase = s:getSelecterPhrase(obj)
        if phrase != ''
            let full = full.mindent.phrase." {\n"
        endif
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

function! s:SassSkeltonMono()
    let line = getline('.')
    let tag = {'tag':'', 'id':'', 'class':''}

    let tags = matchlist(line, '\v(.{-})(\<)(.{-})(\>)(.*)')
    if tags != []
        let tag_name = tags[3]
        let tag_val = matchlist(tag_name, '\v(.{-})\s+(.*)')

        if tag_val != []
            let tag_name = tag_val[1]
            let tag_props = tag_val[2]
            let tag_prop_end = 0

            while tag_prop_end != 1
                let tag_prop = matchlist(tag_props, '\v.{-}(class|id)\="(.{-})"(.*)')
                if tag_prop != []
                    for e in split(tag_prop[2], '\s')
                        let tag[tag_prop[1]] = e
                    endfor

                    let tag_props = tag_prop[3]
                else
                    let tag_prop_end = 1
                endif
            endwhile
        endif

        let tag.tag = tag_name
    endif

    let ret = s:getSelecterPhrase(tag)
    if ret != ''
        let ret = ret." {\n}\n"
        let @@ = ret
        echo 'Yanked CSS Skelton Mono.'
    else
        echo 'No Yanked.'
    endif
    let @@ = ret
endfunction

function! s:getSelecterPhrase(obj)
    let tag = a:obj.tag
    let class = a:obj.class
    let id = a:obj.id

    if class.id != ''
        let tag = ''
        if class != ''
            let tag = tag.'.'.class
        endif
        if id != ''
            let tag = tag.'#'.id
        endif
    endif

    return tag
endfunction

command! SassSkeltonMono call s:SassSkeltonMono()
command! SassSkelton call s:SassSkelton()
