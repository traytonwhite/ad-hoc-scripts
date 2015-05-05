#!/usr/bin/env perl
#===============================================================================
#
#         FILE: readxlsfiles.pl
#
#        USAGE: ./readxlsfiles.pl directory outputfile.csv > debugfile.log
#
#  DESCRIPTION: Cycle through all of the xls files in a directory and grab
#               specific cells of data and print out to a CSV along with other
#               file information.
#
#               This assumes a certain consistent layout for each file
#
#               For file type 1:
#                       main number in cell O2
#                       retail2 name in cell N7
#                       retail1 name in cell H7
#                       end user name in cell B7
#
#               For file type 2, 2 options:
#                   Option 1:
#                       main number in cell T2
#                       retail1 name in cell D8
#                       end user name in cell J8
#
#                   Option 2:
#                       main number in cell S2
#                       retail1 name in cell D8
#                       end user name in cell J8
#
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Trayton White (tbw), tbw@traytonwhite.com
# ORGANIZATION: None
#      VERSION: 4.0
#      CREATED: 03/17/2014 17:01:48
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use autodie;
use feature 'switch';
use Modern::Perl;
use experimental 'smartmatch';
use Text::CSV;
use Spreadsheet::ParseExcel;

my $indir = $ARGV[0];
my $outfile = $ARGV[1];

my $csv = Text::CSV->new ({
        binary => 1
        , auto_diag => 1
        , sep_char => ","
        , always_quote => 1
        , eol => "\n"
        , allow_loose_quotes => 1
        , escape_char => "~"
});

open(my $out, '>:encoding(utf8)', $outfile);

my $status;

# print out header for csv file, add any additional columns here
my $header = [
    "file name"
    , "sheet name"
    , "type"
    , "main number"
    , "retail2 account"
    , "retail1 account"
    , "end user account"
];
$status = $csv->print($out, $header);

for my $xlsfile (glob qq("${indir}*.xls")) {
    eval {
        open(my $infile, '<', $xlsfile);
        my $parser = Spreadsheet::ParseExcel->new();
        my $workbook = $parser->parse($infile);
        for my $sheet ( $workbook->worksheets() ) {
            my $quote = "";
            my $disti = "";
            my $reseller = "";
            my $enduser = "";
            my $quotetype = "";
            my $sheetname = $sheet->get_name() // "";
            if ($sheet->get_cell(1,14)) {
                if ($sheet->get_cell(1,14)->value() =~ /quote #:/i) {
                    $quotetype = "reseller";
                    $quote = $sheet->get_cell(1, 18) ? $sheet->get_cell(1, 18)->value() : "";
                    $disti = "no disti";
                    $reseller = $sheet->get_cell(7, 3) ? $sheet->get_cell(7, 3)->value() : "";
                    $enduser = $sheet->get_cell(7, 9) ? $sheet->get_cell(7, 9)->value() : "";
                } else {
                    $quotetype = "distributor";
                    $quote = $sheet->get_cell(1, 14) ? $sheet->get_cell(1, 14)->value() : "";
                    $disti = $sheet->get_cell(6, 13) ? $sheet->get_cell(6, 13)->value() : "";
                    $reseller = $sheet->get_cell(6, 7) ? $sheet->get_cell(6, 7)->value() : "";
                    $enduser = $sheet->get_cell(6, 1) ? $sheet->get_cell(6, 1)->value() : "";
                }
            } elsif ($sheet->get_cell(1, 19)) {
                $quotetype = "reseller";
                $quote = $sheet->get_cell(1, 19) ? $sheet->get_cell(1, 19)->value() : "";
                $disti = "no disti";
                $reseller = $sheet->get_cell(7, 3) ? $sheet->get_cell(7, 3)->value() : "";
                $enduser = $sheet->get_cell(7, 9) ? $sheet->get_cell(7, 9)->value() : "";
            } else {
                $quotetype = "this file did not seem to match layouts - check into more";
            }
            my $record = [
                $xlsfile
                , $sheetname
                , $quotetype
                , $quote
                , $disti
                , $reseller
                , $enduser
            ];
            $status = $csv->print($out, $record);
        }
        close($infile);
    };

    given ($@) {
        when ('')       { say "No error for filename: $xlsfile" }
        when ('open')   { say "Error from opening filename: $xlsfile" }
        when (':io')    { say "Non-open, IO error from filename: $xlsfile" }
        when (':all')   { say "All other autodie errors related to filename: $xlsfile" }
        default         { say "Some other error happened not related to autodie: $xlsfile $@" }
    }
}
