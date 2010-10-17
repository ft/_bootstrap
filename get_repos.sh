#!/bin/sh

# How do we figure out which repos I actually want on a system?
#
#  There are `list/*' files which define categories of repositories
#  to fetch. Each line of a file name a repo name.
#  The `REPO_ROOT_URI' environment variable can be used to direct this
#  script to a certain git server, which holds the dotfile repositories.
#
#  Say `lists/core' looks like this:
#      zsh
#      screen
#      tmux
#  That to get these repos, we need to do this:
#      % ./get_repos.sh core
#
#  Multiple categories may be given at once.

REPO_ROOT_URI=${REPO_ROOT_URI:-git://git.0x50.de/ft/dotfiles/}

if [ $# -lt 1 ]; then
    printf 'usage: get_repos.sh <CATEGORY/IES...>\n'
    exit 1
fi

#command() { echo "$@"; }

if [ "x$1" = 'x-l' ]; then
    printf 'Available repository categories:\n'
    for file in lists/*; do
        case "$file" in
            \#*) continue ;;
            *~) continue ;;
        esac
        printf '  %s\n' "${file##*/}"
    done
    exit 0
fi

fail=0
for cat in "$@"; do
    if [ ! -e lists/"$cat" ]; then
        printf 'Unknown category: `%s'\''.\n' "$cat"
        fail=1
    fi
done

if [ "$fail" != 0 ]; then
    printf 'Giving up.\n'
    exit 1
fi

for cat in "$@"; do
    while IFS= read -r repo; do
        printf 'Cloning `%s'\''...\n' "$repo"
        if [ -d ../"$repo" ]; then
            printf '  Directory `%s'\'' exists. Skipping.\n' "$repo"
            continue
        fi
        (
            cd ..
            command git clone "$REPO_ROOT_URI"/"$repo".git "$repo"
        )
    done < ./lists/"$cat"
done

exit 0
