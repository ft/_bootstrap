#!/bin/sh

# Concept:
#  When I'm getting access to a new machine, I want my setups to be
#  available with the least possible hassle. The different setup
#  files are available via VCS. Deployment is done using `dewi'.
#  This script is used to initialise a root directory and import
#  my costum changes to the `.dewi' directory.
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
    command make deploy
)
