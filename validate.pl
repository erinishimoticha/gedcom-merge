#!/usr/bin/perl -w

use strict;
use Gedcom;

my $ged = Gedcom->new(
    grammar_version => "5.5",
    gedcom_file => shift
);
