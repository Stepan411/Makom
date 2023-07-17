#!/usr/bin/env perl

#use POSIX qw(strftime);
use strict;
use warnings;
use Exporter;
use Switch;
use Data::Dumper;
use FindBin;
use DBI;
use feature qw(fc say);

binmode(STDOUT,':utf8');
use utf8;
use open qw(:utf8 :std);

  my $dbh = DBI->connect('DBI:mysql:makom', 'vizor', 'MBfhSg^4h5b%g3K'
                   ) || die "Could not connect to database: $DBI::errstr";
$dbh->{mysql_enable_utf8} = 1;
$dbh->do("SET NAMES 'utf8'");
my $i;
my $j;
my ($x, $y, $str, $id_menu, @na, $elem, $fi1);
my $sth = $dbh->prepare("SELECT * FROM routes ORDER BY CAST(name AS SIGNED) ASC");
        $sth->execute();
        my $routes = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$routes} ) {
        for $j ( 0 .. $#{$routes->[$i]} )  {
        }
}

$sth = $dbh->prepare("SELECT name
FROM route_directions WHERE routes_id = $routes->[0][0]");
        $sth->execute();
        my $directions = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$directions} ) {
        for $j ( 0 .. $#{$directions->[$i]} )  {
        }
}

$sth = $dbh->prepare("SELECT * FROM graphs ORDER BY name ASC");
        $sth->execute();
        my $graphs = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $x ( 0 .. $#{$graphs} ) {
        for $y ( 0 .. $#{$graphs->[$x]} )  {
        }
}
@na=param;
foreach $elem (@na)
{$_=param($elem);
        eval"\$$elem='$_'";
}
$fi1='views/menu.tt';
   open(F2,"> $fi1");

print F2<<MET;
<!DOCTYPE html>
<html lang="en">
[% IF session.logged_in %]
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
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
.prokrutka {
height: 355px; /* высота нашего блока */
width:110px; /* ширина нашего блока */
background: #fff; /* цвет фона, белый */
border: 1px solid red; /* размер и цвет границы блока */
/* прокрутка по горизонтали */
overflow-y: auto; /*scroll;   прокрутка по вертикали */
}
</style>
  </head>
                <body>
         <div class="vh-100 p-3" style="background-color: #eee;">

<div class="row g-0 text-center">
  <div class="col-sm-6 col-md-4">

<main class="d-flex flex-nowrap flex-nowrap">
  <h1 class="visually-hidden">Sidebars examples</h1>
<div class="b-example-divider b-example-vr"></div>
<div class="flex-shrink-0 p-3 bg-white" style="width: 140px;">
    <a href="/" class="d-flex align-items-center pb-3 mb-3 link-dark text-decoration-none border-bottom">
<!-- <img class="bi pe-none me-2" src="images/gear-wide.svg" alt="Bootstrap" width="16" height="16">-->


      <span class="fs-5 fw-semibold">Автобуси</span>
    </a>
<div class="prokrutka shadow p-3 mb-5 bg-body rounded">
    <ul class="list-unstyled ps-0">
