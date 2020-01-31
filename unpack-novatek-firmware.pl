#!/usr/bin/perl
#
# unpack-novatek-firmware.pl -- Unpack Reolink/Novatek *.pak firmware files
#
# (C) 2020 Hajo Noerenberg
#
# http://www.noerenberg.de/
# https://github.com/hn/reolink-camera
#
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3.0 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>.
#


use strict;

my $write = 0;

if ($ARGV[0] eq "-w") {
    $write++;
    shift();
}

my $f = $ARGV[0];
die() if ( !$f );
open( IF, "<$f" ) || die( "Unable to open input file '$f': " . $! );
binmode(IF);

my $buf;

# 00-04 : magic?
# 04-08 : checksum?
# 08-12 : toc len?

my $pnum = 10;	# toc len? just a guess

seek( IF, 0, 0 ) || die;
read( IF, $buf, 4 );
if ($buf ne "\x13\x59\x72\x32") {	# 0x13597232 .Yr2
    die("Invalid magic");
}

for (my $p = 0; $p <= $pnum; $p++) {

    my $len = 64;
    my $offset = 12 + $p * $len;

    seek( IF, $offset, 0 ) || die;
    read( IF, $buf, $len );

#    print "Reading " . sprintf( "%4d", $len ) . " bytes at offset " . sprintf( "%5d", $offset ) . ": 0x" . sprintf( "%-32s", unpack( "H*", $buf ) ) . "\n";

    my $poff = unpack( "V", substr($buf, 56, 4));
    my $plen = unpack( "V", substr($buf, 60, 4));
    my $pname = substr($buf,  0, 32); $pname =~ s/[^[:print:]]//g;
    my $pver  = substr($buf, 32, 24); $pver  =~ s/[^[:print:]]//g;

    print "Partition " . $p . "    name: " . $pname . "\n";
    print "Partition " . $p . " version: " . $pver . "\n";
    print "Partition " . $p . "  offset: " . sprintf( "%8d", $poff ) . "\n";
    print "Partition " . $p . "  length: " . sprintf( "%8d", $plen ) . "\n";

    if ($write && $plen > 0) {
        my $basename = $f;
        $basename =~ s{^.*/|\.[^.]+$}{}g;
        my $outfile = $basename . "-partition-" . $p . "-" . $pname . ".bin";
        $outfile =~ s/\///g;

        print "Writing output file '" . $outfile . "'\n";
        open( OF, ">$outfile" ) || die( "Unable to open output file '$f': " . $! );
        binmode(OF);

        seek( IF, $poff, 0 ) || die;
        read( IF, $buf, $plen );
        print OF $buf;
        close(OF);
    }

    print "\n";

}

