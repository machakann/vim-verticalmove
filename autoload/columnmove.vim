" columnmove.vim - bring cursor vertically in similar ways as line-wise
"                    commands

" Because of my preference these commands ignore folded lines in default.

" Vertical f, t, F, T commands would only take into account the range
" displayed. Because I assumed no one can remember precise characters in the
" same column out of one's sight.

" If there are vicinal lines with no character in the same column (for
" example, vicinal empty line), vertical w, b, e, ge assume there is a space.

let s:save_cpo = &cpo
set cpo&vim

let s:type_num  = type(0)
let s:type_str  = type('')
let s:type_list = type([])
let s:type_dict = type({})

" for vertical ';', ',' commands
" first factor is the kind of command (f, t, F, T)
" second factor is the character searched last.
let s:search_history = ['', '']

" load vital
let s:V  = vital#of('columnmove')
let s:Sl = s:V.import('Data.List')
let s:s  = s:V.import('Prelude')
unlet s:V

""" mapping functions
" vertical 'f' commands "{{{
function! columnmove#f(mode, ...)
  return s:columnmove_ftFT('f', a:mode, a:0, a:000)
endfunction
"}}}
" vertical 't' commands "{{{
function! columnmove#t(mode, ...)
  return s:columnmove_ftFT('t', a:mode, a:0, a:000)
endfunction
"}}}
" vertical 'F' commands "{{{
function! columnmove#F(mode, ...)
  return s:columnmove_ftFT('F', a:mode, a:0, a:000)
endfunction
"}}}
" vertical 'T' commands "{{{
function! columnmove#T(mode, ...)
  return s:columnmove_ftFT('T', a:mode, a:0, a:000)
endfunction
"}}}
" vertical ';' commands "{{{
function! columnmove#semicolon(mode, ...)
  let kind   = s:search_history[0]
  let char   = s:search_history[1]

  if kind != ''
    " count assginment
    let l:count = (a:0 > 0 && a:1 > 0) ? a:1 : v:count1

    " for the user configuration
    let options_dict = (a:0 > 1) ? a:2 : {}

    " do not update history
    call extend(options_dict, {'update_history' : 0})

    " call well-suited command
    let output = columnmove#{kind}(a:mode, char, l:count, options_dict)
  else
    let output = ''
  endif

  return output
endfunction
"}}}
" vertical ',' commands "{{{
function! columnmove#comma(mode, ...)
  let kind = s:search_history[0]
  let char = s:search_history[1]

  if kind != ''
    " count assginment
    let l:count = (a:0 > 0 && a:1 > 0) ? a:1 : v:count1

    " for the user configuration
    let options_dict = (a:0 > 1) ? a:2 : {}

    " do not update history
    call extend(options_dict, {'update_history' : 0})

    " call well-suited command
    let output = columnmove#{tr(kind, 'ftFT', 'FTft')}(a:mode, char, l:count, options_dict)
  else
    let output = ''
  endif

  return output
endfunction
"}}}
" vertical 'w' commands "{{{
function! columnmove#w(mode, ...)
  return s:columnmove_wbege('w', a:mode, a:0, a:000)
endfunction
"}}}
" vertical 'b' commands "{{{
function! columnmove#b(mode, ...)
  return s:columnmove_wbege('b', a:mode, a:0, a:000)
endfunction
"}}}
" vertical 'e' commands "{{{
function! columnmove#e(mode, ...)
  return s:columnmove_wbege('e', a:mode, a:0, a:000)
endfunction
"}}}
" vertical 'ge' commands  "{{{
function! columnmove#ge(mode, ...)
  return s:columnmove_wbege('ge', a:mode, a:0, a:000)
endfunction
"}}}
" vertical 'W' commands "{{{
function! columnmove#W(mode, ...)
  return s:columnmove_wbege('W', a:mode, a:0, a:000)
endfunction
"}}}
" vertical 'B' commands "{{{
function! columnmove#B(mode, ...)
  return s:columnmove_wbege('B', a:mode, a:0, a:000)
endfunction
"}}}
" vertical 'E' commands "{{{
function! columnmove#E(mode, ...)
  return s:columnmove_wbege('E', a:mode, a:0, a:000)
endfunction
"}}}
" vertical 'gE' commands  "{{{
function! columnmove#gE(mode, ...)
  return s:columnmove_wbege('gE', a:mode, a:0, a:000)
endfunction
"}}}

""" subfuncs
" common
function! s:user_conf(name, arg, default)    "{{{
  let user_conf = a:default

  if !empty(a:arg)
    if type(a:arg) == s:type_dict
      if has_key(a:arg, a:name)
        return a:arg[a:name]
      endif
    endif
  endif

  if exists('g:columnmove_' . a:name)
    let user_conf = g:columnmove_{a:name}
  endif

  if exists('t:columnmove_' . a:name)
    let user_conf = t:columnmove_{a:name}
  endif

  if exists('w:columnmove_' . a:name)
    let user_conf = w:columnmove_{a:name}
  endif

  if exists('b:columnmove_' . a:name)
    let user_conf = b:columnmove_{a:name}
  endif

  return user_conf
