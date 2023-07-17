#!/usr/bin/env perl
package Makom;
use Dancer2;
use DBI;
use base qw( Template::Base );
binmode(STDOUT,':utf8');
use utf8;
use open qw(:utf8 :std);
use File::Slurper qw/ read_text /;
use feature qw(fc say);
use Excel::Writer::XLSX;
use CGI qw(param);

our $VERSION = '0.1';

my $flash;
sub set_flash {
    my $message = shift;
    $flash = $message;
}
 
sub get_flash {
    my $msg = $flash;
    $flash = "";
    return $msg;
}

my @start = ('Wo', 'Wo');

hook before_template_render => sub {
    my $tokens = shift;
    $tokens->{'css_url'} = request->base . 'css/style.css';
    $tokens->{'login_url'} = uri_for('/login');
    $tokens->{'logout_url'} = uri_for('/logout');
};

hook before => sub {
	var foo => 42;
};

@start = ('R', 'D');
sub connect_db {
	my $dbh = DBI->connect('DBI:mysql:makom', 'vizor', 'MBfhSg^4h5b%g3K'
                   ) || die "Could not connect to database: $DBI::errstr";
$dbh->{mysql_enable_utf8} = 1;
$dbh->do("SET NAMES 'utf8'");
    return $dbh;
}

sub init_db {
    my $db     = connect_db();
    my $schema = read_text('./schema.sql');
    $db->do($schema)
        or die $db->errstr;
}

get '/menu' => sub {
	my $db  = connect_db();
    	my $sql = 'select id, routes, graphs from passport where id=1';
    	my $sth = $db->prepare($sql)
            or die $db->errstr;
    	$sth->execute
        or die $sth->errstr;
       		template 'menu.tt', {
        msg           => get_flash(),
        menu_add => uri_for('/menu/add'),
        passport => $sth->fetchall_hashref('id'),
        };
};

post '/menu' => sub {
    my $db  = connect_db();
    my $sql = 'UPDATE passport SET routes = ?, routes_id = ?, graphs = ?, graphs_id = ?, transport_types_id = ? WHERE id = 1';
    my $sth = $db->prepare($sql)
        or die $db->errstr;
    $sth->execute(
        body_parameters->get('routes'),
	body_parameters->get('routes_id'),
        body_parameters->get('graphs'),
	body_parameters->get('graphs_id'),
	body_parameters->get('val_select')
    ) or die $sth->errstr;
    set_flash('Опубліковано новий запис');
    redirect '/';
};
my $s411=8;
get '/passport' => sub {
#any ['get', 'post'] => '/passport' => sub {
    	my $err; 
    	my $db  = connect_db();
    	my $sql = 'select id, routes, graphs from passport where id=1';
    	my $sth = $db->prepare($sql)
            or die $db->errstr;
    $sth->execute
        or die $sth->errstr;
	my $s411 = body_parameters->get('option1');
#	 print "s411=$s411\n";

	        template 'passport.tt', {
	passport => $sth->fetchall_hashref('id'),
# 	$s411 = body_parameters->get('option1'),
#	s411 => $s411,
	};
};

post '/passport2' => sub {
my $s411 = body_parameters->get('option1');
print "s411=$s411\n";
 template 'passport2.tt', {

              $s411 = body_parameters->get('option1'),
        print "s411=$s411\n",
	};
};

get '/test22' => sub {
        template 'test22.tt', {
        };
};

get '/menu2' => sub {
        template 'menu2.tt', {
        };
};


our $schedules_max = ();

