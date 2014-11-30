" Copyright (c) 2014 Alexander Heinrich <alxhnr@nudelpost.de> {{{
"
" This software is provided 'as-is', without any express or implied
" warranty. In no event will the authors be held liable for any damages
" arising from the use of this software.
"
" Permission is granted to anyone to use this software for any purpose,
" including commercial applications, and to alter it and redistribute it
" freely, subject to the following restrictions:
"
"    1. The origin of this software must not be misrepresented; you must
"       not claim that you wrote the original software. If you use this
"       software in a product, an acknowledgment in the product
"       documentation would be appreciated but is not required.
"
"    2. Altered source versions must be plainly marked as such, and must
"       not be misrepresented as being the original software.
"
"    3. This notice may not be removed or altered from any source
"       distribution.
" }}}

if exists('g:loaded_ctrlp_find_cache')
  finish
endif
let g:loaded_ctrlp_find_cache = 1

" Require the existence of various programs.
for program in [ 'bash', 'base64', 'readlink' ]
  if !executable(program)
    echomsg "ctrlp-find-cache: error: the program '" . program
      \ . "' was not found."
    let s:unmet_requirements = 1
  endif

  if exists('s:unmet_requirements')
    finish
  endif
endfor

if !exists('g:ctrlp_find_cache#command')
  let g:ctrlp_find_cache#command =
    \ expand('<sfile>:p:h:h') . '/ctrlp-find-cache.sh'
endif

if !exists('g:ctrlp_find_cache#arguments')
  let g:ctrlp_find_cache#arguments =
    \ "-type f -regextype posix-extended -not -regex"
    \ . " '^(.*\/)?(\.(cache|fontconfig|git)|build|CMakeFiles)(\/.*)?'"
    \ . " -not -iregex '^.*\.(o|a|so|exe|dll|bin|pyc|gz|xz|bz2|zip|rar|pdf"
    \ . "|png|jpe?g|ico|gif|xpm|bak)$'"
    \ . " -not -regex '^.*[a-f]\d[a-f0-9]{10,}.*$'"
endif

if !exists('g:ctrlp_user_command')
  let g:ctrlp_user_command = g:ctrlp_find_cache#command . ' %s '
    \ . g:ctrlp_find_cache#arguments
endif

let g:ctrlp_use_caching = 0