endfunction
"}}}
function! s:user_mode_conf(name, arg, default, mode)    "{{{
  let user_conf = a:default

  if !empty(a:arg)
    if type(a:arg) == s:type_dict
      if has_key(a:arg, a:name)
        if type(a:arg[a:name]) == s:type_dict
          return get(a:arg[a:name], a:mode, a:default)
        elseif type(a:arg[a:name]) == s:type_num
          return a:arg[a:name]
        endif
      endif
    endif
  endif

  if exists('g:columnmove_' . a:name)
    let type_val = g:columnmove_{a:name}

    if type(type_val) == s:type_dict
      let user_conf = get(g:columnmove_{a:name}, a:mode, a:default)
    elseif type(type_val) == s:type_num
      let user_conf = g:columnmove_{a:name}
    endif
  endif

  if exists('t:columnmove_' . a:name)
    let type_val = t:columnmove_{a:name}

    if type(type_val) == s:type_dict
      let user_conf = get(t:columnmove_{a:name}, a:mode, a:default)
    elseif type(type_val) == s:type_num
      let user_conf = t:columnmove_{a:name}
    endif
  endif

  if exists('w:columnmove_' . a:name)
    let type_val = w:columnmove_{a:name}

    if type(type_val) == s:type_dict
      let user_conf = get(w:columnmove_{a:name}, a:mode, a:default)
    elseif type(type_val) == s:type_num
      let user_conf = w:columnmove_{a:name}
    endif
  endif

  if exists('b:columnmove_' . a:name)
    let type_val = b:columnmove_{a:name}

    if type(type_val) == s:type_dict
      let user_conf = get(b:columnmove_{a:name}, a:mode, a:default)
    elseif type(type_val) == s:type_num
      let user_conf = b:columnmove_{a:name}
    endif
  endif

  return user_conf
endfunction
"}}}
function! s:check_raw(arg)    "{{{
  if has_key(a:arg, 'raw')
    return a:arg['raw']
  endif

  return 0
endfunction
"}}}
function! s:fold_opener(line, currentline, level)  "{{{
  let foldlevel   = foldlevel(a:line)
  if foldlevel < 0 | return [] | endif

  if a:level < 0
    let currentlevel = foldlevel(a:currentline)
    if currentlevel < 0 | return [] | endif
    let rel_depth   = foldlevel - currentlevel

    if rel_depth < 0
      let nth = foldlevel
    elseif rel_depth <= (-1)*a:level
      let nth = rel_depth
    else
      let nth = 0
    endif
  elseif foldlevel <= a:level
    let nth = a:level - foldlevel + 1
  else
    return []
  endif

  let opened_fold = []
  while nth > 0
    let fold_start = foldclosed(a:line)
    if fold_start < 0 | return opened_fold | endif
    let fold_end   = foldclosedend(a:line)

    execute a:line . 'foldopen'
    let opened_fold += [[fold_start, fold_end]]
    let nth -= 1
  endwhile

  return opened_fold
endfunction
"}}}
function! s:fold_closer(line, opened_fold)  "{{{
  for fold in reverse(a:opened_fold)
    if a:line < fold[0] || a:line > fold[1]
      execute fold[0] . 'foldclose'
    endif
  endfor
