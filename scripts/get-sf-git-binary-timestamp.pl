#!/usr/bin/perl
#
# get the timestamp of a binary from the sourceforge web
# frontend, to avoid cloning the huge repo just for one file
#
$repo = shift;
$path = shift;
$url = "http://azboxopenpli.git.sourceforge.net/git/gitweb.cgi?p=$repo;f=$path";

$hurl = $url . ";a=history";
# print "hurl: '$hurl'\n";
@w3m = `w3m -dump -cols 100 \"$hurl\"`;
chomp @w3m;
$ret = 1;
foreach $line (@w3m)
{
	if ($line =~ /commitdiff$/)
	{
		$date = substr($line, 0, 11);
		# print "'$date'\n";
		$timestamp = `date +%Y%m%d -d \"$date\"`;
		chomp $timestamp;
		$ret = 0;
		last;
	}
}
# print "ts: '$timestamp'\n";
print "$timestamp\n";
exit $ret;
