#!/usr/bin/perl
#
# tool to show how the values in aotom_vfd.c:CharLib will actually
# look on the display
#
# (C) 2012 Stefan Seyfried
# License: WTFPL v2
#
# usage: sparkvfd.pl 0xf1 0x38
#
# //  aaaaa
# // fh j kb
# // f hjk b
# //  ggimm
# // e rpn c
# // er p nc
# //  ddddd
#
#                  7 6 5 4 3 2 1 0
# /*address 0 8bit g i m c r p n e */
# /*address 1 7bit   d a b f k j h */

$a0 = hex shift;
$a1 = hex shift;

# print "a0: $a0 a1: $a1\n";

for ($i = 0; $i < 7; $i++)
{
	$out[$i] = "       ";
}


if (($a0 & 1<<0)) {
	substr($out[4],0,1) = "|";
	substr($out[5],0,1) = "|";
}
if (($a0 & 1<<1)) {
	substr($out[4],4,1) = "\\";
	substr($out[5],5,1) = "\\";
}
if (($a0 & 1<<2)) {
	substr($out[4],3,1) = "|";
	substr($out[5],3,1) = "|";
}
if (($a0 & 1<<3)) {
	substr($out[4],2,1) = "/";
	substr($out[5],1,1) = "/";
}
if (($a0 & 1<<4)) {
	substr($out[4],6,1) = "|";
	substr($out[5],6,1) = "|";
}
if (($a0 & 1<<5)) {
	substr($out[3],4,2) = "--";
}
if (($a0 & 1<<6)) {
	substr($out[3],3,1) = "+";
}
if (($a0 & 1<<7)) {
	substr($out[3],1,2) = "--";
}
if (($a1 & 1<<0)) {
	substr($out[1],1,1) = "\\";
	substr($out[2],2,1) = "\\";
}
if (($a1 & 1<<1)) {
	substr($out[1],3,1) = "|";
	substr($out[2],3,1) = "|";
}
if (($a1 & 1<<2)) {
	substr($out[1],5,1) = "/";
	substr($out[2],4,1) = "/";
}
if (($a1 & 1<<3)) {
	substr($out[1],0,1) = "|";
	substr($out[2],0,1) = "|";
}
if (($a1 & 1<<4)) {
	substr($out[1],6,1) = "|";
	substr($out[2],6,1) = "|";
}
if (($a1 & 1<<5)) {
	$out[0] = " ----- ";
}
if (($a1 & 1<<6)) {
	$out[6] = " ----- ";
}

for ($i = 0; $i < 7; $i++)
{
	print $out[$i] . "\n";
}