endfunction
"}}}
function! s:getchar_from_same_column(string, thr_col, cutup, null)  "{{{
  " This function returns the first character beyond 'thr_col' which is the
  " column width on a display.

  " NOTE: 'cutup' is the maximum number of characters which can be put within
  "       'thr_col' bytes. It should be 1 or larger.

  let chars = split(a:string, '\zs')[: a:cutup-1]
  let len   = len(chars)
  let top   = len - 1
  let bot   = -top
  let idx   = top

  if a:string == ''
    return a:null
  endif

  if a:thr_col <= 0
    return [chars[0], 0]
  endif

  if strdisplaywidth(a:string) <= a:thr_col
    return a:null
  endif

  if strdisplaywidth(join(chars[: a:thr_col-1], '')) == a:thr_col
    return [chars[a:thr_col], a:thr_col]
  endif

  if strdisplaywidth(chars[0]) > a:thr_col
    return [chars[0], 0]
  endif

  " binary search
  while 1
    let width = strdisplaywidth(join(chars[: idx], ''))

    if width == a:thr_col
      let idx += 1
      break
    elseif top - bot <= 1
      let idx = top
      break
    elseif width < a:thr_col
      let bot = idx
    else
      let top = idx
    endif

    let idx = (top + bot)/2
  endwhile

  let col = (idx > 0) ? strlen(join(chars[: idx - 1], '')) : 0

  return [chars[idx], col]
endfunction"}}}
function! s:add_topline(dest_view) "{{{
  let dest_view = a:dest_view
  let line = a:dest_view.lnum
  let col  = a:dest_view.col

  let err = setpos('.', [0, line, col, 0])
  if !err
    return extend(dest_view, winsaveview(), 'keep')
  else
    return a:dest_view
  endif
endfunction
"}}}

