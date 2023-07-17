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
use GIS::Distance; 
use Time::Piece;
#use Geo::Distance::Google;
use Excel::Writer::XLSX;
binmode(STDOUT,':utf8');
use utf8;
use open qw(:utf8 :std);

my @table = ();		# 2 мірний масив часу та зупинокграфіка
my @row_ref =();	# 2 мірний масив для перетворення часу в масиві графіка

our @workshift=(); 	# 2 мірний масив робочого часу
my @routes=();          # 2 мірний масив id маршруту
my @schedules=();	# 2 мірний масив id графіка
my @directions=();	# 2 мірний масив напрямку - назви маршрута
my @graphs=();		# 2 мірний масив назви графіка (1...9..)
my $sec =0;
my $min=0;
my $hour=0;
my $flig_max=0;
my $arr_max = 0;		# max елемент масиву по j $table
my $tape=38;              	# к-сть стрічок на листі А4
#my $id_shedules = 323;		# id графіка
my $rout_writhe = 30;		# маршрут вводити ( допустимо 30 )
my $graph_writhe=1;		# графык вводити 
my $reverse_stop = 0;		# PZZ - id таблиці passport_stops_routes $pas_stop[$f][2]  Перша Зворотня Зуинка
our $time_prep_concl=();	# підготовчо заключний час водія в хв.
my ($i, $j);
our $schedules_max = ();		# max значення id графыка - це останнє активоване id
our $w=0;			# глобальна змінна для workshift
our $d=0;			# глобальна змінна для dinners
my $gis = GIS::Distance->new();
my $nomer_finish = ();		# Довжина маршруту
my $flight_duration_dir = ();	# тривалість рейсу пряма
my $flight_duration_rev = ();	# тривалість рейсу зворотня
my $time_dir = 0;		#  час початку рейсу прямого 
my $time_rev = 0;         #  час початку зворотнього рейсу зворотнього
my @mas=();
my @passport_data=();
my $passport_data=();
my $pas_routes=();
my @pas_graf=();		        # службовий масив для розбиття координат на 3 числа для перетворення в Гугловську систему координат 
my $lat=(); my $lon = (); my $distance = 0; my $distance_summ = 0; my $dist_s = 0;	# для вирахування координат та підрахунку дистанції

  my $dbh = DBI->connect('DBI:mysql:makom', 'vizor', 'MBfhSg^4h5b%g3K'
                   ) || die "Could not connect to database: $DBI::errstr";
$dbh->{mysql_enable_utf8} = 1;
$dbh->do("SET NAMES 'utf8'");
#--------- -------------- Маршрут і Графік name ------------------------------
my $sth = $dbh->prepare("SELECT id, routes, routes_id, graphs, graphs_id, val_select_direct, val_select_twisted, preliminary_final_time, IFNULL(radio_pzz, 0) AS radio_pzz
FROM passport WHERE id = 1");
        $sth->execute();
        $passport_data = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$passport_data} ) {
	for $j ( 0 .. $#{$passport_data[$i]} )  {
}
#print "Маршрут=$passport_data->[0][0], $passport_data->[0][1], $passport_data->[0][2], $passport_data->[0][3], $passport_data->[0][4]\n"
}

#print "passport_data[0][8]$passport_data->[0][8], $passport_data->[0][1]\n";
$time_prep_concl = $passport_data->[0][7];
my $time_prep_concl_constanta = $time_prep_concl;
#--------- -------------- Маршрут id ------------------------------
 $sth = $dbh->prepare("SELECT id, transport_types_id, name
FROM routes WHERE name = $passport_data->[0][1]");
        $sth->execute();
        my $routes = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$routes} ) {
        for $j ( 0 .. $#{$routes->[$i]} )  {
#print "routes=$routes->[$i][$j]\t";
}
#print "\n";
#print "Маршрут=$routes->[0][2] \n";
}
#--------- -------------- Назва маршруту ------------------------------
$sth = $dbh->prepare("SELECT name, id
FROM route_directions WHERE routes_id = $routes->[0][0]");
        $sth->execute();
        my $directions = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$directions} ) {
        for $j ( 0 .. $#{$directions->[$i]} )  {
#print "directions=$directions->[$i][$j]\t";
}
#print "$directions->[$i][0]\n";
        $sth = $dbh->prepare("UPDATE passport SET directions_id = $directions->[0][1]  WHERE id = 1");   #запис назви маршруту
        $sth->execute();
}
#--------- -------------- Назви (Номера) графіків ------------------------------
	if ($passport_data->[0][3] eq 'All') {
$sth = $dbh->prepare("SELECT id, name
FROM graphs WHERE routes_id = $routes->[0][0]"); # AND (name = $graph_writhe)");
} else {
$sth = $dbh->prepare("SELECT id, name
FROM graphs WHERE (routes_id = $routes->[0][0]) AND (name = $passport_data->[0][3])");
}
        $sth->execute();
        my $graphs = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$graphs} ) {
        for $j ( 0 .. $#{$graphs->[$i]} )  {
}
#print "Графік=$graphs->[$i][1], graphs->[$i][0]=$graphs->[$i][0] \n";
}
#--------- -------------- Графіки (ID графіка) ------------------------------
my $workbook  = Excel::Writer::XLSX->new("Route_$routes->[0][2].xlsx");
#print "Маршрут_ss=$routes->[0][2], passport_data->[0][3]=$passport_data->[0][3] \n";

my $worksheet = $workbook->add_worksheet();

        our $graf_sum=0;		# Цикл вибору графіків
