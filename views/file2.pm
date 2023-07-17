#!/usr/bin/env perl

use POSIX qw(strftime);
use strict;
use warnings;
use Exporter;
use Switch;
use Data::Dumper;
use FindBin;
use DBI;
use feature qw(fc say);
use Excel::Writer::XLSX;
binmode(STDOUT,':utf8');
use utf8;
use open qw(:utf8 :std);
use CGI qw(param);

our @routes=(); 
our @graphs=();
my $rout_writhe = 30;
our @media=();
my $str = 0;
our $id_menu = 'id_menu';
our ($i, $j, $x, $y, @na, $elem, $fi1);

use Excel::Writer::XLSX;

my $workbook  = Excel::Writer::XLSX->new( 'exa_2.xlsx' );
my $worksheet = $workbook->add_worksheet();
my $worksheet2 = $workbook->add_worksheet();
my $worksheet3 = $workbook->add_worksheet();
# Встановлення портретної орієнтації для другого листа
$worksheet->set_landscape();  # За замовчуванням орієнтація - landscape
$worksheet2->set_portrait();
$worksheet3->set_landscape();
$workbook->close();