" vertical f, t, F, T
function! s:columnmove_ftFT(kind, mode, argn, args) "{{{
  " count assginment
  let l:count = (a:argn > 1 && a:args[1] > 0) ? a:args[1] : v:count1

  " re-entering to the visual mode (if necessary)
  if (a:mode ==# 'x') && ((mode() !=? 'v') && (mode() != "\<C-v>"))
    normal! gv
  endif

  " searching for the user configuration
  let options_dict = (a:argn > 2) ? a:args[2] : {}

  " target character assignment
  let char = (a:argn > 0) ? a:args[0] : ''

  " save view
  let view = winsaveview()

  " resolving user configuration
  let opt = {}
  let opt.fold_open      = s:user_mode_conf('fold_open', options_dict, 0, a:mode)
  let opt.ignore_case    = s:user_conf(   'ignore_case', options_dict, &ignorecase)
  let opt.highlight      = s:user_conf(     'highlight', options_dict, 1)
  let opt.update_history = s:user_conf('update_history', options_dict, 1)
  let opt.expand_range   = s:user_conf(  'expand_range', options_dict, 0)
  let opt.auto_scroll    = s:user_conf(   'auto_scroll', options_dict, 0)
  let opt.raw            = s:check_raw(options_dict)

  " searching for destinations
  if char != ''
    let dest_view = s:get_dest_ftFT_with_char(a:kind, a:mode, char, l:count, view, opt)
  else
    let dest_view = s:get_dest_ftFT(a:kind, a:mode, l:count, view, opt)
  endif

  if opt.raw
    let output = deepcopy(dest_view)
    let output.col      += 1
    let output.curswant += 1
  else
    let output = ''
  endif

  let opened_fold = remove(dest_view, 'opened_fold')

  " move cursor
  if (opt.raw != 1) && (dest_view.lnum > 0)
    if (v:version > 704) || (v:version == 704 && has('patch310'))
      call setpos('.', [0, dest_view.lnum, dest_view.col+1, 0, dest_view.curswant+1])
    else
      call winrestview(s:add_topline(dest_view))
    endif
  endif

  " close unnecessary fold
  if opened_fold != []
    call s:fold_closer(line('.'), opened_fold)
  endif

  return output
endfunction
"}}}
function! s:get_dest_ftFT(kind, mode, count, view, opt)  "{{{
  let l:count  = a:count
  let virtcol  = virtcol(".")
  let initline = a:view.lnum
  let col      = a:view.col    " NOTE: not equal col('.')!
  let curswant = a:view.curswant
  let cutup    = max([virtcol, col('.')])

  " gather buffer lines
  if a:kind =~# '[ft]'
    " down
    if a:opt.auto_scroll
      normal! zt
    endif

    let startline = (a:kind ==# 'f') ? initline + 1 : initline + 2

    if a:opt.expand_range < 0
      let endline = line("$")
    else
      let fileend = line("$")
      let endline = line("w$") + a:opt.expand_range
      let endline = (endline > fileend) ? fileend : endline
    endif

    let inc  = 1
    let edge = 'end'

    let whole_lines = getline(startline, endline)
    let line_num    = endline - startline
  elseif a:kind =~# '[FT]'
    " up
    if a:opt.auto_scroll
      normal! zb
    endif

    let startline = (a:kind ==# 'F') ? initline - 1 : initline - 2

    if a:opt.expand_range < 0
      let endline = 1
    else
      let endline = line("w0") - a:opt.expand_range
      let endline = (endline < 1) ? 1 : endline
    endif

    let inc  = -1
    let edge = 'start'

    let whole_lines = reverse(getline(endline, startline))
    let line_num    = startline - endline
  endif

  " determine the threshold column (=curswant)
  let char_width     = strdisplaywidth(matchstr(getline(initline), '.', col))
  let acceptable_gap = char_width - 1
  let curswant       = (curswant - virtcol + char_width <= acceptable_gap)
        \            ? curswant : (virtcol - char_width)

  " collecting characters in same column as cursor
  let idx         = 0
  let line        = startline

  let chars       = []
  let cols        = []
  let lines       = []
  let opened_fold = []

  if (a:opt.fold_open != 0) && (a:kind =~# '[tT]')
    " fold opening
    let opened_fold += s:fold_opener(initline + inc, initline, a:opt.fold_open)
  endif

  while idx <= line_num
    let fold_start = foldclosed(line)
    let fold_end   = foldclosedend(line)
    if fold_start < 0
      let [c, col] = s:getchar_from_same_column(whole_lines[idx], curswant, cutup, ['', -1])
      let chars += [c]
      let cols  += [col]
      let lines += [line]
      let idx   += 1
      let line  += inc
    else
      if a:opt.fold_open != 0
        let opened_fold += s:fold_opener(line, initline, a:opt.fold_open)
        let fold_start   = foldclosed(line)
        let fold_end     = foldclosedend(line)
      endif

      if a:opt.expand_range >= 0
        if a:kind =~# '[ft]'
          let endline  = line("w$") + a:opt.expand_range
          let endline  = (endline > fileend) ? fileend : endline
          let line_num = endline - startline
        elseif a:kind =~# '[FT]'
          let endline  = line("w0") - a:opt.expand_range
          let endline  = (endline < 1) ? 1 : endline
          let line_num = startline - endline
        endif
      endif

      if fold_start < 0
        continue
      else
        let chars += ['']
        let cols  += [-1]
        let lines += [line]
        let idx   += (fold_{edge} - line) * inc + 1
        let line   = fold_{edge} + inc
      endif
    endif
  endwhile

  " picking up candidates
  let prefix = a:opt.ignore_case ? '\m\c' : '\m\C'

  let highlight_pos = []
  let uniq_chars     = s:Sl.uniq_by(filter(copy(chars), '!empty(v:val)'), 'v:val')
  for c in copy(uniq_chars)
    let pattern = prefix . s:s.escape_pattern(c)
    let idx     = match(chars, pattern, 0, a:count)
    if idx >= 0
      let highlight_pos += [[lines[idx], cols[idx]]]
    else
      call remove(uniq_chars, match(uniq_chars, pattern))
    endif
  endfor
  if highlight_pos == [] | return {'lnum': -1, 'col': -1, 'curswant': -1, 'opened_fold': opened_fold} | endif

  " highlighting candidates
  if a:opt.highlight
    let id_list = map(copy(highlight_pos), "s:highlight_add(v:val[0], v:val[1]+1)")
    redraw
  endif

  " target character assginment
  let key = nr2char(getchar())

  " delete highlighting
  if a:opt.highlight
    call map(id_list, "s:highlight_del(v:val)")
    redraw
  endif

  if key == "" | return {'lnum': -1, 'col': -1, 'curswant': -1, 'opened_fold': opened_fold} | endif

  " update history
  if a:opt.update_history
    let s:search_history = [a:kind, key]
  endif

  let pattern = prefix . s:s.escape_pattern(key)
  let idx     = match(uniq_chars, pattern)

  if idx < 0
    " can not find target
    if a:opt.auto_scroll
      call winrestview(a:view)
    endif

    return {'lnum': -1, 'col': -1, 'curswant': -1, 'opened_fold': opened_fold}
  endif

  if a:kind ==# 't'
    let output = {'lnum': highlight_pos[idx][0] - 1, 'col': highlight_pos[idx][1], 'curswant': curswant, 'opened_fold': opened_fold}
  elseif a:kind ==# 'T'
    let output = {'lnum': highlight_pos[idx][0] + 1, 'col': highlight_pos[idx][1], 'curswant': curswant, 'opened_fold': opened_fold}
  else
    let output = {'lnum': highlight_pos[idx][0], 'col': highlight_pos[idx][1], 'curswant': curswant, 'opened_fold': opened_fold}
  endif

  return output
endfunction
"}}}
function! s:get_dest_ftFT_with_char(kind, mode, c, count, view, opt)  "{{{
  let l:count  = a:count
  let virtcol  = virtcol(".")
  let initline = a:view.lnum
  let col      = a:view.col    " NOTE: not equal col('.')!
  let curswant = a:view.curswant
  let cutup    = max([virtcol, col('.')])

  " update history
  if a:opt.update_history
    let s:search_history = [a:kind, a:c]
  endif

  " defining the searching range
  if a:kind =~# '[ft]'
    " down
    if a:opt.auto_scroll
      normal! zt
    endif

    let startline = (a:kind ==# 'f') ? initline + 1 : initline + 2

    if a:opt.expand_range < 0
      let endline = line("$")
    else
      let fileend = line("$")
      let endline = line("w$") + a:opt.expand_range

      let endline = (endline > fileend) ? fileend : endline
    endif

    let inc  = 1
    let edge = 'end'

    let whole_lines = getline(startline, endline)
  elseif a:kind =~# '[FT]'
    " up
    if a:opt.auto_scroll
      normal! zb
    endif

    let startline = (a:kind ==# 'F') ? initline - 1 : initline - 2

    if a:opt.expand_range < 0
      let endline = 1
    else
      let endline = line("w0") - a:opt.expand_range

      let endline = (endline < 1) ? 1 : endline
    endif

    let inc  = -1
    let edge = 'start'

    let whole_lines = reverse(getline(endline, startline))
  endif

  " determine the threshold column (=curswant)
  let char_width     = strdisplaywidth(matchstr(getline(initline), '.', col))
  let acceptable_gap = char_width - 1
  let curswant       = (curswant - virtcol + char_width <= acceptable_gap)
        \            ? curswant : (virtcol - char_width)

  " searching for the destination
  let idx      = 0
  let line     = startline
  let prefix   = a:opt.ignore_case ? '\m\c' : '\m\C'
  let pattern  = prefix . s:s.escape_pattern(a:c)
  let line_num = len(whole_lines) - 1

  let opened_fold = []

  if (a:opt.fold_open != 0) && (a:kind =~# '[tT]')
    " fold opening
    let opened_fold += s:fold_opener(initline + inc, initline, a:opt.fold_open)
  endif

  while idx <= line_num
    let fold_start = foldclosed(line)
    let fold_end   = foldclosedend(line)
    if fold_start < 0
      let [c, col] = s:getchar_from_same_column(whole_lines[idx], curswant, cutup, ['', -1])
      if c =~ pattern | break | endif " found!
      let idx   += 1
      let line  += inc
    else
      if a:opt.fold_open != 0
        let opened_fold += s:fold_opener(line, initline, a:opt.fold_open)
        let fold_start   = foldclosed(line)
        let fold_end     = foldclosedend(line)
      endif

      if a:opt.expand_range >= 0
        if a:kind =~# '[ft]'
          let endline  = line("w$") + a:opt.expand_range
          let endline  = (endline > fileend) ? fileend : endline
          let line_num = endline - startline
        elseif a:kind =~# '[FT]'
          let endline  = line("w0") - a:opt.expand_range
          let endline  = (endline < 1) ? 1 : endline
          let line_num = startline - endline
        endif
      endif

      if fold_start < 0
        continue
      else
        let idx   += (fold_{edge} - line) * inc + 1
        let line   = fold_{edge} + inc
      endif
    endif
  endwhile

  " restore view
  call winrestview(a:view)

  " could not find
  if idx > line_num | return {'lnum': -1, 'col': -1, 'curswant': -1, 'opened_fold': opened_fold} | endif

  if a:kind ==# 't'
    let output = {'lnum': line - 1, 'col': col, 'curswant': curswant, 'opened_fold': opened_fold}
  elseif a:kind ==# 'T'
    let output = {'lnum': line + 1, 'col': col, 'curswant': curswant, 'opened_fold': opened_fold}
  else
    let output = {'lnum': line, 'col': col, 'curswant': curswant, 'opened_fold': opened_fold}
  endif

  return output
endfunction
"}}}
function! s:highlight_add(row, col) "{{{
  let pattern   = '\%' . a:row . 'l\%' . a:col . 'c.'
  let id = matchadd("IncSearch", pattern)
  return id
endfunction
"}}}
function! s:highlight_del(id) "{{{
  call matchdelete(a:id)

  return
endfunction
"}}}

" vertical w, b, e, ge, W, B, E, gE
function! s:columnmove_wbege(kind, mode, argn, args) "{{{
  " count assginment
  let l:count = (a:argn > 0 && a:args[0] > 0) ? a:args[0] : v:count1

  " re-entering to the visual mode (if necessary)
  if (a:mode ==# 'x') && ((mode() !=? 'v') && (mode() != "\<C-v>"))
    normal! gv
  endif

  " searching for the user configuration
  let options_dict = (a:argn > 1) ? a:args[1] : {}

  " save view
  let init_view = winsaveview()

  " resolving user configuration
  let opt = {}
  let opt.fold_open      = s:user_mode_conf('fold_open', options_dict, 0, a:mode)
  let opt.strict_wbege   = s:user_conf(  'strict_wbege', options_dict, 1)
  let opt.fold_treatment = s:user_conf('fold_treatment', options_dict, 0)
  let opt.raw            = s:check_raw(options_dict)

  " searching for the destination
  let dest_view   = s:get_dest_wbege(a:kind, l:count, init_view, opt)

  if opt.raw
    let output = deepcopy(dest_view)
    let output.col      += 1
    let output.curswant += 1
  else
    let output = ''
  endif

  let opened_fold = remove(dest_view, 'opened_fold')

  " move cursor
  if (opt.raw != 1) && (dest_view.lnum > 0)
    if (v:version > 704) || (v:version == 704 && has('patch310'))
      call setpos('.', [0, dest_view.lnum, dest_view.col+1, 0, dest_view.curswant+1])
    else
      call winrestview(s:add_topline(dest_view))
    endif
  endif

  " close unnecessary fold
  if opened_fold != []
    call s:fold_closer(line('.'), opened_fold)
  endif

  return output
endfunction
"}}}
function! s:get_dest_wbege(kind, count, view, opt)  "{{{
  let l:count     = a:count
  let virtcol     = virtcol('.')
  let initline    = a:view.lnum
  let col         = a:view.col    " NOTE: not equal col('.')!
  let curswant    = a:view.curswant
  let cutup       = max([virtcol, col('.')])
  let opened_fold = []

  if a:kind ==# 'w'
    " the case for w command
    let inc       = 1
    let edge      = 'end'
    let endline   = line('$')
    let lines     = getline(initline, endline)
    let threshold = endline - initline
  elseif a:kind ==# 'b'
    " the case for b command
    let inc       = -1
    let edge      = 'start'
    let lines     = reverse([' '] + getline(1, initline))
    let threshold = initline
  elseif a:kind ==# 'e'
    " the case for e command
    let inc       = 1
    let edge      = 'end'
    let endline   = line('$')
    let lines     = getline(initline, endline) + [' ']
    let threshold = endline - initline + 1
  elseif a:kind ==# 'ge'
    " the case for ge command
    let inc       = -1
    let edge      = 'start'
    let lines     = reverse(getline(1, initline))
    let threshold = initline - 1
  elseif a:kind ==# 'W'
    " the case for W command
    let inc       = 1
    let edge      = 'end'
    let endline   = line('$')
    let lines     = getline(initline, endline)
    let threshold = endline - initline
  elseif a:kind ==# 'B'
    " the case for b command
    let inc       = -1
    let edge      = 'start'
    let lines     = reverse([''] + getline(1, initline))
    let threshold = initline
  elseif a:kind ==# 'E'
    " the case for e command
    let inc       = 1
    let edge      = 'end'
    let endline   = line('$')
    let lines     = getline(initline, endline) + ['']
    let threshold = endline - initline + 1
  elseif a:kind ==# 'gE'
    " the case for gE command
    let inc       = -1
    let edge      = 'start'
    let lines     = reverse(getline(1, initline))
    let threshold = initline - 1
  endif

  if ((a:kind =~# '[wbe]') || (a:kind ==# 'ge')) && (!a:opt.strict_wbege)
    let null_char = ['', -1]
  else
    let null_char = [' ', -1]
  endif

  " determine the threshold column (=curswant)
  let char_width     = strdisplaywidth(matchstr(lines[0], '.', col))
  let acceptable_gap = char_width - 1
  let curswant       = (lines[0] == '') ? 0
        \            : (curswant - virtcol + char_width <= acceptable_gap) ? curswant
        \            : (virtcol - char_width)

  if a:opt.fold_open != 0
    " fold opening
    let opened_fold += s:fold_opener(initline, initline, a:opt.fold_open)
  endif

  " check folding
  let fold_start = foldclosed(initline)
  let fold_end   = foldclosedend(initline)

  " jump folded parts if necessary
  if fold_{edge} >= 0
    " The current line is still folded
    let line = fold_{edge}  " line number of the destination
    let idx  = (fold_{edge} - line) * inc
  else
    let line = initline  " line number of the destination
    let idx  = 0
  endif

  let [c, col] = (fold_{edge} < 0)
        \      ? s:getchar_from_same_column(lines[idx], curswant, cutup, null_char)
        \      : null_char
  let is_target_cur = s:check_c(a:kind, c, a:opt)

  let output = {'lnum': -1, 'col': -1, 'curswant': -1, 'opened_fold': opened_fold}
  while l:count > 0
    let idx  += 1
    if idx > threshold
      return output
    endif
    let line  += inc

    if a:opt.fold_open != 0
      " fold opening
      let opened_fold += s:fold_opener(line, initline, a:opt.fold_open)
    endif

    let fold_start = foldclosed(line)
    let fold_end   = foldclosedend(line)

    if (fold_{edge} >= 0) && (a:opt.fold_treatment == 0)
      " skip folded lines
      while 1
        let idx += (fold_{edge} - line) * inc + 1
        let line = fold_{edge} + inc  " line number of the destination

        if a:kind ==? 'w' || a:kind ==? 'e'
          if (line > endline) | return output | endif
        elseif a:kind ==? 'b' || a:kind =~# 'g[eE]'
          if (line < 1) | return output | endif
        endif

        if a:opt.fold_open != 0
          " fold opening
          let opened_fold += s:fold_opener(line, initline, a:opt.fold_open)
        endif

        let fold_start = foldclosed(line)
        let fold_end   = foldclosedend(line)

        if (fold_{edge} < 0) | break | endif
      endwhile
    endif

    let is_target_pre = is_target_cur
    let [c, col] = (fold_{edge} < 0)
          \      ? s:getchar_from_same_column(lines[idx], curswant, cutup, null_char)
          \      : null_char
    let is_target_cur = s:check_c(a:kind, c, a:opt)

    let [idx, line, l:count, output]
          \ = s:judge(a:kind, a:opt, fold_{edge}, is_target_pre, is_target_cur,
          \           l:count, inc, idx, line, col, curswant, opened_fold, output)
  endwhile

  return output
endfunction
"}}}
function! s:check_c(kind, c, opt) "{{{
  if a:kind =~# '[wbe]' || a:kind ==# 'ge'
    if a:opt.strict_wbege
      " strict w, b, e, ge
      " space, tab   : -1
      " keyword chars:  1
      " other chars  :  0
      return (a:c =~ '\m\s') ? -1 : ((a:c =~ '\m\k') ? 1 : 0)
    else
      " spoiled w, b, e, ge
      " empty    : 1
      " not empty: 0
      return (a:c == '') ? 1 : 0
    endif
  else
    " W, B, E, gE
    " space    : 1
    " not space: 0
    return (a:c =~ '\m\s') ? 1 : 0
  endif
endfunction
"}}}
function! s:judge(kind, opt, fold_edge, is_target_pre, is_target_cur, count, inc, idx, line, col, curswant, opened_fold, output)  "{{{
  " FIXME: Too much arguments!
  let idx       = a:idx
  let line      = a:line
  let l:count   = a:count
  let output    = a:output

  if a:kind ==# 'w' || a:kind ==# 'ge'
    if a:opt.strict_wbege
      " strict w, ge

      " the containt of is_target_***
      " space, tab   : -1
      " keyword chars:  1
      " other chars  :  0

      if a:fold_edge >= 0
        " The current line is folded
        let idx  += (a:fold_edge - a:line) * a:inc
        let line  = a:fold_edge
      elseif a:is_target_pre < 0
        " The previous is empty or space
        if a:is_target_cur >= 0
          let l:count -= 1
          let output = {'lnum': a:line, 'col': a:col, 'curswant': a:curswant, 'opened_fold': a:opened_fold}
        endif
      elseif !(a:is_target_pre == a:is_target_cur)
        " a different kind of character as previous one
        if a:is_target_cur >= 0
          let l:count -= 1
          let output = {'lnum': a:line, 'col': a:col, 'curswant': a:curswant, 'opened_fold': a:opened_fold}
        endif
      endif
    else
      " spoiled w, ge

      " the containt of is_target_***
      " empty    : 1
      " not empty: 0

      if a:fold_edge >= 0
        " The current line is folded
        let idx  += (a:fold_edge - a:line) * a:inc
        let line  = a:fold_edge
      elseif (a:is_target_pre && !a:is_target_cur)
        " The previous line is empty and the current line is not empty
        let l:count -= 1
        let output = {'lnum': a:line, 'col': a:col, 'curswant': a:curswant, 'opened_fold': a:opened_fold}
      endif
    endif
  elseif a:kind ==# 'b' || a:kind ==# 'e'
    if a:opt.strict_wbege
      " strict b, e

      " the containt of is_target_***
      " space, tab   : -1
      " keyword chars:  1
      " other chars  :  0

      if a:fold_edge >= 0
        " The current line is folded
        if a:is_target_pre >= 0
          " The previous character is not space
          if a:output.lnum > 0
            let l:count -= 1
          endif
        endif

        let idx  += (a:fold_edge - a:line) * a:inc
        let line  = a:fold_edge
      elseif a:is_target_pre < 0
        " The previous is empty or space
        if a:is_target_cur > -1
          let output = {'lnum': a:line, 'col': a:col, 'curswant': a:curswant, 'opened_fold': a:opened_fold}
        endif
      elseif a:is_target_pre == a:is_target_cur
        " a same kind of character as previous one
        let output = {'lnum': a:line, 'col': a:col, 'curswant': a:curswant, 'opened_fold': a:opened_fold}
      else
        " a different kind of character as previous one
        if a:output.lnum > 0
          let l:count -= 1
        endif

        if (l:count > 0) && (a:is_target_cur > -1)
          let output = {'lnum': a:line, 'col': a:col, 'curswant': a:curswant, 'opened_fold': a:opened_fold}
        endif
      endif
    else
      " spoiled b, e

      " the containt of is_target_***
      " empty    : 1
      " not empty: 0

      if a:fold_edge >= 0
        " The current line is folded
        if !a:is_target_pre && a:output.lnum > 0
          let l:count -= 1
        endif

        let idx  += (a:fold_edge - a:line) * a:inc
        let line  = a:fold_edge
      elseif (a:is_target_cur && !a:is_target_pre)
        " The current line is empty and the previous line is not empty
        if a:output.lnum > 0
          let l:count -= 1
        endif
      elseif !a:is_target_cur
        let output = {'lnum': a:line, 'col': a:col, 'curswant': a:curswant, 'opened_fold': a:opened_fold}
      endif
    endif
  elseif a:kind ==# 'W' || a:kind ==# 'gE'
    " W, gE

    " the containt of is_target_***
    " space    : 1
    " not space: 0

    if a:fold_edge >= 0
      " The current line is folded
      let idx  += (a:fold_edge - a:line) * a:inc
      let line  = a:fold_edge
    elseif (a:is_target_pre && !a:is_target_cur)
      " The previous line is empty and the current line is not empty
      let l:count -= 1
      let output = {'lnum': a:line, 'col': a:col, 'curswant': a:curswant, 'opened_fold': a:opened_fold}
    endif
  elseif a:kind ==# 'B' || a:kind ==# 'E'
    " B, E

    " the containt of is_target_***
    " space    : 1
    " not space: 0

    if a:fold_edge >= 0
      " The current line is folded
      if !a:is_target_pre && a:output.lnum > 0
        let l:count -= 1
      endif

      let idx  += (a:fold_edge - a:line) * a:inc
      let line  = a:fold_edge
    elseif a:is_target_cur && !a:is_target_pre
      " The current line is empty and the previous line is not empty
      if a:output.lnum > 0
        let l:count -= 1
      endif
    elseif !a:is_target_cur
      let output = {'lnum': a:line, 'col': a:col, 'curswant': a:curswant, 'opened_fold': a:opened_fold}
    endif
  endif

  return [idx, line, l:count, output]
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set foldmethod=marker:
" vim:set commentstring="%s:
