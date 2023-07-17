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

my $dbh = DBI->connect('DBI:mysql:maklutsk', 'vizor', 'MBfhSg^4h5b%g3K'
                   ) || die "Could not connect to database: $DBI::errstr";
$dbh->{mysql_enable_utf8} = 1;
$dbh->do('set names "UTF8"');
#--------- -------------- Маршрут id ------------------------------
my $sth = $dbh->prepare("SELECT * FROM routes ORDER BY CAST(name AS SIGNED) ASC");
        $sth->execute();
        my $routes = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$routes} ) {
        for $j ( 0 .. $#{$routes->[$i]} )  {
#print "routes=$routes->[$i][$j]\t";
}
#print "\n";
}
#--------- -------------- Назва маршруту ------------------------------
$sth = $dbh->prepare("SELECT name
FROM route_directions WHERE routes_id = $routes->[0][0]");
        $sth->execute();
        my $directions = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$directions} ) {
        for $j ( 0 .. $#{$directions->[$i]} )  {
}
#print "$directions->[$i][0] \n";
}
#--------- -------------- Назви (Номера) графіків ------------------------------
$sth = $dbh->prepare("SELECT * FROM graphs ORDER BY name ASC");
        $sth->execute();
        my $graphs = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $x ( 0 .. $#{$graphs} ) {
        for $y ( 0 .. $#{$graphs->[$x]} )  {
#print "Графік=$graphs->[$x][$y] \t";
}
#print "\n";
}

@na=param;
foreach $elem (@na)
{$_=param($elem);
        eval"\$$elem='$_'";
}
$fi1='menu.tt';
   open(F2,"> $fi1");
#   print "Content-type: text/html\n\n";
print F2<<MET;
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="Mark Otto, Jacob Thornton, and Bootstrap contributors">
    <meta name="generator" content="Hugo 0.101.0">
    <title>Sidebars · Bootstrap v5.2</title>

    <link rel="canonical" href="https://getbootstrap.com/docs/5.2/examples/sidebars/">

<!--<link href="../assets/dist/css/bootstrap.min.css" rel="stylesheet">-->

<link rel="stylesheet" type="text/css" href="css/sidebars.css" media="screen">
<link rel="stylesheet" type="text/css" href="css/sidebars_my.css" media="screen">

<script src="javascripts/sidebars.js"></script>
  
	<link href="css/sidebars.css" rel="stylesheet">
<style>
.prokrutka {
height: 355px; /* высота нашего блока */
width:110px; /* ширина нашего блока */
background: #fff; /* цвет фона, белый */
border: 1px solid #C1C1C1; /* размер и цвет границы блока */
/* прокрутка по горизонтали */
overflow-y: auto; /*scroll;   прокрутка по вертикали */
}
</style>


  </head>
  <body>

<main class="d-flex flex-nowrap">
  <h1 class="visually-hidden">Sidebars examples</h1>
<div class="b-example-divider b-example-vr"></div>
  
<div class="flex-shrink-0 p-3 bg-white" style="width: 140px;">
    <a href="/" class="d-flex align-items-center pb-3 mb-3 link-dark text-decoration-none border-bottom">
<!-- <img class="bi pe-none me-2" src="images/gear-wide.svg" alt="Bootstrap" width="16" height="16">-->
      <span class="fs-5 fw-semibold">Луцьк</span>
    </a>
<div class="prokrutka">
    <ul class="list-unstyled ps-0">
MET
     	for $i ( 0 .. $#{$routes} ) {
        for $j ( 0 .. $#{$routes->[$i]} )  {
	}
$str = $routes->[$i][4];
$id_menu = 'id_menu'."$str";
#print "routes=$routes->[$i][4], id_menu=$id_menu\n";
print F2<<MET;
       <li class="mb-1">
        <button class="btn btn-toggle d-inline-flex align-items-center rounded border-0 collapsed" data-bs-toggle="collapse" data-bs-target="#$id_menu-collapse" aria-expanded="false">
          $routes->[$i][4]
	</button>
        <div class="collapse" id="$id_menu-collapse">
          <ul class="btn-toggle-nav list-unstyled fw-normal pb-1 small">
MET
        for $x ( 0 .. $#{$graphs} ) {
        for $y ( 0 .. $#{$graphs->[$x]} ) { 
        }
	if ($routes->[$i][0] == $graphs->[$x][2]){
#print "routes->[$i][4]=$routes->[$i][4], Графік=$graphs->[$x][2], Графік=$graphs->[$x][1] \n";
print F2<<MET;
            <li><a href="#" class="link-dark d-inline-flex text-decoration-none rounded">$graphs->[$x][1]</a></li>
MET
}
}
print F2<<MET;
          </ul>
        </div>
      </li>
MET
#print "\n";
}
print F2<<MET;
    </div>
   </ul>
  </div>
</main>
      <script src="javascripts/sidebars.js"></script>
  </body>
</html>
MET
close F2;
exit;

