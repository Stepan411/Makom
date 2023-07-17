#/usr/bin/env perl
use strict;
use CGI;
use JSON;

my $q = new CGI;
my $json = new JSON;

if ($q->param)
{
  print $q->header();
    my $hash = $json->decode($q->param('POSTDATA'));
      # NEXT LINE REMOVED, IT WAS WRONG!!
        #print $q->header('application/json');
          my $msg = [ sprintf "data from %s received ok", $hash->{name} ];
            print $json->encode($msg);
            }