#arrangement_stops
get '/arrangement_stops' => sub {
my ($i, $j);
my @routes=();
our $schedules_max = ();
my @table = (); 
my $passport=();
my        $db  = connect_db();
	my $sql = 'select id, routes, routes_id, graphs, graphs_id, directions_id, preliminary_final_time from passport order by id desc';
   	my $sth = $db->prepare($sql) or die $db->errstr;
my         $rv = $sth->execute or die $sth->errstr;
my	   @passport = $sth->fetchrow_array;
my         $rc = $sth->finish; # освобождаем память
	
	$sql = 'select id, name from route_directions where id';
my      $ss = $db->prepare($sql) or die $db->errstr;
    	$ss->execute  or die $ss->errstr;
#--------------------------------------- Знаходження зупинок маршруту -----------------------------
=coment	$sql = 'select id, name from stations where id';
my      $s1 = $db->prepare($sql) or die $db->errstr;
        $s1->execute  or die $s1->errstr;


 print "Address: $passport[2]\n";

	$sql = "SELECT id, name, routes_id FROM graphs WHERE id"; # AND (name = $graph_writhe)");
my      $s2 = $db->prepare($sql) or die $db->errstr;
        $s2->execute  or die $s2->errstr;
	$sql = "SELECT id, graphs_id, histories_id FROM schedules WHERE id";
my      $s3 = $db->prepare($sql) or die $db->errstr;
        $s3->execute  or die $s3->errstr;
	$sql = 'SELECT id, schedules_id, time, flights_number, stations_id, pc_number FROM schedule_times WHERE id';
my      $s4 = $db->prepare($sql) or die $db->errstr;
        $s4->execute  or die $s4->errstr;
#	$sql = 'SELECT name, latitude, longitude FROM stations WHERE id';
#my      $s5 = $db->prepare($sql) or die $db->errstr;
#        $s5->execute  or die $s5->errstr;
#-------------------------------------- Закінчення і результат - формування масиву зупинок маршруту @table --------------------
        $sql = "select id, stations_id, pavilion, navis, lava, ekran from stations_equipment where id";
my      $s6 = $db->prepare($sql) or die $db->errstr;
        $s6->execute  or die $s6->errstr;

        $sql = "select * from entries where id";
my      $s7 = $db->prepare($sql) or die $db->errstr;
        $s7->execute  or die $s7->errstr;


my $dbh = DBI->connect('DBI:mysql:maklutsk', 'vizor', 'MBfhSg^4h5b%g3K'
                   ) || die "Could not connect to database: $DBI::errstr";
$dbh->{mysql_enable_utf8} = 1;
$dbh->do("SET NAMES 'utf8'");


$db  = connect_db();
 $sth =  $dbh->prepare("SELECT id, histories_id FROM schedules WHERE graphs_id =  ");
        $sth->execute();
        my $schedules = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$schedules} ) {
        for $j ( 0 .. $#{$schedules->[$i]} )  {
}
$schedules_max = $schedules->[$i][0];
}
print "id_schedules_max = $schedules_max \n";

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

}

	template 'arrangement_stops.tt', {
 		msg           => get_flash(),
		passport   => \@passport,
		route_directions => $ss->fetchall_hashref('id'),
#		stations => $s1->fetchall_hashref('id'),
#		graphs => $s2->fetchall_hashref('routes_id'),
#		schedules => $s3->fetchall_hashref('graphs_id'),
#		schedule__times => $s4->fetchall_hashref('id'),
#		stations => $s5->fetchall_hashref('id'),
#		stations_equipment => $s6->fetchall_hashref('id'),
#entri_es => $s7->fetchall_hashref('id'),
        };
=cut
};

post '/arrangement_stops' => sub {

	 print "ss: schedules__id\n";
#    	my $db  = connect_db();
#	my $sql = 'UPDATE passport SET schedules__id = ? WHERE id = 1';
#	my        $sth = $db->prepare($sql) or die $db->errstr;
#    	$sth->execute(
#        body_parameters->get('schedules__id'),
#    	) or die $sth->errstr;
#$sql = 'select id, routes, graphs from passport order by id desc';
#	 print "ss: schedules__id\n";
};



get '/' => sub {
    my $db  = connect_db();
    my $sql = 'select id, routes, graphs from passport order by id desc';
    my $sth = $db->prepare($sql)
            or die $db->errstr;
    $sth->execute
        or die $sth->errstr;
   template 'show_entries.tt', {
        msg           => get_flash(),
        passport => $sth->fetchall_hashref('id'),
    };
};


get '/synchronization' => sub {
@start = var 'foo';
	template 'synchronization.tt', {
		'start2' => \@start,
	};
};

