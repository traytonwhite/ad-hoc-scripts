#!/usr/bin/env perl
#===============================================================================
#
#         FILE: boomiatomdataload.pl
#
#        USAGE: ./boomiatomdataload.pl filepath fileprefix letterstart letterend
#
#  DESCRIPTION: This script uses WWW::Mechanize::Firefox to control a Firefox
#               session and use Boomi to load data files using a local test atom
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Trayton White (tbw), tbw@traytonwhite.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 01/30/2014 00:14:41
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use autodie;
use WWW::Mechanize::Firefox;
use File::Copy qw(cp);

my $mech = WWW::Mechanize::Firefox->new(
    activate => 1,
    autoclose => 0,
    tab => qr/^Boomi/
#    log => ['debug']
);

my $filepath = $ARGV[0];
my $fileprefix = $ARGV[1];
my $start = $ARGV[2];
my $end = $ARGV[3];

my $loaddir = "/Volumes/C/boomiatom/customer/in/";

for ($start..$end) {
    my $filename = $fileprefix . $_;
#    my @cpargs = ("cp", $filepath . $filename, $loaddir);
#    system(@cpargs);
    cp($filepath . $filename, $loaddir);

    # click run a test
    $mech->click({ xpath => '/html/body/div[4]/div[2]/div/div[3]/div/div[2]/div/div[4]/div/div[2]/div/div[3]/div/div[3]/div/div[2]/div/div[3]/div/div[2]/div/div[2]/div/div/div/div/ul/li[7]/div', synchronize => 0});
    sleep(20);

    # click run test
    $mech->click({ xpath => '/html/body/div[5]/div/table/tbody/tr[2]/td[2]/div/div/div[2]/table/tbody/tr/td/button', synchronize => 0 });
    sleep(20);

    # check for the green highlight graphic on the stop sign in the
    # Boomi load GUI
    while (! $mech->is_visible( xpath => '/html/body/div[4]/div[2]/div/div[3]/div/div[2]/div/div[4]/div/div[2]/div/div[3]/div/div[3]/div/div[2]/div/div[3]/div/div[2]/div/div[3]/div/div[3]/div/div[4]/div/div[3]/div/div/div/div[47]/div[4][@class="gwt-TestShape greenGlow"]' )) {
        sleep(30);
        print "checked load completion\n";
    }
    print "load completed for $filename \n";
    sleep(30);

    # click return to edit mode
    $mech->click({ xpath => '/html/body/div[4]/div[2]/div/div[3]/div/div[2]/div/div[4]/div/div[2]/div/div[3]/div/div[3]/div/div[2]/div/div[3]/div/div[2]/div/div[2]/div/div[2]/div/div/ul/li[5]/div/div[2]', synchronize => 0 });
    sleep(15);

    # delete file that was loaded
    unlink $loaddir . $filename;
    print "deleted $filename \n";
#    my @rmargs = ("rm", $loaddir . $filename);
#    system(@rmargs);
    print "completed $_ \n";
}

print "completed loading\n";
