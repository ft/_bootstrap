#!/usr/bin/perl

use warnings;
use strict;

my ($src, %cats, %sources);

sub fill_cat {
    my ($cat) = @_;
    my ($fh);

    open $fh, '<', "lists/$cat" or die "Couldn't open `lists/$cat': $!\n";
    while (my $line = <$fh>) {
        chomp $line;
        push @{ $cats{$cat} }, $line;
    }
    close $fh;
}

sub fill_source {
    my ($src) = @_;
    my ($fh);

    open $fh, '<', "sources/$src" or die "Couldn't open `sources/$src': $!\n";
    while (my $line = <$fh>) {
        chomp $line;
        my ($name, $repo) = $line =~ m/^(\w+)\s+(.*)/;
        $sources{$src}{$name} = $repo;
    }
    close $fh;
}

sub get_repo {
    my ($src, $repo) = @_;
    my (@cmd);

    if (!defined $sources{$src}{$repo}) {
        print "`$repo' not available on `$src'. Skipping.\n";
        return 0;
    }
    if (-d $repo) {
        print "`$repo' already exists. Skipping.\n";
        return 0;
    }
    @cmd = ( 'git', 'clone', $sources{$src}{$repo}, $repo );
    system @cmd;
    return 1;
}

sub __get_files {
    my ($dir) = @_;
    my ($dh, @files);

    opendir $dh, "$dir" or die "Couldn't open dir `$dir': $!\n";
    @files = grep { ! m/^\./ && ! m/~$/ && ! m/^#/ } readdir $dh;
    closedir $dh;

    return @files;
}

sub __list_files {
    my ($dir) = @_;
    my (@files);

    @files = __get_files($dir);
    foreach my $file (@files) {
        print "  ", $file, "\n";
    }

    return $#files + 1;
}

sub list_categories {
    my ($rc);

    print "Available categories:\n\n";
    $rc = __list_files('lists');
    print "\n$rc categor" . ($rc > 1 ? 'ies' : 'y') . " in total.\n";
}

sub list_sources {
    my ($rc);

    print "Available sources:\n\n";
    $rc = __list_files('sources');
    print "\n$rc source" . ($rc > 1 ? 's' : '') . " in total.\n";
}

sub read_cats {
    foreach my $file (__get_files('lists')) {
        fill_cat($file);
    }
}

sub read_sources {
    foreach my $file (__get_files('sources')) {
        fill_source($file);
    }
}

sub usage {
    print "usage: get_repos.pl [-ls|-lc] <source-server> <categor{y,ies}>\n\n";
    print "  Options:\n";
    print "      -h         this help message\n";
    print "      -lc        list possible categories\n";
    print "      -ls        list available sources\n\n";
}

if ($#ARGV < 0) {
    usage();
    exit 1;
}

if ($ARGV[0] eq '-ls') {
    list_sources();
    exit 0;
} elsif ($ARGV[0] eq '-lc') {
    list_categories();
    exit 0;
} elsif ($ARGV[0] eq '-') {
    usage();
    exit 0;
}

if ($#ARGV < 1) {
    usage();
    exit 1;
}

read_cats();
read_sources();

$src = $ARGV[0];
shift;

if (!defined $sources{$src}) {
    die "`$src' is *not* a valid source (try \"get_repos.pl -ls\").\n";
}

chdir '..' or die "Couldn't change to updir (..). Giving up.\n";
foreach my $cat (@ARGV) {
    foreach my $repo (@{ $cats{$cat} }) {
        get_repo($src, $repo);
    }
}