get '/synchron' => sub {
	@start = var 'foo';
	        template 'synchron.tt', {
			'start2' => \@start,
	 };
};

my $content = ();
hook after_template_render => sub {
    my $ref_content = shift;
	$content     = ${$ref_content};
   @start => $content;
    };

get '/synch_ron' => sub {
       system('mysqldump -u vizor -pMBfhSg^4h5b%g3K  makom > /makom_backup.sql');           # копія БД з даними до синхронізації
	   my $db  = connect_db();

     my $sql = 'DELETE FROM graphs'; my $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'DELETE FROM dinners'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'DELETE FROM routes'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'DELETE FROM route_directions'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'DELETE FROM schedules'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'DELETE FROM schedule_times'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'DELETE FROM stations'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'DELETE FROM workshift'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;

#	$sql = 'DROP INDEX idx_routes ON routes'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;

        $sql = 'INSERT INTO makom.graphs SELECT * FROM maklutsk.graphs';
        $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'INSERT INTO makom.dinners SELECT * FROM maklutsk.dinners';
        $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'INSERT INTO makom.routes SELECT * FROM maklutsk.routes';
        $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'INSERT INTO makom.route_directions SELECT * FROM maklutsk.route_directions';
        $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'INSERT INTO makom.schedules SELECT * FROM maklutsk.schedules';
        $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'INSERT INTO makom.schedule_times SELECT * FROM maklutsk.schedule_times';
        $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'INSERT INTO makom.stations SELECT * FROM maklutsk.stations';
        $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'INSERT INTO makom.workshift SELECT * FROM maklutsk.workshift';
        $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;

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
$dbh->do("SET NAMES 'utf8'");
#--------- -------------- Маршрут id ------------------------------
$sth = $dbh->prepare("SELECT * FROM routes ORDER BY CAST(name AS SIGNED) ASC");
        $sth->execute();
        my $routes = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$routes} ) {
        for $j ( 0 .. $#{$routes->[$i]} )  {
        }
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
}
#--------- -------------- Назви (Номера) графіків ------------------------------
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

<div class="row g-0 text-center">
  <div class="col-sm-6 col-md-4">

<main class="d-flex flex-nowrap flex-nowrap">
  <h1 class="visually-hidden">Sidebars examples</h1>
<div class="b-example-divider b-example-vr"></div>
<div class="flex-shrink-0 p-3 bg-white" style="width: 140px;">
    <a href="/" class="d-flex align-items-center pb-3 mb-3 link-dark text-decoration-none border-bottom">
<!-- <img class="bi pe-none me-2" src="images/gear-wide.svg" alt="Bootstrap" width="16" height="16">-->
      <span class="fs-5 fw-semibold">Луцьк</span>
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
        if ($routes->[$i][0] == $graphs->[$x][2]){
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


  </body>
</html>
MET
close F2;
redirect '/';
	template 'synch_ron.tt', {
#                        'start2' => \@start,
	};
};

get '/page' => sub {
my $scalar = 'a';
my @list = ('b', 'c');
my %hash = (key => 'uuu');
sub code { scalar (localtime) }
my $object = 1;
my $parser =1;
	template 'page.tt', {
scalar  => $scalar,
list    => \@list,
hash    => \%hash,
code    => \&code,
cgi     => $object, # }  or die $parser->error,
	};
};

any ['get', 'post'] => '/login' => sub {
    my $err;
 
    if ( request->method() eq "POST" ) {

        if ( body_parameters->get('username') ne setting('username') ) {
            $err = "Недійсне ім’я користувача";
        }
        elsif ( body_parameters->get('password') ne setting('password') ) {
            $err = "Недійсний пароль";
        }
        else {
            session 'logged_in' => true;
            set_flash('Ви ввійшли в систему.');
            return redirect '/';
        }
   }
    template 'login.tt', {
       'err' => $err,
   };
 
};

get '/logout' => sub {
   app->destroy_session;
   set_flash('Ви вийшли з системи.');
   redirect '/';
};
 
true;
