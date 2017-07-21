let s:save_cpo = &cpo
set cpo&vim

call unite#util#set_default('g:unite_source_grouping_ignore_pattern', '\(.xls$\|.xlsm$\|.xlsx$\|.class$\|.zip$\|.jpeg$\|.jpg$\|.gif$\|.png$\|.pdf$\|.db$\)')
"
let s:source = {}

function! s:source.gather_candidates(args, context)
  return s:create_sources(self.paths)
endfunction

function! unite#sources#grouping#define()
  return map(deepcopy(g:unite_source_grouping_places),
        \   'extend(copy(s:source),
        \    extend(v:val, {"name": "grouping/" . v:val.name,
        \   "description": "candidates from history of " . v:val.name}))')
endfunction

function! s:create_sources(paths)
  if !exists('g:unite_source_grouping_places')
    let g:unite_source_grouping_places = [{'name' : 'app', 'paths' : [{'path' : '/src'}]}]
  endif

  let root = s:grouping_root()
  if root == "" | return [] | end

  let files = []
  for p in a:paths
    if !has_key(p, 'path') | let p['path'] = '' | endif
     let files += map(split(globpath(root . p.path , '**') , '\n') , '{
                 \ "name" : fnamemodify(v:val , ":t:r") ,
                 \ "path" : v:val,
                 \ "info" : p,
                 \ }')
  endfor

  let list = []
  for f in files
    if isdirectory(f.path) | continue | endif
    if (has_key(f.info, 'ext') && fnamemodify(f.path, ":e") != f.info.ext) | continue | endif

    if g:unite_source_grouping_ignore_pattern != '' && f.path =~ g:unite_source_grouping_ignore_pattern
        continue
    endif

    call add(list , {
            \ "abbr" : substitute(f.path , root . f.info.path . '/' , '' , ''),
            \ "word" : substitute(f.path , root . f.info.path . '/' , '' , ''),
            \ "kind" : "file" ,
            \ "action__path"      : f.path ,
            \ "action__directory" : fnamemodify(f.path , ':p:h:h') ,
            \ })
  endfor

  return list
endfunction

function! s:grouping_root()
  let dir = split(system("git rev-parse --show-toplevel"), "\n")[0]
  return  dir
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
