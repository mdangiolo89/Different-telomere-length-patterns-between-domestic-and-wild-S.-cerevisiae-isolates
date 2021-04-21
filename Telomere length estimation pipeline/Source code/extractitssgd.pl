use strict;

open(my $in, "<", "$ARGV[0]") or die "can't open file";
open(my $yits, ">", "$ARGV[0].YITS") or die "can't open file";
open(my $notyits, ">", "$ARGV[0].NOTYITS") or die "can't open file";


while (<$in>) {
		chomp $_;
		my @row3=split(/\t/, $_);
		my ($readnumber) = $row3[0] =~ m/\/([12])$/;
		#print "$readnumber\n";
		$row3[0] =~ s/\/[12]$//;
		#if ($row3[2] eq 'C{1,3}A') {next;}
		if ($row3[2] eq 'TG{1,3}' && $readnumber == 1) {
		open(my $secondreadinpair, "<", "$ARGV[1]") or die "can't open file";
		while (<$secondreadinpair>) {
                	chomp $_;
			my @row2=split(/\s+/, $_);
			#print "$row3[0]\t$row2[0]\n";
			if ("$row3[0]" eq "$row2[0]") {print $yits "$row3[0]/$readnumber\t$row3[1]\t$row3[2]\t$row3[3]\n";last;}
		}		
		}
		
		if ($row3[2] eq 'TG{1,3}' && $readnumber == 2) {
                open(my $firstreadinpair, "<", "$ARGV[2]") or die "can't open file";
                while (<$firstreadinpair>) {
                        chomp $_;
                        my @row2=split(/\s+/, $_);
                        #print "$row3[0]\t$row2[0]\n";
                        if ("$row3[0]" eq "$row2[0]") {print $yits "$row3[0]/$readnumber\t$row3[1]\t$row3[2]\t$row3[3]\n";last;}
                }
                }

		open(my $bothreadsmappedoutsidey, "<", "$ARGV[3]") or die "can't open file";
                while (<$bothreadsmappedoutsidey>) {
                        chomp $_;
                        my @row2=split(/\s+/, $_);
                        #print "$row3[0]\t$row2[0]\n";
                        if ("$row3[0]" eq "$row2[0]") {print $notyits "$row3[0]/$readnumber\t$row3[1]\t$row3[2]\t$row3[3]\n";last;}
                }

}
