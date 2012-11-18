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
@html = `curl \"$hurl\"`;
chomp @html;
$content = join(" ", @html);
if ($content =~ /.*<td title=".*?(\d\d\d\d)-(\d\d)-(\d\d).*?>commitdiff<\/a><\/td>/)
{
	print "$1$2$3\n";
	exit 0;
}
exit 1;
