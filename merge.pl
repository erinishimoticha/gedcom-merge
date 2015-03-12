#!/usr/bin/perl

use strict;
use lib 'lib';
use ParseArgs;

my $args = ParseArgs::parse(\@ARGV);
my @endstuff;
$| = 1;
my $ind = {};

init();
process_all_files();

sub process_all_files() {
    open OUT, '>' . $args->{'o'} or die("Can't open target file.");

    # process each file, immediately printing out the individuals and saving the
    # family and submittor data to print at the end of the file.
    foreach my $filename (@{$args->{'_extra'}}) {
        print "Processing $filename\n";
        print OUT process_file($filename), "\n";
    }

    # write out the family and submittor data.
    foreach my $line (@endstuff) {
        print OUT "$line\n";
    }

    # close the file
    print OUT "0 TRLR\n";
    close OUT;
}

sub init() {
    my $options = {
        'o' => {'long' => 'outfile', 'default' => 0},
    };

    # Consolidate arguments of different forms
    foreach my $shortname (keys %$options) {
        my $longname = $options->{$shortname}{'long'};
        $args->{$shortname} = (defined $args->{$shortname} || defined $args->{$longname}) ?
            ($args->{$shortname} || $args->{$longname}) : $options->{$shortname}{'default'};
    }

    if (length($args->{'o'}) < 2) {
        print usage();
        exit 1;
    }
    print "Merging ", join(", ", @{$args->{'_extra'}}), " to create ", $args->{'o'}, "\n";
}

sub process_file($) {
    # Read in the GEDCOM and build some data structures for the sources
    # which will allow us to place each source under it's target individual
    # and field when we write the new GEDCOM back out.
    my $filename = shift;
    my $write = 0;
    my $save = 0;

    # need to write anything that comes before the first INDI, but only for the first file.
    my @keys = keys %$ind;
    if ($#keys == -1) {
        $write = 1;
    }
    my @contents;

    open INF, $filename or die("Can't open $filename");
    foreach my $line (<INF>) {
        my $curind;
        $line =~ s/\s*$//i;

        if ($line =~ /(\d) \@(\w+)\@ INDI/i) {
            if ($1 != 0) {
                print "INDI NOT FIRST LEVEL\n";
            }
            $curind = $2;
            $write = 0;
            if ($ind->{$curind}) {
                print "skipping INDI $curind\n";
            } else {
                $ind->{$curind} = 1;
                $write = 1;
                $save = 0;
            }
        } elsif ($line =~ /(\d) \@(\w+)\@ FAM/i) {
            if ($1 != 0) {
                print "FAM NOT FIRST LEVEL\n";
            }
            $curind = $2;
            $write = 0;
            if ($ind->{$curind}) {
                print "skipping FAM $curind\n";
            } else {
                $ind->{$curind} = 1;
                $write = 1;
                $save = 1;
            }
        } elsif ($line =~ /(\d) \@(\w+)\@ SUBM/i) {
            if ($1 != 0) {
                print "SUBM NOT FIRST LEVEL\n";
            }
            $curind = $2;
            $write = 0;
            if ($ind->{$curind}) {
                print "skipping SUBM $curind\n";
            } else {
                $ind->{$curind} = 1;
                $write = 1;
                $save = 1;
            }
        } elsif ($line =~ /(\d) \@(\w+)\@ SOUR/i) {
            if ($1 != 0) {
                print "SOUR NOT FIRST LEVEL\n";
            }
            $curind = $2;
            $write = 0;
            if ($ind->{$curind}) {
                print "skipping SOUR $curind\n";
            } else {
                $ind->{$curind} = 1;
                $write = 1;
                $save = 1;
            }
        } elsif ($line =~ /(\d) TRLR/i) {
            $write = 0;
        }

        if ($write) {
            if ($save) {
                push(@endstuff, $line);
            } else {
                push(@contents, $line);
            }
        }
    }
    close INF;
    return join("\n", @contents);
}

sub usage() {
    return "\tUsage:

    ./merge.pl file1 file2 file3 -o output_file

        Options:

    -o, --outfile    Output GEDCOM filename.
";
}
