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
#use Geo::Distance::Google;
use Excel::Writer::XLSX;
binmode(STDOUT,':utf8');
use utf8;
use open qw(:utf8 :std);

  my $dbh = DBI->connect('DBI:mysql:makom', 'vizor', 'MBfhSg^4h5b%g3K'
                   ) || die "Could not connect to database: $DBI::errstr";
$dbh->{mysql_enable_utf8} = 1;
$dbh->do("SET NAMES 'utf8'");
#--------- ---------------- ------------------------------
        my $sql = $dbh->prepare('select id, routes, name_directions from passport where id=1');
        $sql->execute or die $dbh->errstr;
        my @passport = $sql->fetchrow_array;
        $sql->finish;

	$sql = $dbh->prepare('select id, police, organizer, number, route_type, regime, date, month_name from title where id=1');
        $sql->execute or die $dbh->errstr;
        my @title = $sql->fetchrow_array;
        $sql->finish;

	
	#	print "title1 = $title[1]\n";
	#print "passport = $passport[1]\n";
#--------- ---------------- ------------------------------
my $workbook  = Excel::Writer::XLSX->new("Title_$passport[1].xlsx");

my $worksheet = $workbook->add_worksheet();
#$worksheet->set_margins_LR(0.2);  # Відступи = 0.2x25.4mm 
$worksheet->set_paper( 9 );    # A4
#$worksheet->set_margins_TB(0.2);
#$worksheet->set_margin_left(0.3);
#$worksheet->set_margin_right(0.2);


my %font1    = (
                font  => 'Arial',
                size  => 11,
                color => 'black',
                bold  => 0,
              );
my %font3    = (
                font  => 'Arial',
                size  => 14,
                color => 'black',
                bold  => 1,
              );
my %font10    = (
                font  => 'Arial',
                size  => 13,
                color => 'black',
                bold  => 1,
              );

my %center1   = (
                border  => 1,
                valign  => 'vcenter',
                align   => 'center',
               );
my %center2   = (
                top  => 1,
		#		bottom  => 6,
		#                left    => 1,
                valign  => 'vcenter',
                align   => 'center',
               );
my %center3   = (
		border  => 0,
		#                valign  => 'vcenter',
	        align   => 'center',
              );
my %center4   = (
	        right  => 1,
		#	left    => 1,
 		valign  => 'vcenter',
                align   => 'center',
               );

my %center5  = (
                bottom  => 1,                
                valign  => 'vcenter',
                align   => 'center',
               );


my $format = $workbook->add_format(
    size => 7,    # Розмір шрифту
    font => 'Arial',   # Шрифт
    top => 1,          # Лінія зверху
    text_wrap => 1,    # Перенесення тексту
    align   => 'center',
    valign => 'top'    # Вертикальне вирівнювання
);

my $format1 = $workbook->add_format(%font1, %center3);       # Arial' 11  bold  => 1, border=1
my $format2 = $workbook->add_format(%center2); 
my $format3 = $workbook->add_format(%font3, %center3);	
my $format4 = $workbook->add_format(%center4);
my $format5 = $workbook->add_format(%center5);
my $format10 = $workbook->add_format(%font10, %center3);

$format1->set_text_wrap();   # авто перені стрічки в клітиночці 
my $format6 = $workbook->add_format();
$format6->set_underline(1);
#$format->set_top(0.75);
$worksheet->set_row('0', 2);    # Ширина колонки 3
$worksheet->set_row('1', 2);    # Ширина колонки 3

$worksheet->set_column('M:M', 3);    # Ширина колонки 3
$worksheet->set_column('A:A', 2);    # Ширина колонки 3
$worksheet->set_column('B:B', 2);    # Ширина колонки 
#$worksheet->set_column('C:C', 5);    # Ширина колонки
$worksheet->set_column('C:C', 4);    # Ширина колонки
$worksheet->set_column('L:L', 4);    # Ширина колонки

$worksheet->write('L2', '', $format5);
$worksheet->merge_range('C3:K3', '', $format2);
$worksheet->merge_range('L3:L51', '', $format4);
$worksheet->merge_range('B3:B51', '', $format4);
$worksheet->merge_range('C52:L52', '', $format2);

$worksheet->merge_range('D5:G6', 'ПОГОДЖЕНО', $format3);
$worksheet->merge_range('H5:K6', 'ЗАТВЕРДЖЕНО', $format3);

#$worksheet->write('A1', 'Hello World');
#$worksheet->set_row(0, undef, $format6);
#$worksheet->set_column('A:A', undef, $format6);

$worksheet->merge_range('D7:G10', $title[1], $format1);
$worksheet->merge_range('D11:G11', '(посада керівнка П.І.Б.)', $format);

$worksheet->merge_range('H7:K10', $title[2], $format1);
$worksheet->merge_range('H11:K11', '(посада керівнка П.І.Б.)', $format);

$worksheet->merge_range('F13:G13', '(підпис)', $format);
$worksheet->merge_range('J13:K13', '(підпис)', $format);

$worksheet->merge_range('D13:E13', 'М.П.', $format3);
$worksheet->merge_range('H13:I13', 'М.П.', $format3);


$worksheet->merge_range('D14:G14', '"___"______________202_року', $format1);
$worksheet->merge_range('H14:K14', '"___"______________202_року', $format1);

$worksheet->merge_range('E22:J22', "ПАСПОРТ № $title[3]", $format3);

$worksheet->merge_range('D24:K24', "АВТОБУСНОГО МАРШРУТУ РЕГУЛЯРНИХ ПЕРЕВЕЗЕНЬ", $format10);
	my $select_type = ();
		if ( $title[4] == 1) {
			$select_type = 'міського';
		} elsif 
			( $title[4] == 2) {
			$select_type = 'приміського';
		} else {
	 		$select_type = 'міжміського';
 		}

$worksheet->merge_range('F25:I25', "$select_type", $format1);
$worksheet->merge_range('D26:K26', '(міського, приміського, міжміського)', $format);


        my $select_regime = ();
                if ( $title[5] == 1) {
                        $select_regime = 'у звичайному режимі';
$worksheet->merge_range('F28:K28', "$select_regime", $format1);
		} elsif
                        ( $title[5] == 2) {
                        $select_regime = 'експресному режимі';
$worksheet->merge_range('D30:K30', "$select_regime", $format1);
		} else {
                        $select_regime = 'режимі маршрутного таксі';
$worksheet->merge_range('D30:K30', "$select_regime", $format1);
                }
$worksheet->merge_range('D28:E28', "який працює", $format1);
$worksheet->merge_range('F29:K29', '(у звичайнрму режимі', $format);
$worksheet->merge_range('D31:K31', 'експресному режимі чи режимі маршрутного таксі)', $format);

#print "passport = $passport[2]\n";


$worksheet->merge_range('D32:F32', "Назва маршруту", $format1);
$worksheet->merge_range('G32:K32', "№ $passport[1], $passport[2]", $format1);
$worksheet->merge_range('G33:K33', '(найменування автостанцій, кінцевих зупинок)', $format);

$worksheet->merge_range('D39:F39', "Паспорт розробленй", $format1);

my $t = $title[6];
my $year = substr($t, 0, 4);
#my $month => substr($t, 5, 2);
my $day = substr($t, 8, 2);

$worksheet->merge_range('D41:F41', "$day .$title[7]. $year року", $format1);
$workbook->close();


