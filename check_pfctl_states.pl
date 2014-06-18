#!/usr/local/bin/perl -w
################### check_pfctl_states.pl ###################
# Version : 1.0
# Date : 18 Jun 2014
# Author  : David Durieux (d.durieux at siprossii.com)
# Licence : GPL - http://www.fsf.org/licenses/gpl.txt
#############################################################
#

use strict;
use warnings;
use Getopt::Std;

# Predefined exit codes for Nagios
my %exit_codes   = ('UNKNOWN' ,-1,
                    'OK'      , 0,
                    'WARNING' , 1,
                    'CRITICAL', 2,);

my $warn_level = 75; # in percentage
my $crit_level = 90; # in percentage



my $current = -1;
my $limit = -1;

my $pfctl = `pfctl -q -s info`;
my @split = split /\n/, $pfctl;
foreach my $line (@split) {
   if ($line =~ /current entries/) {
      $line =~ s/current entries//;
      $line =~ s/^\s*(.*?)\s*$/$1/;
      $current = $line;
   }
}

$pfctl = `pfctl -q -s memory`;
@split = split /\n/, $pfctl;
foreach my $line (@split) {
   if ($line =~ /states/) {
      $line =~ s/states//;
      $line =~ s/hard limit//;
      $line =~ s/^\s*(.*?)\s*$/$1/;
      $limit = $line;
   }
}

if ($current == -1 || $limit == -1) {
   print "PF states UNKNOWN - no data found |states=0;0;0;0;0 percent=0;0;0;0;0\n";
   exit $exit_codes{'UNKNOWN'};
} else {
   my $percentage_current = int(($current * 100) / $limit);
   my $warn_val = int(($warn_level * $limit) / 100);
   my $crit_val = int(($crit_level * $limit) / 100);
   if ($percentage_current >= $crit_level ) {
      print "PF states CRITICAL - $current ($percentage_current%) |states=$current;$warn_val;$crit_val;0;$limit
      exit $exit_codes{'CRITICAL'};
   } elsif ($percentage_current >= $warn_level) {
      print "PF states WARNING - $current ($percentage_current%) |states=$current;$warn_val;$crit_val;0;$limit p
      exit $exit_codes{'WARNING'};
   } else {
      print "PF states OK - $current ($percentage_current%) |states=$current;$warn_val;$crit_val;0;$limit percen
      exit $exit_codes{'OK'};
   }
}
