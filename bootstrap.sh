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

# Concept:
#  When I'm getting access to a new machine, I want my setups to be
#  available with the least possible hassle. The different setup
#  files are available via VCS. Deployment is done using `dewi'.
#  This script is used to initialise a root directory and import
#  my custom changes to the `.dewi' directory.
#
#  Then there's another script `get_repos.sh', which gets a set of
#  repositories from the internet and puts the checkouts into the
#  parent directory. After that a `make deploy' in said parent
#  directory will deploy all available configurations for the
#  current user.

if [ "$1" != 'yes_please' ]; then
    printf 'To really run, use `yes_please'\'' as the script'\''s 1st argument.\n'
    exit 0
fi

olddir="$PWD"
cd ..
dir="$PWD"

#command() { echo "$@"; }

printf 'Bootstrapping dewi in `%s'\''...\n' "$dir"
command dewi init
(
    DEWI_ROOT="$dir"
    export DEWI_ROOT
    cd "$olddir"
    command dewi deploy
)
