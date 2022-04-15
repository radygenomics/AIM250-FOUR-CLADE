#!/usr/bin/perl -w
#
# Here, we reformat STRUCTURE output for the R script
# Lines like this one
#   512  HG01947    (0)    4 :  0.359 | Pop 1: 0.000 0.000 0.000  | Pop 2: 0.000 0.000 0.641  | Pop 3: 0.000 0.000 0.000  |
# into this:
#   512  HG01947    (0)    4 :  0.000 0.641 0.000 0.359 

my $f = shift;

`mv $f $f.c4`;
open IN, "<$f.c4";
open OU, ">$f";
my $section=0;
while(<IN>) {
  if(!$section) {
    if(/^        Label \(\%Miss\) Pop/) {
      $section = 1;
      s/ Pop.*/ Pop:  Inferred clusters/;
    }
    print OU $_;
    next;
  }
  if(/\| Pop/) {
    /^([^:]* :)/; # keep the first section up to ':' as is
    my @T = ($1,'','','','');
    tr/:/ /; # get rid of :
    my @t = split;
    $T[$t[3]] = $t[4];
    for($k=7;$k<@t;$k+=6) {
      $T[$t[$k]] = $t[$k+3]; # e.g. T[2] will get value 0.641 
    }
    print OU join(" ",@T), "\n";
  } else {
    print OU $_; # without changes
  }
}
close OU;
close IN;
