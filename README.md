# ctrlp-find-cache

Asynchronous cache for [ctrlp.vim](https://github.com/kien/ctrlp.vim). This
plugin spawns _find_ as a background process to cache its output for
subsequent runs. Thus you can only search trough files, which already
existed at the time of the previous search.

This plugin depends on [ctrlp.vim](https://github.com/kien/ctrlp.vim),
bash, and various commands from
[coreutils](https://www.gnu.org/software/coreutils/). Almost all GNU/Linux
distributions have them preinstalled already.

## Configuration

By default this plugin works out of the box. If you have not set
**g:ctrlp\_user\_command**, it will be set for you. The content of this
variable will be the concatenation of the following two variables:

### g:ctrlp\_find\_cache#command

This variable contains the full path to the find-cache shell script, which
provides the core functionality of this plugin.

### g:ctrlp\_find\_cache#arguments

This variable contains extra arguments, which will be passed to _find_. It
defaults to various flags, which are needed to skip VCS directories, cache
directories, build files and various file formats which Vim can't open.

If you don't set this variable, it will be set to this:

```vim
let g:ctrlp_find_cache#arguments =
  \ "-type f -regextype posix-extended -not -regex"
  \ . " '^(.*\/)?(\.(cache|fontconfig|thumbnails|git)|build|CMakeFiles)(\/.*)?'"
  \ . " -not -iregex '^.*\.(o|a|so|exe|dll|bin|pyc|gz|xz|bz2|zip|rar|pdf"
  \ . "|png|jpe?g|ico|gif|xpm|bak)$'"
  \ . " -not -regex '^.*[a-f]\d[a-f0-9]{10,}.*$'"
```

Changing this variable after Vim has started won't affect ctrlp, unless you
also update **g:ctrlp\_user\_command**.

## License

Released under the zlib license.
