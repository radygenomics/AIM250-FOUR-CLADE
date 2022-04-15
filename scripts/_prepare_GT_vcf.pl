#!/usr/bin/perl -w 

# For this tool we need to prepare a VCF with GT, including 0|0 calls (hom ref)
# Because of the quality of our seq workflow and the fact that all markers are in exons, 
# we can be sure that if the position is NOT in the input vcf, it is hom ref and can be filled in from 
# template file
# All rows should be simply:
# 10      696237  rs10904535      G       A       100     PASS    .       GT      1|1 
#
# The AIM-250 position and allele file is in a fixed position:
# /path/to/AIM-FOUR-CLADE/Essential_files//AIM_250_grch37.pos.ref.alt
#
# (c) RCIGM, S.Batalov, 2020

my $f = shift or die "Need a VCF\n";
open IN, "gzip -dcfq $f|" or die "Need a VCF\n";
$f =~ s/\.vcf.*/.GT.vcf.gz/;
open OU, "|bgzip > $f" or die "Cannot write to $f\n";

open TM, "</path/to/AIM-FOUR-CLADE/Essential_files//AIM_250_grch37.pos.ref.alt";
my @t0 = (10,696237,"rs10904535","G","A","100","PASS",".","GT","0|0");
while(<TM>) {
  s/\s+$//;
  my @t = split("\t");
  @t[@t..9] = @t0[@t..9];
  $VAR{$t[0].",".$t[1]} = \@t;
  push @List, $t[0].",".$t[1]; # they are sorted; can output in the same order
}
close TM;

while(<IN>) {
  if(/^#/) { s/_dragen//; print OU $_ unless /ID=GL00|DRAGENCommandLine/; next; }
  @t = split("\t");
  next unless ($v=$VAR{$t[0].",".$t[1]}) && $v->[3] eq $t[3] && $v->[4] eq $t[4];
  $v->[9] = substr($t[9],0,3);
  $v->[6] = $t[6];
}
close IN;
foreach (@List) {
  print OU join("\t",@{$VAR{$_}}), "\n";
}
close OU;
`tabix -p vcf $f`;
