#!/bin/bash

# Copyright (c) 2014 Alexander Heinrich <alxhnr@nudelpost.de>
#
# This software is provided 'as-is', without any express or implied
# warranty. In no event will the authors be held liable for any damages
# arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
#    1. The origin of this software must not be misrepresented; you must
#       not claim that you wrote the original software. If you use this
#       software in a product, an acknowledgment in the product
#       documentation would be appreciated but is not required.
#
#    2. Altered source versions must be plainly marked as such, and must
#       not be misrepresented as being the original software.
#
#    3. This notice may not be removed or altered from any source
#       distribution.

function die
{
  test -n "$@" && echo "ctrlp-find-cache: $@" 1>&2
  exit 1
}

test $# == 0 && die "no arguments specified."

search_path=$(readlink -e "$1") || die "'$1' does not exist."
test -d "$search_path" || die "'$1' is not a directory."
shift

if [[ -n "$XDG_CACHE_HOME" ]] ; then
  cache_dir="$XDG_CACHE_HOME/ctrlp-find-cache"
else
  cache_dir="$HOME/.cache/ctrlp-find-cache"
fi
mkdir -p "$cache_dir" || die "failed to create cache directory."

cache_filename=$(base64 -w 0 <<< "$search_path")
cache_filename=${cache_filename//\//%}
cache_filepath=$cache_dir/$cache_filename
lockdir="$cache_dir/.%lockdir%$cache_filename"
unset owning_find_process

mkdir "$lockdir" >/dev/null 2>&1
if [[ $? -eq 0 ]] ; then
  LANG="en" find "$search_path" "$@" |& \
    grep -v "^find: \`.*': Permission denied$" > "$lockdir/cache" &
  find_pid=$!
  find_cache_pid=$$
  echo -n "$find_pid" > "$lockdir/find_pid"
  echo -n "$find_cache_pid" > "$lockdir/find_cache_pid"
  owning_find_process=1
else
  find_pid=$(cat "$lockdir/find_pid" 2>/dev/null)
  find_cache_pid=$(cat "$lockdir/find_cache_pid" 2>/dev/null)
  if [[ -z "$find_pid" || -z "$find_cache_pid" ]] ; then
    die "please remove inconsistent lock directories from cache."
  fi
fi

# Finishes a search, which must be started by this processes. Check
# $owning_find_process first, before calling this function. It will return
# 1, if removing the lockdir failed.
function finish_search
{
  while kill -0 $find_pid 2>/dev/null; do sleep 0.1; done
  mv "$lockdir/cache" "$cache_filepath"
  rm "$lockdir/find_pid" "$lockdir/find_cache_pid"
  rmdir "$lockdir" 2>/dev/null || return 1
}

if [[ -e "$cache_filepath" ]] ; then
  cat "$cache_filepath"
  test -n "$owning_find_process" && finish_search &
else
  if [[ -n "$owning_find_process" ]] ; then
    finish_search || die "failed to remove lockdir."
  else
    while kill -0 $find_pid $find_cache_pid 2>/dev/null; do sleep 0.1; done
    test ! -e "$cache_filepath" && test -e "$lockdir" && \
      die "please remove orphaned lock directories from cache."
  fi

  cat "$cache_filepath"
fi
