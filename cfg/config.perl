#!/usr/bin/perl

# Each "make deploy" and "make withdraw" from all subdirectories will
# load this file *before* the directory's `Dewifile'.

#set_opt('verbose', 'true');

read_dewifile($DEWI{DOT_DEWI} . "/addons/simple-filter");
read_dewifile($DEWI{DOT_DEWI} . "/addons/nuke-deadlinks");

end();
