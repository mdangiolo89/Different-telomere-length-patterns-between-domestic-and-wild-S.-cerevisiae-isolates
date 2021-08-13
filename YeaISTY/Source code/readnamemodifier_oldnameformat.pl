use strict;
open T, "$ARGV[0]";
while (<T>) {
    chomp $_;
if ($_ =~ m/^>/) {
my @line=split(/\s+/, $_);
#print "$line[1]\n";
my ($readpair) = $line[1] =~ m/.*\/([12])$/;
#print "$readpair\n";
my $newreadname = join('/', $line[0], $readpair);
print "$newreadname\n";
}
else {print "$_\n";}
}
close T;
