#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

my ($input, $motif, $prefix);

GetOptions('input|i:s' => \$input,
	   'motif|m:s' => \$motif,
	   'prefix|p:s' => \$prefix);


my $input_fh = read_file($input);
my %input = parse_fasta_file($input_fh);

my $motif_fh = read_file($motif);
my %motif = parse_list_file($motif_fh); 

my $detailCA = "$prefix.detail.CA.out";
my $detailCA_fh = write_file($detailCA);
my $detailTG = "$prefix.detail.TG.out";
my $detailTG_fh = write_file($detailTG);
my $summary = "$prefix.summary.out";
my $summary_fh = write_file($summary);

my %match;

foreach my $m (sort keys %motif) {
    print "m=$m\n";
    my $i = 0;
    foreach my $s (sort keys %input) {
	$input{$s} = uc $input{$s};
	my $total_match_length = 0;
	while ($input{$s} =~ /$m/g) {
	    $i++;
	    $match{$m}{$i}{'case'} = $&; 
	    # my $start = pos($input{$s}) + 1;
	    # my $end = $start + (length $match{$m}{$i}{'case'}) - 1;
	    # $match{$m}{$i}{'position'} = "$s:$start-$end";
	    my $start = $-[0] + 1;
	    my $end = $+[0];
	    $match{$m}{$i}{'position'} = "$s:$start-$end";
	    $match{$m}{$i}{'length'} = $end - $start + 1;
	}
    }
}

my %stat;
#print $detailCA_fh "motif\tmatch_id\tref\tmatch_start\tmatch_end\tmatch_case\n";
#print $detailTG_fh "motif\tmatch_id\tref\tmatch_start\tmatch_end\tmatch_case\n";
foreach my $m (sort keys %motif) {
    foreach my $i (sort {$a<=>$b} keys %{$match{$m}}) {
	my ($s, $start, $end) = ($match{$m}{$i}{'position'} =~ /(\S+):(\d+)-(\d+)/);
	if ($m eq 'C{1,3}A') {print $detailCA_fh "$s\t$start\t$end\t$match{$m}{$i}{'case'}\n";}
        if ($m eq 'TG{1,3}')  {print $detailTG_fh "$s\t$start\t$end\t$match{$m}{$i}{'case'}\n";}
	if (exists $stat{$m}{$s}) {
	    $stat{$m}{$s}{'count'}++;
	    $stat{$m}{$s}{'length'} += ($end - $start +1);

	} else {
	    $stat{$m}{$s}{'count'} = 1;
	    $stat{$m}{$s}{'length'} = $end - $start +1;
	}
    }
}

print $summary_fh "motif\tref\tref_length\tmotif_count\tmatch_length\tmatch_cov\n";
foreach my $m (sort keys %motif) {
    foreach my $s (sort keys %input) {
	if (exists $stat{$m}{$s}) {
	    my $N_count = $input{$s} =~ tr/N/N/;
	    my $length = (length $input{$s}) - $N_count;
	    $stat{$m}{$s}{'cov'} = $stat{$m}{$s}{'length'}/$length;
	    print $summary_fh "$m\t$s\t$length\t$stat{$m}{$s}{'count'}\t$stat{$m}{$s}{'length'}\t$stat{$m}{$s}{'cov'}\n";
	}
    }
}






sub read_file {
    my $filename = shift @_;
    my $fh;
    open ($fh, $filename) or die "cannot open the file $filename\n";
    return $fh;
}


sub write_file {
    my $filename = shift @_;
    my $fh;
    open ($fh, ">$filename") or die "cannot open the file $filename\n";
    return $fh;
}


sub parse_fasta_file {
    my $fh = shift @_;
    my %seq;
    my $seq_name = "";
    my $flag = 0;
    while (<$fh>) {
        chomp;
        if (/^\s*$/) {
            next;
        } elsif (/^\s*#/) {
	    next;
	} elsif (/^>(\S+)/) {
	    $seq_name = $1;
	    $seq{$seq_name} = "";
	} else {
	    $seq{$seq_name} .= $_;
	}
    }
    return %seq;
}


sub parse_list_file {
    my $fh = shift @_;
    my %list = ();
    while (<$fh>) {
	chomp;
        if (/^\s*$/) {
            next;
	} elsif (/^#/) {
            next;
	} else {
	    my $line = $_;
	    if (exists $list{$line}) {
		$list{$line}++;
	    } else {
		$list{$line} = 1;
	    }
	}
    }
    return %list;
}


sub revcom {
    my $seq = shift @_;
    my $seq_revcom = reverse $seq;
    $seq_revcom =~ tr/ATGCNatgcn/TACGNtacgn/;
    return $seq_revcom;
}
