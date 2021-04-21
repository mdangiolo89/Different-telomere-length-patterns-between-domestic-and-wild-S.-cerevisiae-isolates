#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

## usage: perl find_motif_in_reads.pl -i $sample.fasta -m motif.txt -o $sample.fasta.readscan -l $sample.fasta.readlist -c 40


my ($input, $motif, $output, $list, $cutoff, $tag);

GetOptions('input|i:s' => \$input,
	   'motif|m:s' => \$motif,
	   'output|o:s' => \$output,
	   'list|l:s' => \$list,
	   'tag|t:s' => \$tag,
	   'cutoff|c:s' => \$cutoff);

my $start_total_match_length;
my $end_total_match_length;
my $lastend = 0;
my $lasti;

my $input_fh = read_file($input);
my %input = parse_fasta_file($input_fh);

my $motif_fh = read_file($motif);
my %motif = parse_list_file($motif_fh); 

my $output_fh = write_file($output);
my $list_fh = write_file($list);

foreach my $m (sort keys %motif) {
    print "m=$m\n";
    foreach my $s (sort keys %input) {
	my ($readname) = $s =~ m/(.*)\/[12]$/;
	my %match;
	my $i = 0;
	my $j = 0;
	my $k = 0;
	my %numberofmotifstretches;
	while ($input{$s} =~ /$m/g) {
	    $i++;
	    $match{$i}{'case'} = $&; 
	    my $start = $-[0] + 1;
	    my $end = $+[0];
	    $match{$i}{'position'} = "$s:$start-$end";
	    $match{$i}{'length'} = $end - $start + 1;
	if ($i == 1) {$numberofmotifstretches{$j}{'total_match_length'} = $match{$i}{'length'};$numberofmotifstretches{$j}{'end_total_match_length'} = $end};
	if ($start-$lastend==1 && $i>1) {$numberofmotifstretches{$j}{'total_match_length'} += $match{$i}{'length'}; $numberofmotifstretches{$j}{'end_total_match_length'} = $end;}
	if ($start-$lastend>1 && $start-$lastend<4 && $i>1) {$k++; 
		if ($k == 1) {$numberofmotifstretches{$j}{'total_match_length'} += $match{$i}{'length'}; $numberofmotifstretches{$j}{'end_total_match_length'} = $end;}
		else {$j++;$numberofmotifstretches{$j}{'total_match_length'} = $match{$i}{'length'};$numberofmotifstretches{$j}{'end_total_match_length'} = $end}
	}
	if ($start-$lastend>3 && $i>1) {$j++;$numberofmotifstretches{$j}{'total_match_length'} = $match{$i}{'length'};$numberofmotifstretches{$j}{'end_total_match_length'} = $end}
	#print "$numberofmotifstretches{$j}{'end_total_match_length'}\n";
	$lastend=$end;
	$lasti=$i
	}

foreach my $stretch (sort {$a <=> $b} keys %numberofmotifstretches) {$numberofmotifstretches{$stretch}{'start_total_match_length'}=$numberofmotifstretches{$stretch}{'end_total_match_length'}-$numberofmotifstretches{$stretch}{'total_match_length'}+1;
	if ($numberofmotifstretches{$stretch}{'total_match_length'}>=$cutoff) {print $output_fh "$s\t$numberofmotifstretches{$stretch}{'total_match_length'}\t$m\t$input{$s}\t$numberofmotifstretches{$stretch}{'start_total_match_length'}\t$numberofmotifstretches{$stretch}{'end_total_match_length'}\n";
	print $list_fh "$readname\n";
	last;
	}
}
}
print "motif=$m strain=$input status=completed\n";
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
