#!/usr/bin/env bash

# Host-tool launcher for the vendored SCons 3.0.1.
#
# SCons 3.0.x supports both Python 2.7 and Python 3.5+, so a Python 3
# interpreter is accepted as a fallback when Python 2 is not installed
# (Ubuntu 22.04 dropped python2 from the archive).

case "${0##*/}" in
	pywrap.sh) arg1="";;
	*) arg1="$0.py" ;;
esac

for bin in python2 python2.7 python; do
    case "$($bin -V 2>&1)" in
        "Python 2"*) exec $bin $arg1 "$@" ;;
    esac
done

for bin in python3 python; do
    case "$($bin -V 2>&1)" in
        "Python 3"*) exec $bin $arg1 "$@" ;;
    esac
done

echo "Unable to find a Python interpreter for executing ${arg1:+$arg1 }$@ !" >&2
exit 1