for $graf_sum ( 0 .. $#{$graphs} ) {
my $distance = 0; my $distance_summ = 0; my $dist_s = 0;  # обнулення гео данних 

$sth = $dbh->prepare("SELECT id, histories_id
FROM schedules WHERE (graphs_id = $graphs->[$graf_sum][0]) AND ($routes->[0][2])");
        $sth->execute();
        my $schedules = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$schedules} ) {
        for $j ( 0 .. $#{$schedules->[$i]} )  {
}
$schedules_max = $schedules->[$i][0];
#print "schedules->[$i][0]$schedules->[$i][0]\n";
}
#print "id_schedules_max = $schedules_max \n";
#--------- -------------- Графік руху - час в сек і ID зупинок------------------------------
$sth = $dbh->prepare("SELECT id, schedules_id, time, flights_number, stations_id, pc_number  
FROM schedule_times WHERE schedules_id = $schedules_max");
	$sth->execute();
	my $table = $sth -> fetchall_arrayref
	or die "$sth -> errstr\n";
	for $i ( 0 .. $#{$table} ) {
	for $j ( 0 .. $#{$table->[$i]} )  {
}
my $sth = $dbh->prepare("SELECT name, latitude, longitude FROM stations WHERE id = $table->[$i][4]");
  	$sth->execute();
	my $row_ref = $sth -> fetchrow_arrayref
	or die "$sth -> errstr\n";
	$table->[$i][4] = $row_ref->[0];
	($sec,$min,$hour)=gmtime($table->[$i][2]);
	$min = sprintf('%02d', $min);
	$hour = sprintf('%02d', $hour);
	$table->[$i][2] = join(":", $hour, $min);
	$flig_max  = $table->[$i][3];			# останій макс. рейс
	$table->[$i][6] = $row_ref->[1];
	$table->[$i][7] = $row_ref->[2];                       
(@mas) = split(//,$table->[$i][6], 3);		# перевід в Гугловську систему координат... розділення числа на три
        $lat = join("", $mas[0], $mas[1]);      # обеднання 
        $lat = $mas[2]/60+$lat;			# перевід
        $lat = sprintf('%06f', $lat);		# заокруглення до 6 знаків після коми
$table->[$i][6] = $lat;				# запис координати в $table->[$i][6]
        $#mas = -1;				# очищення масиву
        (@mas) = split(//,$table->[$i][7], 3);	
        $lon = join("", $mas[0], $mas[1]);
        $lon = $mas[2]/60+$lon;
        $lon = sprintf('%06f', $lon);
$table->[$i][7] = $lon;				# запис гугловської системи координат в $table->[$i][7]
	$arr_max++; 						# max елемент масиву по j $table
	#print "table->[$i][4] = $table->[$i][4],  \n";
}
#--------------------- Праця з Excel::Writer: ------------------------------------
#my $workbook  = Excel::Writer::XLSX->new('simple.xlsx');
	#die "Problems creating new Excel file: $!" unless defined $workbook;
#my $worksheet = $workbook->add_worksheet();
	$worksheet->hide_gridlines(0);
	for $worksheet ( $workbook->sheets() ) {
    	$worksheet->set_landscape();
}
	my %font2=();
	my %font1=();
	if ($flig_max >=10){				# Зменшення розміру шріфта якщо оборотних рейсів >= 10
%font2    = (
                font  => 'Arial',
		size  => 7,
		color => 'black',
                bold  => 1,
              );
%font1    = (
                font  => 'Arial',
                size  => 7,                     ##
                color => 'black',
	        bold  => 0,
	      );
	}else{  
%font2    = (
                font  => 'Arial',
                size  => 8,
                color => 'black',
                bold  => 1,
              );
%font1    = (
                font  => 'Arial',
		size  => 8, 
                color => 'black',
                bold  => 0,
              );
}
my %font0    = (
                font  => 'Arial',
                size  => 6,
                color => 'black',
                bold  => 0,
		text_wrap => 1,
              );
my %center0   = (
                border  => 0,
                valign  => 'vcenter',
                align   => 'center',
              );
my %center1   = (
		border  => 0,
                valign  => 'vcenter',
                align   => 'left',
              );
my %center2   = (
               	top	=> 6,
		bottom  => 6,
		left    => 1,
		right   => 1,
                valign  => 'vcenter',
                align   => 'centr',
              );
my %center3   = (
                valign  => 'vcenter',
                align   => 'center',
 		left    => 1,
              );
my %center4   = (
		right 	=> 1,	
                valign  => 'vcenter',
                align   => 'centr',
              );
my %center5   = (
                top     => 6,
                bottom  => 6,
                valign  => 'vcenter',
                align   => 'centr',
              );
my %center6   = (
                top     => 6,
                bottom  => 6,
                left    => 1,
                valign  => 'vcenter',
                align   => 'centr',
              );
my %center7  = (
               	top     => 6,
		bottom  => 6,
		right   => 1,
		valign  => 'vcenter',
                align   => 'center',
              );
 
my %shading = (
                bg_color => 'green',
                pattern  => 1,
              );
$worksheet->set_paper( 9 );    # A4
$worksheet->center_horizontally();
$worksheet->center_vertically();
$worksheet->set_margins_LR(0.18);  # Відступи = 0.2x25.4mm 
$worksheet->set_margins_TB(0.2); 
$worksheet->set_margin_top(0.4);
$worksheet->set_column('A:A', 2);    # Ширина колонки 3 ##3
	if ($flig_max >=10){					 # Зменшення розміру колонки, якщо оборотних рейсів >= 10
$worksheet->set_column('B:B', 13);	
$worksheet->set_column('C:C', 3);	
$worksheet->set_column('D:AZ', 3);	
	}else{
$worksheet->set_column('B:B', 16);      
$worksheet->set_column('C:C', 4);       
$worksheet->set_column('D:AZ', 4);      
}
	my $b =1;
	my $a =1;
for (my $i=3; $i <= 20; $i++){   # Цикл для виставлення ширини =3 кожної 3 колонки до3x20 = 60 рейсів
        $b = $b + 3;
        $a = $a + 3;
if ($flig_max >=10){ 
	$worksheet->set_column($a, $b, 2.08);
}else{
	$worksheet->set_column($a, $b, 3);
}
}
my $format0 = $workbook->add_format(%font0, %center0);
my $format1 = $workbook->add_format(%font1, %center0);
my $format2 = $workbook->add_format(%font2, %center0);
my $format3 = $workbook->add_format(%font1, %center3);
my $format4 = $workbook->add_format(%font1, %center1);
my $format5 = $workbook->add_format(%font0, %center5);
my $format6 = $workbook->add_format(%font0, %center6);
my $format7 = $workbook->add_format(%font0, %center7);

$worksheet->merge_range('A1:C1', "Маршруту № $routes->[0][2] Графік $graphs->[$graf_sum][1]", $format2);
$worksheet->merge_range('A2:A3',  '№  п/п', $format5);
$worksheet->merge_range('B2:B3',  'Зупинка', $format5);
$worksheet->merge_range('C2:C3',  'Від-   стань', $format7);
	$a=2;
	my $c=0;
	$i=0;
	$j=0;
	my $r=3;
	my $flign_N = 1;
	$a=1; 
                       while ($a <= $flig_max){       # 
                                $a++;
$worksheet->merge_range($c, $r, $c, $r+2, "Рейс № $flign_N", $format2);
$worksheet->merge_range($c+1, $r, $c+2, $r,  'Прибуття', $format5);
$worksheet->merge_range($c+1, $r+1, $c+2, $r+1,  'Стоянка', $format5);
$worksheet->merge_range($c+1, $r+2, $c+2, $r+2,  'Відправлення', $format7);
	$r=$r+3;
	$flign_N = $flign_N+1;
}
	my $row = 3;
	my $column_name = 1;
	my $name = ();
	my $nomer = 1;
	my $pc_num =0;
	my $flights_number = 1;
	my $x = 100;
	my $start = 0;	# точка старту друку графіка не з першої зупинки графіка, а з #row
	my $list =0;    # к-сть листів
	my $rr = 0;
	my $cc = 0;
	for $i ( 0 .. $#{$table} ) {
	$pc_num = $table->[$i][5];
	$start++;
	my $r =0;
	$c= 0;
	$flights_number = $table->[$i][3];
	if (($pc_num ==  1) && ($flights_number == 1)){		# цикл друку коли графік починаэться pc_number == 1 в БД таблиці schedule_times
	while ($flights_number == 1) {				# це коли графік починається з першої зупинки на маршруті
	$name= $table->[$i][4];
$worksheet->write($row, $column_name,  $name, $format4);
$worksheet->write($row, $column_name-1,  $nomer, $format1);
#---------------------------------- Друк дистанції ------------------------------------
        my $lat1 = $table->[$i][6]; my $lon1 = $table->[$i][7];	# змінні модуля GIS::Distance
        $i++;
if (defined($table->[$i][6]) ) {	# умова друку дистанції, якщо оприділено $table->[$i][6] то друкую в кінці масиву не оприділено
        my $lat2 = $table->[$i][6]; my $lon2 = $table->[$i][7];
        my $distance = $gis->distance( $lat1, $lon1, $lat2, $lon2 );
        $distance = $distance->meters();
        $distance_summ = $distance_summ + ($distance/1000);
        $dist_s =  sprintf('%01f', $distance_summ);
if ($table->[$i][5] >=  $nomer){  	# умова не друку останньої дистанції на кінцевій зупинці, бо зупинки ідуть на одну більші $i++
#print "distance=$distance, dist_s=$dist_s, table->[$i][4]=$table->[$i][4], table->[$i][5]=$table->[$i][5]\n";
$worksheet->write($row+1, $column_name+1, $dist_s, $format3);
#-------------------------------- Запис суми довжини маршруту прямого нарямку ------------------------ 
if (($passport_data->[0][8]-1) == $nomer) {
        $sth = $dbh->prepare("UPDATE characteristics_route SET long_route_dir = $dist_s  WHERE id = 1");   #запис назви маршруту
        $sth->execute();
	$nomer_finish = $dist_s;
}
#------------------------------------------------------------------------------------------
}
}else{
        $i=$i-1;
}
        $i=$i-1;
#---------------------------------- Завершення друку ----------------------------------
	$nomer++;
	$row++;
	$i++;
	$flights_number = $table->[$i][3];
	$x=$x-1;
	$r = $row;
	if ($row % $tape == 0) {		# друк коли ціле число кратне радкам в сторінці тоді друкуємо хедер $row % $tape == 0
$worksheet->merge_range($r, $c, $r, $c+2, "Маршруту № $routes->[0][2] Графік $graphs->[$graf_sum][1]", $format2);
$worksheet->merge_range($r+1, $c, $r+2, $c, '№  п/п', $format5);
$worksheet->merge_range($r+1, $c+1, $r+2, $c+1,  'Зупинка', $format5);
$worksheet->merge_range($r+1, $c+2, $r+2, $c+2,  'Від-   стань', $format7);
	$row = $row + 3;
	$cc = $c;
	$rr = $r;
	$c=3;
        my $flign_N = 1;
        $a=2;
                       while ($a <= $flig_max+1){       #
                                $a++;
$worksheet->merge_range($r, $c, $r, $c+2, "Рейс № $flign_N", $format2);
$worksheet->merge_range($r+1, $c, $r+2, $c,  'Прибуття', $format5);
$worksheet->merge_range($r+1, $c+1, $r+2, $c+1,  'Стоянка', $format5);
$worksheet->merge_range($r+1, $c+2, $r+2, $c+2,  'Відправлення', $format7);
        $c=$c+3;
        $flign_N = $flign_N+1;
}
	$c = $cc;
	$r = $rr;
}	# завершення друку хедера
}	# завершення циклу ($flights_number == 1)
}elsif ($flights_number == 2) {			# це коли графік починається з якоїсь іншої не першої зупинки по маршруті
	while ($flights_number == 2) {		# цикл друку коли графык починаэться pc_number != 1 в БД таблиці schedule_times 
	$name= $table->[$i][4];
$worksheet->write($row, $column_name,  $name, $format4);
$worksheet->write($row, $column_name-1,  $nomer, $format1);
#---------------------------------- Друк дистанції ------------------------------------
	my $lat1 = $table->[$i][6]; my $lon1 = $table->[$i][7];
	$i++;
if (defined($table->[$i][6]) ) {
	my $lat2 = $table->[$i][6]; my $lon2 = $table->[$i][7];
	my $distance = $gis->distance( $lat1, $lon1, $lat2, $lon2 );
	$distance = $distance->meters();
	$distance_summ = $distance_summ + ($distance/1000);
	$dist_s =  sprintf('%01f', $distance_summ);
if ($table->[$i][5] >=  $nomer){        # умова не друку останньої дистанції на кінцевій зупинці, бо зупинки ідуть на одну більші $i++
#print "distance=$distance, dist_s=$dist_s, table->[$i][4]=$table->[$i][4], table->[$i][5]=$table->[$i][5]\n";
$worksheet->write($row+1, $column_name+1, $dist_s, $format3);
#-------------------------------- Запис суми довжини маршруту прямого нарямку ------------------------
if (($passport_data->[0][8]-1) == $nomer) {
        $sth = $dbh->prepare("UPDATE characteristics_route SET long_route_dir = $dist_s  WHERE id = 1");   #запис назви маршруту
        $sth->execute();
 $nomer_finish = $dist_s;
}
#------------------------------------------------------------------------------------------------------------------------------------
}
}else{
        $i=$i-1;
}
	$i=$i-1;
#---------------------------------- Завершення друку ----------------------------------
	$nomer++;
	$row++;
	$i++;
	$flights_number = $table->[$i][3];
	$r = $row;
#print "Графік $graphs->[0][1], x=$x\n";
	if ($row % $tape == 0) {		 # друк коли ціле число кратне радкам в сторінці тоді друкуємо хедер $row % $tape == 0
$worksheet->merge_range($r, $c, $r, $c+2, "Маршруту № $routes->[0][2] Графік $graphs->[$graf_sum][1]", $format2);
$worksheet->merge_range($r+1, $c, $r+2, $c, '№  п/п', $format5);
$worksheet->merge_range($r+1, $c+1, $r+2, $c+1,  'Зупинка', $format5);
$worksheet->merge_range($r+1, $c+2, $r+2, $c+2,  'Від-   стань', $format7);
$row = $row + 3;
$list = $list + 3;
        $cc = $c;
        $rr = $r;
        $c=3;
        my $flign_N = 1;
        $a=2;
                       while ($a <= $flig_max+1){       #
                                $a++;
$worksheet->merge_range($r, $c, $r, $c+2, "Рейс № $flign_N", $format2);
$worksheet->merge_range($r+1, $c, $r+2, $c,  'Прибуття', $format5);
$worksheet->merge_range($r+1, $c+1, $r+2, $c+1,  'Стоянка', $format5);
$worksheet->merge_range($r+1, $c+2, $r+2, $c+2,  'Відправлення', $format7);
        $c=$c+3;
        $flign_N = $flign_N+1;
}
        $c = $cc;
        $r = $rr;
}	# завершення циклу друку хедеру сторінки
}
}	# завершення циклу ($flights_number == 2)
	 if ($nomer >= $pc_num) { last       # Вихід з цикла щоб не друкувало 
}
}	# завершення умови elsif ($flights_number == 2)
#---------------------------------- Друк $time часу графіка -----------------------------
	my $column_time = 0;
	$row = $table->[0][5]+2;

	$start = $table->[0][5];
	$flights_number = 1;
	my $flights = 1;
	my $time = ();
	$b = 0;
	for $i ( 0 .. $#{$table} ) {   # цикл для оприділення останього, кінцевого часу та кінцевого номеру рейсу - найбільшого 
	for $j ( 0 .. $#{$table->[$i]} )  {
	$time = $table->[$i][2];
	$flights_number = $table->[$i][3];
}
	$b++;
	if(($flights_number != $flights) || ($column_time == 0)) {  	# умова коли рейс ($flights_number) != 1 або колонка == 0
  	$flights = $flights_number;
	if ($column_time != 0) {
	$row = $row-1;
	$time = $table->[$i-1][2];
$worksheet->write($row, $column_time,  $time, $format3);# друк останніх стрічок (кінцевих часових точок... кінцевих ЧТ...зупинок) графіка
$worksheet->write($row, $column_time+1,  ' ', $format1);
$worksheet->write($row, $column_time+2,  ' ', $format1);
#------------------------ Тривалість рейсу кінець - час ----------------------------

if ($time_dir == 1) {
	$time_dir = 2;

        my $time2 = Time::Piece->strptime($time, '%H:%M');
	my $diff = $time2 - $flight_duration_rev;

# Отримання значення різниці у годинах та хвилинах
	 my $hours = int($diff->hours);
	 my $minutes = $diff->minutes - ($hours * 60);

# Форматування рядка з результатом у форматі "години хвилини"
	 my $result_str = sprintf("%d год. %d хв.", $hours, $minutes);

	 $sth = $dbh->prepare("UPDATE characteristics_route SET flight_duration_rev = ? WHERE id = 1");   #запис назви маршруту
	 $sth->execute( $result_str );

}
#-----------------------------------------------------------------------------------
}
	if ($start != 1) {	# точка аналізу старту друку першої ЧТ графіка, початок графіка, перша зупинка старту
	$start =1;
	}else{
	$row = 3;		# точка кожної колонки в графіку
}
	$column_time = $column_time + 3;
	if ($column_time != 3){
	$time = $table->[$i][2];
}
	if ($list > 3 ){	# на кожному листі добавляється 3 срічки хедера
	$row = $row +3;		# точка друку першої часової точки графіка
}
$worksheet->write($row, $column_time,  ' ', $format3);		# друк часових точок першої зупинки графіку
$worksheet->write($row, $column_time+1,  ' ', $format1);
$worksheet->write($row, $column_time+2,  $time, $format1);
#------------------------ Тривалість рейсу початок - час ----------------------------
if ($time_dir == 0 && $row == 3) {
	$flight_duration_dir = $time;
	$time_dir = 1;
}
#------------------------------------------------------------------------------------
	$list = 0;		# дисткі лише для старту друку - іншим колонкам не потрібні
	}else{
$worksheet->write($row, $column_time,  $time, $format3);
$worksheet->write($row, $column_time+1,  0.5, $format1);
$worksheet->write($row, $column_time+2,  $time, $format1);
$time_rev = $passport_data->[0][8]+2;
#------------------------ Середнє значення Тривалості рейсу - час ----------------------------
if ($time_dir == 1 &&  $time_rev+3 == $row) {
	$time_rev = $time_rev+3;			# перескакування через хедер
}
if ($time_dir == 1 && $row == $time_rev) {
	
	my $time1 = Time::Piece->strptime($time, '%H:%M');
	my $time2 = Time::Piece->strptime($flight_duration_dir, '%H:%M');
	my $diff = $time1 - $time2;
$flight_duration_rev = $time1;

# Отримання значення різниці у годинах та хвилинах
	my $hours = int($diff->hours);
	my $minutes = $diff->minutes - ($hours * 60);

# Форматування рядка з результатом у форматі "години хвилини"
	my $result_str = sprintf("%d год. %d хв.", $hours, $minutes);

        $sth = $dbh->prepare("UPDATE characteristics_route SET flight_duration_dir = ? WHERE id = 1");   #запис назви маршруту
        $sth->execute( $result_str );
}
#--------------------------------------------------------------------------------------------
}
	if ($arr_max == $b) {
$worksheet->write($row, $column_time,  $time, $format3);	# друк кінцевого часу
$worksheet->write($row, $column_time+1,  ' ', $format1);
$worksheet->write($row, $column_time+2,  ' ', $format1);
}
	$row++;
	if ($row % $tape == 0) {
	$row = $row + 3;
}
}
# -------------------- Запис довжини маршруту зворотньоо напрямку --------------------------------
$nomer_finish =	$dist_s - $nomer_finish;
        $sth = $dbh->prepare("UPDATE characteristics_route SET long_route_rev = $nomer_finish WHERE id = 1");   #запис назви маршруту
        $sth->execute();

#----------------------------- Листок 2 -- Гравік режиму праці та відпочинку водіїв -------------
$worksheet = $workbook->add_worksheet();     # добавлення сторінки
$worksheet->set_column('A:B', 2);
$worksheet->set_column('C:AZ', 13);
my %center10 = ();
my %font10 = ();
my %center11 = ();
my %center12 = ();
our %center13 = ();
%font10    = (
                font  => 'Arial',
                size  => 14,
                color => 'black',
                bold  => 1,
              );
my %font11    = (
                font  => 'Arial',
                size  => 10,
                color => 'black',
                bold  => 0,
              );
our %font12    = (
                font  => 'Arial',
                size  => 10,
                color => 'black',
                bold  => 0,
              );
my %font13    = (
                font  => 'Arial',
                size  => 10,
                color => 'black',
                bold  => 1,
              );
%center10   = (
		border  => 0,
                valign  => 'vcenter',
                align   => 'center',
              );
%center11   = (
                border  => 1,
                valign  => 'vcenter',
                align   => 'center',
	       );
%center12   = (
                border  => 1,
                valign  => 'vcenter',
                align   => 'center',
                bg_color => 'yellow',
              );
%center13   = (
                border  => 1,
                valign  => 'vcenter',
                align   => 'center',
                bg_color => 'silver',
              );
my %center14   = (
                border  => 0,
                valign  => 'vcenter',
                align   => 'left',
              );
my $format10 = $workbook->add_format(%font10, %center10);	# Arial' 14  bold  => 1, border=0
my $format11 = $workbook->add_format(%font11, %center10);	# Arial' 11  bold  => 0, border=0
my $format12 = $workbook->add_format(%font12, %center10);	# Arial' 10  bold  => 0, border=0
my $format13 = $workbook->add_format(%font11, %center11);	# Arial' 11  bold  => 1, border=1
my $format14 = $workbook->add_format(%font12, %center12);	# Arial' 10  bold  => 0, border=1 bg_color => 'yellow'
my $format15 = $workbook->add_format(%font12, %center13);       # Arial' 10  bold  => 0, border=1 bg_color => 'navy'
my $format16 = $workbook->add_format(%font13, %center10);       # Arial' 10  bold  => 1, border=0
my $format17 = $workbook->add_format(%font11, %center14);       # Arial' 10  bold  => 1, border=0
#----------------------------------------------- Обіди ----------------------
our $din =0;
our $work =0;
our @din_v1 = ();			# ініціалізація масиву для підрахунку часу
our @din_v2 = (1..4);                  	# ініціалізація масиву для зберігання заг. хар.
$sth = $dbh->prepare("SELECT workshift_id, flight_number, stations_id, pc_number, start_time, end_time, duration, elapsed_worktime
FROM dinners WHERE schedules_id = $schedules_max");
        $sth->execute();
        my $dinners = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $d ( 0 .. $#{$dinners} ) {
        for $j ( 0 .. $#{$dinners->[$d]} )  {
}
 	($sec,$min,$hour)=gmtime($dinners->[$d][4]);            # початок обіду
        $min = sprintf('%02d', $min);
        $hour = sprintf('%02d', $hour);
        $dinners->[$d][4] = join(":", $hour, $min);
        ($sec,$min,$hour)=gmtime($dinners->[$d][5]);            # кінець обіду
        $min = sprintf('%02d', $min);
        $hour = sprintf('%02d', $hour);
        $dinners->[$d][5] = join(":", $hour, $min);
        ($sec,$min,$hour)=gmtime($dinners->[$d][6]);            # тривалість обідулість обіду
	$min = sprintf('%02d', $min);
        $hour = sprintf('%02d', $hour);
        $dinners->[$d][6] = join(":", $hour, $min);
        ($sec,$min,$hour)=gmtime($dinners->[$d][7]);            # час до обіду
        $min = sprintf('%02d', $min);
        $hour = sprintf('%02d', $hour);
        $dinners->[$d][7] = join(":", $hour, $min);
#print "dinners->[$d][0]=$dinners->[$d][0], $dinners->[$d][4], $dinners->[$d][5], $dinners->[$d][6], $dinners->[$d][7] \n";
$din = $d;
}
#-------------------------------- Робочий час -----------------------------------------
$sth = $dbh->prepare("SELECT number, duration, start_time, end_time
FROM workshift WHERE schedule_id = $schedules_max");
        $sth->execute();
        my $workshift = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $w ( 0 .. $#{$workshift} ) {
        for $j ( 0 .. $#{$workshift->[$w]} )  {
		#print "$workshift->[$w][$j]\t";
}
#print "\n";
#print "schedules_max=$schedules_max\n";

        ($sec,$min,$hour)=gmtime($workshift->[$w][1]);            # к-сть відпрацьованих годин
        $min = sprintf('%02d', $min);
        $hour = sprintf('%02d', $hour);
        $workshift->[$w][1] = join(":", $hour, $min);
        ($sec,$min,$hour)=gmtime($workshift->[$w][2]);            # час початку роботи
        $min = sprintf('%02d', $min);
        $hour = sprintf('%02d', $hour);
        $workshift->[$w][2] = join(":", $hour, $min);
        ($sec,$min,$hour)=gmtime($workshift->[$w][3]);            # час закінчення роботи
        $min = sprintf('%02d', $min);
        $hour = sprintf('%02d', $hour);
        $workshift->[$w][3] = join(":", $hour, $min);
	$work = $w;
}
#-------------------- Графік режиму праці та відпочинку водіїв------------------------------------
$worksheet->merge_range('A3:H3', 'Графік', $format10);
	if ($work != 0) {
$worksheet->merge_range('A4:H4', 'режиму праці та відпочинку водіїв на маршруті', $format16);
}else{
$worksheet->merge_range('A4:H4', 'режиму праці та відпочинку водія на маршруті', $format16);
}
$worksheet->merge_range('A5:H5', "№ $routes->[0][2]: $directions->[0][0]", $format16);
$worksheet->merge_range('A6:H6', "Графік № $graphs->[$graf_sum][1]", $format12);
	my $wshift_2 =0;
	if ($work > 0){
        for $i ( 0 .. $#{$table} ) {	# цикл знаходження назви зупинки перезмінки водіїв
        for $j ( 0 .. $#{$table->[$i]} )  {
	if ($table->[$i][$j] eq $workshift->[1][2]){
	$wshift_2  = $table->[$i][4];
	last
}
}
}
}
	my $e = 8;
	$c = 2;
	my $id_workshift = 0;
	my $num = 0;
	$id_workshift =  $dinners->[$din][0];
	if ($work != 0){
$worksheet->merge_range('C7:D8', 'Години/хвилини', $format13);
$worksheet->merge_range('E7:F8', '', $format13);
$worksheet->merge_range('G7:H8', '', $format13);

#	print "11din=$din, work=$work \n";
while ($work > 0) {		# цикл вибору робочих змін
$worksheet->merge_range($e, $c, $e+1, $c+1, "$workshift->[$work][3]", $format13);
#	print "workshift->[$work][3]=$workshift->[$work][3], e=$e \n";
$worksheet->merge_range($e, $c+2, $e+1, $c+3, ' ', $format13);
$worksheet->merge_range($e, $c+4, $e+1, $c+5, 'Закінчення зміни', $format15);
	$e = $e +2;
	if ($din != 0){			# якщо не має в графіку обідів
	while ($din >= 0) {		# цикл виборки обідів 
	if ($num == 1) { 		# умова вібору першого водія (перша колонка)
		$c=$c+2;
$worksheet->merge_range($e, $c, $e+1, $c+1, "$dinners->[$din][5]", $format13);
$worksheet->merge_range($e, $c+2, $e+1, $c+3, "$dinners->[$din][6]", $format14);
$worksheet->merge_range($e, $c+4, $e+1, $c+5, ' ', $format13);
	@din_v1 = split (/:/,$dinners->[$din][6]);		# відділення год від хв і перетворення в сек. для додавання
	$din_v1[0] = $din_v1[0]*60*60;
	$din_v1[1] = $din_v1[1]*60;
	$din_v1[0] = $din_v1[0] + $din_v1[1];
	$din_v2[0] = $din_v2[0] + $din_v1[0];
# 	print "444 dinners->[$din][5]=$dinners->[$din][5], e=$e, din_v1[0]=$din_v1[0], din_v2[0]=$din_v2[0] \n";
        $e = $e +2;
$worksheet->merge_range($e, $c, $e+1, $c+1, "$dinners->[$din][4]", $format13);
#        print "dinners->[$din][4]=$dinners->[$din][4], e=$e \n";
$worksheet->merge_range($e, $c+2, $e+1, $c+3, 'Перерва/відпочинок', $format13);
$worksheet->merge_range($e, $c+4, $e+1, $c+5, ' ', $format13);
        $e = $e +2;
#	print "33din=$din, work=$work, e=$e \n";
	$c=$c-2;
}else{				# умова вібору другого водія (другої колонки)
$worksheet->merge_range($e, $c, $e+1, $c+1, "$dinners->[$din][5]", $format13);
$worksheet->merge_range($e, $c+2, $e+1, $c+3, ' ', $format13);
	@din_v1 = split (/:/,$dinners->[$din][6]);              # відділення год від хв і перетворення в сек. для додавання
	$din_v1[0] = $din_v1[0]*60*60;
	$din_v1[1] = $din_v1[1]*60;
	$din_v1[0] = $din_v1[0] + $din_v1[1];
	$din_v2[1] = $din_v2[1] + $din_v1[1];
$worksheet->merge_range($e, $c+4, $e+1, $c+5, "$dinners->[$din][6]", $format14);
#	print "444 dinners->[$din][5]=$dinners->[$din][5], e=$e \n";
	$e = $e +2;
$worksheet->merge_range($e, $c, $e+1, $c+1, "$dinners->[$din][4]", $format13);
#	print "dinners->[$din][4]=$dinners->[$din][4], e=$e \n";
$worksheet->merge_range($e, $c+2, $e+1, $c+3, ' ', $format13);
$worksheet->merge_range($e, $c+4, $e+1, $c+5, 'Перерва/відпочинок', $format13);
	$e = $e +2;
#	print "33din=$din, work=$work, e=$e \n";
}
	$din = $din -1;
if ($id_workshift != $dinners->[$din][0] ){	# умова перезмвнки
#	print "workshift->[$work][2]=$workshift->[$work][2], e=$e \n";
if ($num == 1){			# умова вібору першого водія (перша колонка)
	$c = $c+2;
$worksheet->merge_range($e, $c, $e+1, $c+1, "$workshift->[$work][2]", $format13);
$worksheet->merge_range($e, $c+2, $e+1, $c+3, 'Початок зміни ', $format15);
$worksheet->merge_range($e, $c+4, $e+1, $c+5, ' ', $format13);
	$e = $e +2;
$worksheet->merge_range($e, $c, $e+1, $c+1, ' ', $format13);
$worksheet->merge_range($e, $c+2, $e+1, $c+3, 'Водій 1', $format13);
$worksheet->merge_range($e, $c+4, $e+1, $c+5, 'Водій 2', $format13);
	$e = $e +2;
$worksheet->merge_range($e, $c, $e+1, $c+1, 'Сумарні показники:', $format13);
$worksheet->merge_range($e, $c+2, $e+1, $c+3, ' ', $format13);
$worksheet->merge_range($e, $c+4, $e+1, $c+5, ' ', $format13);
	$e = $e +2;
$worksheet->merge_range($e, $c, $e+1, $c+1, 'Період керування водія', $format15);
$worksheet->merge_range($e, $c+2, $e+1, $c+3, "$workshift->[$work][1]", $format15);
$worksheet->merge_range($e, $c+4, $e+1, $c+5, "$workshift->[$work-1][1]", $format15);
	$e = $e +2;
	($sec,$min,$hour)=gmtime($din_v2[0]); 		# перетворення сек в год хв і їх обєднання для 1 водія
	$min = sprintf('%02d', $min);
	$hour = sprintf('%02d', $hour);
	$din_v2[0] = join(":", $hour, $min);
	($sec,$min,$hour)=gmtime($din_v2[1]);           # перетворення сек в год хв і їх обєднання для 2 водія
	$min = sprintf('%02d', $min);
	$hour = sprintf('%02d', $hour);
	$din_v2[1] = join(":", $hour, $min);
$worksheet->merge_range($e, $c, $e+1, $c+1, 'Перерви/відпочинок', $format13);
$worksheet->merge_range($e, $c+2, $e+1, $c+3, "$din_v2[0]", $format13);
$worksheet->merge_range($e, $c+4, $e+1, $c+5, "$din_v2[1]", $format13);
#---------------------- Період керування водія + підготовчо заключний час - задається в змінній $time_prep_concl -----------------------
$e = $e +2;
$time_prep_concl = $time_prep_concl_constanta;
$time_prep_concl = $time_prep_concl*60;
#print "time_prep_concl_737 = $time_prep_concl\n";
	@din_v1 = split (/:/,$workshift->[$work][1]);              # 1 водій -відділення год від хв і перетворення в сек. для додавання
        $din_v1[0] = $din_v1[0]*60*60;
        $din_v1[1] = $din_v1[1]*60;
        $din_v1[0] = $din_v1[0] + $din_v1[1];
        $din_v2[2] = $din_v1[0] + $time_prep_concl;
  	($sec,$min,$hour)=gmtime($din_v2[2]);           # перетворення сек в год хв і їх обєднання для 1 водія
        $min = sprintf('%02d', $min);
        $hour = sprintf('%02d', $hour);
        $din_v2[2] = join(":", $hour, $min);

        @din_v1 = split (/:/,$workshift->[$work-1][1]);              # 2 водій відділення год від хв і перетворення в сек. для додавання
        $din_v1[0] = $din_v1[0]*60*60;
        $din_v1[1] = $din_v1[1]*60;
        $din_v1[0] = $din_v1[0] + $din_v1[1];
        $din_v2[3] = $din_v1[0] + $time_prep_concl;
  	($sec,$min,$hour)=gmtime($din_v2[3]);           # перетворення сек в год хв і їх обєднання для 1 водія
        $min = sprintf('%02d', $min);
        $hour = sprintf('%02d', $hour);
        $din_v2[3] = join(":", $hour, $min);
$worksheet->merge_range($e, $c, $e+1, $c+1, 'Тривалість робочого часу', $format13); 
$worksheet->merge_range($e, $c+2, $e+1, $c+3, "$din_v2[2]", $format13);
$worksheet->merge_range($e, $c+4, $e+1, $c+5, "$din_v2[3]", $format13);
	$e = $e +3;
$worksheet->merge_range($e, $c, $e, $c+5, '          Примітка: у графіку не відображається час простою до 15 хв. ', $format17);
$worksheet->merge_range($e+1, $c, $e+1, $c+3, '          Пункти зміни водіїв: ', $format17);
$worksheet->merge_range($e+2, $c, $e+2, $c+3, '                  у прямому напрямку:         відсутні;           ', $format17);
$worksheet->merge_range($e+3, $c, $e+3, $c+3, "                  у зворотньому напрямку: $wshift_2. ", $format17);
	$c = $c-2;
}else{				# умова вібору другого водія (другої колонки)
$worksheet->merge_range($e, $c, $e+1, $c+1, "$workshift->[$work][2]", $format13);
$worksheet->merge_range($e, $c+2, $e+1, $c+3, 'Закінчення зміни ', $format15);
$worksheet->merge_range($e, $c+4, $e+1, $c+5, 'Початок зміни', $format15);
}
  	$num = 1;
 	$id_workshift = $dinners->[$din][0];
	$e = $e +2;
	$c=$c-2;
	$work = $work -1;
}
}
}else{
 	$worksheet->merge_range($e, $c, $e+1, $c+1, "$workshift->[$work][2]", $format13);
        $worksheet->merge_range($e, $c+2, $e+1, $c+3, 'Закінчення зміни ', $format15);
        $worksheet->merge_range($e, $c+4, $e+1, $c+5, 'Початок зміни', $format15);
	$e = $e +2;
   	$worksheet->merge_range($e, $c, $e+1, $c+1, "$workshift->[$work-1][2]", $format13);
 	$worksheet->merge_range($e, $c+2, $e+1, $c+3, 'Початок зміни', $format15);
 	$worksheet->merge_range($e, $c+4, $e+1, $c+5, ' ', $format13);
	$work = $work -1;
 	$e = $e +2;
        $worksheet->merge_range($e, $c, $e+1, $c+1, ' ', $format13);
        $worksheet->merge_range($e, $c+2, $e+1, $c+3, 'Водій 1', $format13);
        $worksheet->merge_range($e, $c+4, $e+1, $c+5, 'Водій 2', $format13);
 	$e = $e +2;
    	$worksheet->merge_range($e, $c, $e+1, $c+1, 'Сумарні показники:', $format13);
        $worksheet->merge_range($e, $c+2, $e+1, $c+3, ' ', $format13);
        $worksheet->merge_range($e, $c+4, $e+1, $c+5, ' ', $format13);
       	$e = $e +2;
        $worksheet->merge_range($e, $c, $e+1, $c+1, 'Період керування водія', $format13);
        $worksheet->merge_range($e, $c+2, $e+1, $c+3, "$workshift->[$work][1]", $format13);
        $worksheet->merge_range($e, $c+4, $e+1, $c+5, "$workshift->[$work-1][1]", $format13);
	 $e = $e +2;
$worksheet->merge_range($e, $c, $e+1, $c+1, 'Перерви/відпочинок', $format13);
$worksheet->merge_range($e, $c+2, $e+1, $c+3, ' ', $format13);
$worksheet->merge_range($e, $c+4, $e+1, $c+5, ' ', $format13);
	$time_prep_concl = $time_prep_concl*60;
	#print "time_prep_concl_803 = $time_prep_concl\n";

        @din_v1 = split (/:/,$workshift->[$work][1]);              # 1 водій -відділення год від хв і перетворення в сек. для додавання
        $din_v1[0] = $din_v1[0]*60*60;
        $din_v1[1] = $din_v1[1]*60;
        $din_v1[0] = $din_v1[0] + $din_v1[1];
        $din_v2[2] = $din_v1[0] + $time_prep_concl;
        ($sec,$min,$hour)=gmtime($din_v2[2]);           # перетворення сек в год хв і їх обєднання для 1 водія
        $min = sprintf('%02d', $min);
        $hour = sprintf('%02d', $hour);
        $din_v2[2] = join(":", $hour, $min);
        @din_v1 = split (/:/,$workshift->[$work-1][1]);              # 2 водій відділення год від хв і перетворення в сек. для додавання
        $din_v1[0] = $din_v1[0]*60*60;
        $din_v1[1] = $din_v1[1]*60;
        $din_v1[0] = $din_v1[0] + $din_v1[1];
        $din_v2[3] = $din_v1[0] + $time_prep_concl;
        ($sec,$min,$hour)=gmtime($din_v2[3]);           # перетворення сек в год хв і їх обєднання для 1 водія
        $min = sprintf('%02d', $min);
        $hour = sprintf('%02d', $hour);
        $din_v2[3] = join(":", $hour, $min);
	$e = $e +2;
$worksheet->merge_range($e, $c, $e+1, $c+1, 'Тривалість робочого часу', $format13);
$worksheet->merge_range($e, $c+2, $e+1, $c+3, "$din_v2[2]", $format13);
$worksheet->merge_range($e, $c+4, $e+1, $c+5, "$din_v2[3]", $format13);
	 $e = $e +4;
$worksheet->merge_range($e, $c, $e, $c+5, '          Примітка: у графіку не відображається час простою до 15 хв. ', $format17);
$worksheet->merge_range($e+1, $c, $e+1, $c+3, '          Пункти зміни водіїв: ', $format17);
$worksheet->merge_range($e+2, $c, $e+2, $c+3, '                  у прямому напрямку:         відсутні;           ', $format17);
	if ($wshift_2 eq '0'){
$worksheet->merge_range($e+3, $c, $e+3, $c+3, "                  у зворотньому напрямку: $wshift_2 ", $format17);
}else{
$worksheet->merge_range($e+3, $c, $e+3, $c+3, '                  у зворотньому напрямку: відсутні. ', $format17);
}
	$e = $e +2;
}
	$work = $work -1;
}
}else{
#--------------------------- Для одного водія -----------------------------------------
$worksheet->merge_range('C7:E8', 'Години/хвилини', $format13);
$worksheet->merge_range('F7:H8', '', $format13);
$worksheet->merge_range($e, $c, $e+1, $c+2, "$workshift->[$work][3]", $format13);
$worksheet->merge_range($e, $c+3, $e+1, $c+5, 'Закінчення зміни', $format15);
	while ($din >= 0){
	if ( !defined($dinners->[$din][5]) ) { last }
	$e = $e +2;
$worksheet->merge_range($e, $c, $e+1, $c+2, "$dinners->[$din][5]", $format13);
$worksheet->merge_range($e, $c+3, $e+1, $c+5, "$dinners->[$din][6]", $format14);
	$e = $e +2;
$worksheet->merge_range($e, $c, $e+1, $c+2, "$dinners->[$din][4]", $format13);
$worksheet->merge_range($e, $c+3, $e+1, $c+5, 'Перерва/відпочинок', $format13);
	if ($din == 0){last}
	$din = $din -1;
}
	$e = $e +2;
$worksheet->merge_range($e, $c, $e+1, $c+2, "$workshift->[$work][2]", $format13);
$worksheet->merge_range($e, $c+3, $e+1, $c+5, 'Початок зміни ', $format15);
	$e = $e +2;
$worksheet->merge_range($e, $c, $e+1, $c+2, ' ', $format13);
$worksheet->merge_range($e, $c+3, $e+1, $c+5, 'Водій', $format13);
	$e = $e +2;
$worksheet->merge_range($e, $c, $e+1, $c+2, 'Сумарні показники:', $format13);
$worksheet->merge_range($e, $c+3, $e+1, $c+5, ' ', $format13);
        $e = $e +2;
$worksheet->merge_range($e, $c, $e+1, $c+2, 'Період керування водія', $format15);
$worksheet->merge_range($e, $c+3, $e+1, $c+5, "$workshift->[$work][1]", $format15);
	if ( defined($dinners->[$din][5]) ) {
      	@din_v1 = split (/:/,$dinners->[$din][6]);              # відділення год від хв і перетворення в сек. для додавання
        $din_v1[0] = $din_v1[0]*60*60;
        $din_v1[1] = $din_v1[1]*60;
        $din_v2[0] = $din_v1[0] + $din_v1[1];
      	@din_v1 = split (/:/,$dinners->[$din+1][6]);              # відділення год від хв і перетворення в сек. для додавання
        $din_v1[0] = $din_v1[0]*60*60;
        $din_v1[1] = $din_v1[1]*60;
        $din_v2[1] = $din_v1[0] + $din_v1[1];
	$din_v2[0] = $din_v2[0] + $din_v2[1];
       ($sec,$min,$hour)=gmtime($din_v2[0]);           # перетворення сек в год хв і їх обєднання для 1 водія
        $min = sprintf('%02d', $min);
        $hour = sprintf('%02d', $hour);
        $din_v2[0] = join(":", $hour, $min);
}
        $e = $e +2;
$worksheet->merge_range($e, $c, $e+1, $c+2, 'Перерви/відпочинок', $format13);
	if ( !defined($dinners->[$din][5]) ) {
$worksheet->merge_range($e, $c+3, $e+1, $c+5, ' ', $format13);
}else{
$worksheet->merge_range($e, $c+3, $e+1, $c+5, "$din_v2[0]", $format13);
}
	$e = $e +2;
	$time_prep_concl = $time_prep_concl*60;
	#print "time_prep_concl_891 = $time_prep_concl\n";

	@din_v1 = split (/:/,$workshift->[$work][1]);              # 1 водій -відділення год від хв і перетворення в сек. для додавання
        $din_v1[0] = $din_v1[0]*60*60;
        $din_v1[1] = $din_v1[1]*60;
        $din_v1[0] = $din_v1[0] + $din_v1[1];
        $din_v2[2] = $din_v1[0] + $time_prep_concl;
        ($sec,$min,$hour)=gmtime($din_v2[2]);           # перетворення сек в год хв і їх обєднання для 1 водія
        $min = sprintf('%02d', $min);
        $hour = sprintf('%02d', $hour);
        $din_v2[2] = join(":", $hour, $min);
$worksheet->merge_range($e, $c, $e+1, $c+2, 'Тривалість робочого часу', $format13);
$worksheet->merge_range($e, $c+3, $e+1, $c+5, "$din_v2[2]", $format13);
	$e = $e +4;
$worksheet->merge_range($e, $c, $e, $c+5, '          Примітка: у графіку не відображається час простою до 15 хв. ', $format17);
$worksheet->merge_range($e+1, $c, $e+1, $c+3, '          Пункти зміни водіїв: ', $format17);
$worksheet->merge_range($e+2, $c, $e+2, $c+3, '                  у прямому напрямку:         відсутні;           ', $format17);
        if ($wshift_2 eq '0'){
$worksheet->merge_range($e+3, $c, $e+3, $c+3, "                  у зворотньому напрямку: $wshift_2 ", $format17);
}else{
$worksheet->merge_range($e+3, $c, $e+3, $c+3, '                  у зворотньому напрямку:  відсутні. ', $format17);
}
}
$worksheet = $workbook->add_worksheet();     # добавлення сторінки
}
#-------------------------------------- Характеристика маршруту ---------------------------
# $workbook  = Excel::Writer::XLSX->new('simple1.xlsx');
        #die "Problems creating new Excel file: $!" unless defined $workbook;

$sth = $dbh->prepare("SELECT id, schedules_id, time, flights_number, stations_id, pc_number
FROM schedule_times WHERE schedules_id = $schedules_max");
        $sth->execute();
        my $table = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$table} ) {
        for $j ( 0 .. $#{$table->[$i]} )  {
}
my $sth = $dbh->prepare("SELECT name, id, latitude, longitude FROM stations WHERE id = $table->[$i][4]");
        $sth->execute();
        my $row_ref = $sth -> fetchrow_arrayref
        or die "$sth -> errstr\n";
        $table->[$i][4] = $row_ref->[0];
	$table->[$i][3] = $row_ref->[1];
        $arr_max++;                                             # max елемент масиву по j $table
}

my %font10    = (
                font  => 'Arial',
                size  => 14,
                color => 'black',
                bold  => 1,
              );
my %font20    = (
                font  => 'Arial',
                size  => 10,
                color => 'black',
                bold  => 0,
              );
my %center10   = (
                border  => 0,
                valign  => 'vcenter',
                align   => 'center',
              );
my %center20   = (
                border  => 0,
                valign  => 'vcenter',
                align   => 'center',
              );
my %center21   = (
                border  => 1,
                valign  => 'vcenter',
                align   => 'center',
              );
my %center22   = (
                border  => 1,
                valign  => 'vcenter',
                align   => 'left',
              );
my %center23   = (
                border  => 0,
                valign  => 'vcenter',
                align   => 'left',
              );
	my $format10 = $workbook->add_format(%font10, %center10);
	my $format20 = $workbook->add_format(%font20, %center20);  
	my $format21 = $workbook->add_format(%font20, %center21);
	my $format22 = $workbook->add_format(%font20, %center22);
	my $format23 = $workbook->add_format(%font20, %center23);
$format21->set_text_wrap();   # авто перені стрічки в клітиночці 
$worksheet->set_margin_top(0.4);	# по центру
$worksheet->set_column('A:A', 5);
$worksheet->set_column('B:B', 5);
$worksheet->set_column('C:C', 37);
$worksheet->set_column('D:G', 8);
$worksheet->merge_range('A2:G2', 'ХАРАКТЕРИСТИКА МАРШРУТУ', $format10);
$worksheet->merge_range('B4:C4', '   3) облаштування зупинок', $format23);
$format21->set_text_wrap();	# перенос тексту в клітинці
$worksheet->merge_range('B5:B7', "№\nз/п", $format21);
$worksheet->merge_range('C5:C7', "Назва зупинки \nу прямому напрямку", $format21);
$worksheet->merge_range('D5:G5', 'Облаштування', $format21);
$worksheet->merge_range('D6:D7', "авто-\nстанція", $format21);
$worksheet->merge_range('E6:E7', "павіль-\nйон", $format21);
$worksheet->merge_range('F6:F7', "навіс", $format21);
$worksheet->merge_range('G6:G7', "лава", $format21);
	$a =7;
	my $n=1;
 	my $x=0;
	my $y=0;
 	my $c=1;
	my $str =5;		# для вирахування стрічок друку на листку
	$tape = $tape+10;
	my $return_flight=0;
	my $start_route =0;
	my $f =0;
	my $g =0;
	my $pas_stop =0;
	my @pas_stop = ();
#	my $table=();
$sth = $dbh->prepare("SELECT id_station, id, IFNULL(radio_pzz, 0) radio_pzz, IFNULL(avto_stops, 0) avto_stops, IFNULL(pavilion, 0) pavilion, IFNULL(navis, 0) navis, IFNULL(lava, 0) lava FROM passport_stops_routes WHERE id order by id");
        $sth->execute();
        $pas_stop = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $f ( 0 .. $#{$pas_stop} ) {
        for $g ( 0 .. $#{$pas_stop->[$f]} )  {
  
		#		print "routes=$pas_stop->[$f][$g]\t";
}
#print "\n";
if ($pas_stop->[$f][2] == 1) {$reverse_stop = $pas_stop->[$f][1]};   # при закінченні друку прямого рейсу, це PZZ
#print "reverse_stop = $reverse_stop \n";
}
$f=0;
for $i ( 0 .. $#{$table} ) {
	#print "table->[$i][5]=$table->[$i][5], table->[$i][4]=$table->[$i][4]\n";
	$start_route = $table->[$i][5];
if ($start_route == 1){
         $y++;
}
if ($y == 1) {
	#print "routes=$pas_stop->[$f][0], $pas_stop->[$f][1], $pas_stop->[$f][2], $pas_stop->[$f][3], $pas_stop->[$f][4]\n";

if ($pas_stop->[$f][3] == 0) {$pas_stop->[$f][3] = ''} else {$pas_stop->[$f][3] = '+'}; 
if ($pas_stop->[$f][4] == 0) {$pas_stop->[$f][4] = ''} else {$pas_stop->[$f][4] = '+'};
if ($pas_stop->[$f][5] == 0) {$pas_stop->[$f][5] = ''} else {$pas_stop->[$f][5] = '+'};
if ($pas_stop->[$f][6] == 0) {$pas_stop->[$f][6] = ''} else {$pas_stop->[$f][6] = '+'};


$worksheet->write($a, $c, $n, $format21);
$worksheet->write($a, $c+1, " $table->[$i][4]", $format22);
$worksheet->write($a, $c+2, $pas_stop->[$f][3], $format21);
$worksheet->write($a, $c+3, $pas_stop->[$f][4], $format21);
$worksheet->write($a, $c+4, $pas_stop->[$f][5], $format21);
$worksheet->write($a, $c+5, $pas_stop->[$f][6], $format21);
	$n++;
	$a++;
	$x++;
	$str++;
	$f++;
if ($str % $tape == 0){		# перехід на наступну кратну стрічкам сторінку
$worksheet->merge_range($a, $c, $a+2, $c, "№\nз/п", $format21);
if ($return_flight == 0) {
$worksheet->merge_range($a, $c+1, $a+2, $c+1, "Назва зупинки \nу прямому напрямку", $format21);
}else{
$worksheet->merge_range($a, $c+1, $a+2, $c+1, "Назва зупинки \nу зворотньому напрямку", $format21);
}
$worksheet->merge_range($a, $c+2, $a, $c+5, 'Облаштування', $format21);
$worksheet->merge_range($a+1, $c+2, $a+2, $c+2, "авто-\nстанція", $format21);
$worksheet->merge_range($a+1, $c+3, $a+2, $c+3, "павіль-\nйон", $format21);
$worksheet->merge_range($a+1, $c+4, $a+2, $c+4, "навіс", $format21);
$worksheet->merge_range($a+1, $c+5, $a+2, $c+5, "лава", $format21);
	$a=$a+3;
	$str++;
}
if ($reverse_stop-1 == $table->[$i][5]) {	# PZZ -  при закінченні друку прямого рейсу посеред листка додаються стрічки і забезпечується перехід
if ($str <= $tape) {				# на початок друку шапки зворотнього рейсу
	$str = $str + ($tape-$str);
	$a=$str+2;
}else{
	$str = ($str + $tape)-($str-$tape);
	$a=$str+2;
}
$worksheet->merge_range($a, $c, $a+2, $c, "№\nз/п", $format21);
$worksheet->merge_range($a, $c+1, $a+2, $c+1, "Назва зупинки \nу зворотньому напрямку", $format21);
$worksheet->merge_range($a, $c+2, $a, $c+5, 'Облаштування', $format21);
$worksheet->merge_range($a+1, $c+2, $a+2, $c+2, "авто-\nстанція", $format21);
$worksheet->merge_range($a+1, $c+3, $a+2, $c+3, "павіль-\nйон", $format21);
$worksheet->merge_range($a+1, $c+4, $a+2, $c+4, "навіс", $format21);
$worksheet->merge_range($a+1, $c+5, $a+2, $c+5, "лава", $format21);

        $a=$a+3;
        $str++;
	$n = 1;
	$return_flight =1;
}
}
}
	$sth->finish();
$dbh->disconnect;

