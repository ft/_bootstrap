#!/bin/sh

## Copyright (c) 2010-2012
## Frank Terbeck <ft@bewatermyfriend.org>, All rights reserved.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
##
##   1. Redistributions of source code must retain the above
##      copyright notice, this list of conditions and the following
##      disclaimer.
##   2. Redistributions in binary form must reproduce the above
##      copyright notice, this list of conditions and the following
##      disclaimer in the documentation and/or other materials
##      provided with the distribution.
##
##  THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
##  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
##  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
##  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS OF THE
##  PROJECT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
##  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
##  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
##  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
##  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
##  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
##  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Most trouble

run=no
opt=no
sys=no
root=sudo
src="$HOME/src"
bin="$HOME/bin"
url='git://github.com/ft/dewi.git'

for i in "$@"; do
    case $i in
    yes_please) run=yes ;;
    o*) opt=yes ;;
    s*) sys=yes ;;
    bin=*) bin=${i#bin=} ;;
    src=*) src=${i#src=} ;;
    root=*) root=${i#root=} ;;
    url=*) url=${i#url=} ;;
    *) printf 'Unknown parameter: %s\n' "$i"
       exit 1 ;;
    esac
done

if [ "$run" = no ]; then
    cat <<EOF
usage: get_dewi.sh [PARMETER(s)]

This script helps installing the dewi framework on the system.

To actually to the deed, one of the parameters needs to be "yes_please".
The other parameters are:

   o(ptionals)   Install optional packages first (this will only work
                 on debian based systems and required root).

   s(ystem)      Install dewi via "make sys" (requires root).

   bin=...       Destination directory for the dewi symlink with non-sys
                 installations. (Default: ~/bin)

   src=...       Parent directory for the dewi source code. (Default: ~/src)

   root=...      Method for obtaining root privileges. (Either "none", "su",
                 "sudo", defaults to "sudo")

   url=...       URL of dewi's source control repository.
                 (Defaults to "git://github.com/ft/dewi.git")
EOF
    exit 0
fi

save_mkdir () {
    mkdir -p "$@" || exit 1
}

save_cd () {
    cd "$@" || exit 1
}

save_ln () {
    command ln -s "$@" || exit 1
}

as_root () {
    printf ' -!- Elevating privilegdes for: "%s"\n' "$*"
    if [ "$root" = sudo ]; then
        command sudo "$@"
    elif [ "$root" = su ]; then
        command su -c "$*" root
    elif [ "$root" = none ]; then
        "$@"
    else
        printf 'Unknown root-method: %s\n' "$root"
        exit 1
    fi
}

clone_dewi_git () {
    _old_pwd=$PWD
    save_mkdir "$src"
    save_cd "$src"
    _ans=r
    if [ -e "$bin/dewi" ]; then
        printf ' -!- %s/dewi exists. (r)emove or (U)se? ' "$src"
        read _ans
        if [ "$_ans" = r ]; then
            rm -Rf dewi
        else
            _ans=u
        fi
    fi
    if [ "$_ans" = r ]; then
        git clone "$url" dewi || exit 1
    fi
    # The next few lines are required until the dewi's "onward" branch is
    # merged into its "master" branch.
    save_cd "dewi"
    branch=$(cat .git/HEAD)
    case "$branch" in
    */onward) printf ' -!- Repository: Already on branch "onward"!\n' ;;
    *) printf ' -!- Repository: Checking out "onward" branch!\n'
       git checkout -b onward origin/onward || exit 1 ;;
    esac
    save_cd "$_old_pwd"
}

install_optionals () {
    printf ' -!- Installing optional dependencies:\n'
    for i in txt2tags libipc-run3-perl libtemplate-perl; do
        as_root apt-get install "$i"
    done
}

build_and_install_dewi () {
    _old_pwd=$PWD
    save_cd "$src/dewi"
    printf ' -!- Building dewi:\n'
    save_mkdir "$src/dewi"
    if [ "$sys" = yes ]; then
        make sys || exit 1
    else
        make || exit 1
    fi
    printf ' -!- Building documentation (optional, failure ignored):\n'
    make doc || rm -f doc/dewi.1
    if [ "$sys" = yes ]; then
        as_root make install
        if [ -e doc/dewi.1 ]; then
            as_root make install-doc
        fi
    else
        save_mkdir "$bin"
        if [ -e "$bin/dewi" ]; then
            printf ' -!- %s/dewi exists. Remove it (y/N)? ' "$bin"
            read _ans
            if [ "$_ans" = y ]; then
                printf ' -!- Removing %s/dewi\n' "$bin"
                rm -f "$bin/dewi"
            fi
        fi
        save_ln "$PWD/dewi" "$bin/dewi"
    fi
    save_cd "$_old_pwd"
}

printf ' -!- Automatic dewi installation routine\n'
[ "$opt" = yes ] && install_optionals
clone_dewi_git
build_and_install_dewi
printf ' -!- Installation complete.\n'
printf ' -!- You may need: PATH="%s:$PATH"\n' "$bin"
printf ' -!- You may need: rehash\n'
printf ' -!- Continue using: ./bootstrap.sh\n'