MET
 for $i ( 0 .. $#{$routes} ) {
        for $j ( 0 .. $#{$routes->[$i]} )  {
        }
$str = $routes->[$i][4];
$id_menu = 'id_menu'."$str";

print F2<<MET;
       <li class="mb-1">
        <button onclick = "checkAttr_$routes->[$i][4]()" class="btn btn-toggle d-inline-flex align-items-center rounded border-0 collapsed" data-bs-toggle="collapse" data-bs-target="#$id_menu-collapse" aria-expanded="false">
          $routes->[$i][4]
        </button>
<script>
function checkAttr_$routes->[$i][4]() {
document.getElementById('routes').value = $routes->[$i][4]
document.getElementById('routes_id').value = $routes->[$i][0]
document.getElementById('graphs').value = 'Всі'
}
</script>
        <div class="collapse" id="$id_menu-collapse">
          <ul class="btn-toggle-nav list-unstyled fw-normal pb-1 small">
MET
        for $x ( 0 .. $#{$graphs} ) {
        for $y ( 0 .. $#{$graphs->[$x]} ) {
        }
        if (($routes->[$i][0] == $graphs->[$x][2]) && ($routes->[$i][1] == 1)){
print F2<<MET;
            <li><a href="#" onclick = "checkAttr_$routes->[$i][4]_$graphs->[$x][1]()" class="link-dark d-inline-flex text-decoration-none rounded">$graphs->[$x][1]</a></li>
<script>
function checkAttr_$routes->[$i][4]_$graphs->[$x][1]() {
document.getElementById('routes').value = $routes->[$i][4]
document.getElementById('routes_id').value = $routes->[$i][0]
document.getElementById('graphs').value = $graphs->[$x][1]
document.getElementById('graphs_id').value = $graphs->[$x][0]
}
</script>
MET
}
}



MET
 for $i ( 0 .. $#{$routes} ) {
        for $j ( 0 .. $#{$routes->[$i]} )  {
        }
$str = $routes->[$i][4];
$id_menu = 'id_menu'."$str";

print F2<<MET;
       <li class="mb-1">
        <button onclick = "checkAttr_$routes->[$i][4]()" class="btn btn-toggle d-inline-flex align-items-center rounded border-0 collapsed" data-bs-toggle="collapse" data-bs-target="#$id_menu-collapse" aria-expanded="false">
          $routes->[$i][4]
        </button>
<script>
function checkAttr_$routes->[$i][4]() {
document.getElementById('routes').value = $routes->[$i][4]
document.getElementById('routes_id').value = $routes->[$i][0]
document.getElementById('graphs').value = 'Всі'
}
</script>
        <div class="collapse" id="$id_menu-collapse">
          <ul class="btn-toggle-nav list-unstyled fw-normal pb-1 small">
MET
        for $x ( 0 .. $#{$graphs} ) {
        for $y ( 0 .. $#{$graphs->[$x]} ) {
        }
        if (($routes->[$i][0] == $graphs->[$x][2]) && ($routes->[$i][1] == 2)){
print F2<<MET;
            <li><a href="#" onclick = "checkAttr_$routes->[$i][4]_$graphs->[$x][1]()" class="link-dark d-inline-flex text-decoration-none rounded">$graphs->[$x][1]</a></li>
<script>
function checkAttr_$routes->[$i][4]_$graphs->[$x][1]() {
document.getElementById('routes').value = $routes->[$i][4]
document.getElementById('routes_id').value = $routes->[$i][0]
document.getElementById('graphs').value = $graphs->[$x][1]
document.getElementById('graphs_id').value = $graphs->[$x][0]
}
</script>
MET
}
}
print F2<<MET;
          </ul>
        </div>
      </li>
MET
}




print F2<<MET;
    </div>
   </ul>
 </div>
<div class="b-example-divider b-example-vr"></div>
</main>
      <script src="javascripts/sidebars.js"></script>


</div>
  <div class="col-6 col-md-6">
<div class="d-flex align-items-center h-100">
  <div class="shadow-lg p-3 mb-5 bg-white rounded ssfon">
    <h1><span class="mak-color">мак</span>-ом</h1>
    <form action="/menu" method=post>
      <div class="container text-center">
        <div class="row align-items-start">
          <div class="col">
                <p><b> Волинська область</b><br>
          </div>
          <div class="col">
                <p><b> м. Луцьк</b><br>
          </div>
          <div class="col">
                <p><b>Дата паспорта:</b><br>
          </div>
       </div>
       <div class="row align-items-center">
          <div class="col">
                <p><b>Маршрут:</b><br>
          </div>
          <div class="col">
                <P><input type="text" id="routes" size="10" name=routes></P>
                <input type="hidden" id="routes_id" name=routes_id>
          </div>
          <div class="col">
                <p><b>Автобуси</b><br>
          </div>
        </div>
       <div class="row align-items-end">
          <div class="col">
                <p><b>Графік:</b><br>
          </div>
          <div class="col">
                <P><input type="text" id="graphs" size="10" name=graphs></P>
                <input type="hidden" id="graphs_id" name=graphs_id>
          </div>
          <div class="col">
<select class="form-select" aria-label="Default select example" name=val_select>
<!--  <option selected>Транспорт:</option>>-->
  <option value="1">Автобуси</option>
  <option value="2">Тролейбуси</option>
  <option value="3">Трамваї</option>
</select>
           </div>
          <div class="footer-login">
                        <input class="btn btn-primary" type="submit" value="Вибір">
                        <a href="[% logout_url %]" class="btn btn-outline-primary">Вихід</a>
          </div>
        </div>
      </div>
     </form>
     </div>
    </div>
  </div>
</div>

  </body>
  [% END %]
</html>
MET
close F2;
redirect '/';
        template 'synch_ron.tt', {
#                        'start2' => \@start,
        };
};

	

