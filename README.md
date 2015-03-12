gedcom-merge
=============================

A simple tool to merge one or more GEDCOMs with matching individual ids. This script does not do any internal
data inspection to merge fields from multiple instances of the individual; it will only choose the first
instance of the individual it comes across and ignore any duplicates.

Usage:

    ./merge.pl file1 file2 file3 -o output_file
