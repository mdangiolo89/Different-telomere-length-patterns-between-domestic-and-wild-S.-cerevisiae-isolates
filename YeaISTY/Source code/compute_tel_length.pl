use strict;
my $sumno="cat $ARGV[0].NOTYITS | awk \'BEGIN{N=0}{n+=\$2}END{print n}\'";
my $sumyes="cat $ARGV[0].YITS | awk \'BEGIN{N=0}{n+=\$2}END{print n}\'";

my $sumrs="cat $ARGV[0] | awk \'BEGIN{N=0}{n+=\$2}END{print n}\'";

my $iso=$ARGV[0];
$iso=~s/.fasta.readscan/_Run1/;

my $covgc="cat $iso.gc5080coverage.txt | awk \'
 {print \$3}\'|sort -n |awk \'BEGIN {c = 0;sum = 0;}
  \$1 ~ \/^[0-9]*(\\.[0-9]*)?\$\/ {
    a[c++] = \$1;
    sum += \$1;
  }
  END {
    ave = sum \/ c;
    if( (c % 2) == 1 ) {
      median = a[ int(c\/2) ];
    } else {
      median = ( a[c\/2] + a[c\/2-1] ) \/ 2;
    }
    OFS=\"\t\";
    print median;
  }
\'";

my $covstd="cat $iso.stdcoverage.txt | awk \'
 {print \$3}\'|sort -n |awk \'BEGIN {c = 0;sum = 0;}
  \$1 ~ \/^[0-9]*(\\.[0-9]*)?\$\/ {
    a[c++] = \$1;
    sum += \$1;
  }
  END {
    ave = sum \/ c;
    if( (c % 2) == 1 ) {
      median = a[ int(c\/2) ];
    } else {
      median = ( a[c\/2] + a[c\/2-1] ) \/ 2;
    }
    OFS=\"\t\";
    print median;
  }
\'";

my $covy="cat $iso.ycoverage.txt | awk \'
 {print \$3}\'|sort -n |awk \'BEGIN {c = 0;sum = 0;}
  \$1 ~ \/^[0-9]*(\\.[0-9]*)?\$\/ {
    a[c++] = \$1;
    sum += \$1;
  }
  END {
    ave = sum \/ c;
    if( (c % 2) == 1 ) {
      median = a[ int(c\/2) ];
    } else {
      median = ( a[c\/2] + a[c\/2-1] ) \/ 2;
    }
    OFS=\"\t\";
    print median;
  }
\'";
# print sum, c, ave, median, a[0], a[c-1];
#


my @covyx=qx( $covy);
my @covstd=qx($covstd);
my @covgc=qx($covgc);
chomp $covyx[0];
chomp $covstd[0];
chomp $covgc[0];
my $covY=$covyx[0];
my $covSTD=$covstd[0];
my $covGC=$covgc[0];


my @sumnox=qx($sumno);
my @sumyesx=qx($sumyes);
my @sumrsx=qx($sumrs);
chomp $sumnox[0];
chomp $sumyesx[0];
chomp $sumrsx[0];
my $readscan=$sumrsx[0];
my $NOTYITS=$sumnox[0];
my $YITS=$sumyesx[0];
my $YITS=$YITS*2;
#print "ISOLATE:$ARGV[0]\tcoverage_standard:$covSTD\tcoverage_GC_50_80:$covGC\n";

my $cne_Y=sprintf("%.2f",($covY/$covSTD));
my $YITS_EL=sprintf("%.0f",($YITS/$covSTD));
my $YITS_EL_GCcorrected=sprintf("%.0f",($YITS/$covGC));

my $NOTYITS_EL=sprintf("%.0f",($NOTYITS/$covSTD));
my $NOTYITS_EL_GCcorrected=sprintf("%.0f",($NOTYITS/$covGC));

my $PUT_TEL_EL=sprintf("%.0f", (($readscan-$NOTYITS-$YITS)/$covSTD));
my $PUT_TEL_EL_GCcorrected=sprintf("%.0f",((($readscan-$NOTYITS-$YITS)/$covGC))/32);


print "Isolate:$ARGV[0]\tCoverage:$covGC\tY_copy_number:$cne_Y\tITS_content:$YITS_EL_GCcorrected\tTelomere_length:$PUT_TEL_EL_GCcorrected\n";
