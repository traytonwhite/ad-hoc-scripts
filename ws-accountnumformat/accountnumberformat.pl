#!/usr/bin/env perl
#===============================================================================
#
#         FILE: accountnumberformat.pl
#
#        USAGE: ./accountnumberformat.pl < inputfilename > outputfilename
#
#  DESCRIPTION: Convert 9 digit numbers into account number format
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Trayton White (tbw), tbw@traytonwhite.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 06/10/2013 10:41:01 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

while (<>) {
    next if ($_ == 0 && $_ ne '0'); # skip if not a number
    my $num = sprintf("%09d", $_);  # convert to zero-filled, right-justifiied
    $num =~ s/([0-9]{4})([0-9]{3})([0-9{2}])/$1-$2-$3/; # add hyphens
    print $num, "\n"; # output
}
