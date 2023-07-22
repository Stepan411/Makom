#!/usr/bin/env perl
package Makom;
use Dancer2;
use strict; # використовувати всі три стриктури 
#set serializer => 'JSON'; # Dancer2::Serializer::JSON
#use warnings;
#use POSIX qw(strftime);
#use Exporter;
#our (@EXPORT, @ISA); 
#ISA = qw(Exporter);
#EXPORT = qw($tabl);
use DBI;
use Log::Any::Adapter;
use Log::Any::Adapter::File;
Log::Any::Adapter->set('Fille', file => '/var/log/Dancer2.log');
use Dancer2::Plugin::Ajax;
use GIS::Distance;
#use JSON;
use Dancer2::Core::Error;
 $|++;		# встановити буферизацію команд 
    use Data::Dumper;
    use feature 'say';
use base qw( Template::Base );
binmode(STDOUT,':utf8');
use utf8;
use open qw(:utf8 :std);
use File::Slurper qw/ read_text /;
use feature qw(fc say);
use Excel::Writer::XLSX;
use CGI::Cookie;
use Time::Piece;
use Math::Geometry::Planar;
use Math::Trig;
#use Math::Interpolate qw(linear_interpolate);

#use POSIX qw(setlocale LC_TIME);

#setlocale(LC_TIME, "uk_UA.utf8"); # встановлюємо українську локаль

use Crypt::PasswdMD5;
use Dancer2::Plugin::CryptPassphrase;
use CGI qw(param);
use Template::Plugin::Table;
#use Template::Plugin::Filter;
my @table = ();
my @table_1 = ();
my $table = ();
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

get '/simulation' => sub {
	my $db     = connect_db();
	my $gis = GIS::Distance->new();
	my @track =();
	my @track_l =();
	my @trac_k_l =();
	my @hash = ();
	my $hash = ();
	my $line_stops = ();
	my @line_stops = ();
	my $lines_gis = ();
	my @lines_gis = ();
	my @lines = ();
	my $lines = ();
	my $line = ();
	my $i = ();
	my $j =();
	my @table =();
	my $schedules_max = ();
	my @schedules_max = ();
	my $graphs_name =();
	my @graphs_name =();
	my @graphs_id =();
	my $graphs_id =();
	my @graphs_max = ();
	my @diners = ();
	my $lat_stops = (); my $lon_stops = ();
	        my $sql = $db->prepare('select id, routes, routes_id, graphs, graphs_id, name_directions, radio_pzz from passport where id=1');
        $sql->execute or die $db->errstr;
        my @passport = $sql->fetchrow_array;
        $sql->finish;

		my $sth = $db->prepare("select id_station, name, lat, lng, IFNULL(radio_pzz, 0) AS radio_pzz from passport_stops_routes ORDER BY id"); $sth->execute();

while(my $row  = $sth  -> fetchrow_hashref) {
	$line_stops = $row;
	push (@line_stops, $line_stops );

	$hash = to_json($row, {utf8 => 0});
                        $hash =~ s/$/,/g;                       # в кінці стрічки ставить кому
                        push (@hash, $hash);
                        #       print "name: $row->{name} lat: $row->{lat} lng: $row->{lng} \n";
        		}
        my $pass_routes = $passport[1];
	my $pass_routes_id = $passport[2];
        my $pass_graphs = $passport[3];
        my $routes =();

my $dist_null_lat = 0;
my $dist_null_lon = 0;
my $distance_line = 0;
my $summ_points_line =0;
my $dist_summ = 0;
my $c = 0;
                $sth = $db->prepare("select id_line, lat, lng, radio_pzz, id_station, distance_stops, distance_line from users_line_route where id_routes = $pass_routes_id ORDER BY id_line"); $sth->execute();
        while( $line = $sth -> fetchrow_hashref) {
		my $lat_1  = $line->{'lat'}; my $lon_1  = $line->{'lng'}; my $id_line1  = $line->{'id_line'};
	if ($c != 0) {
 		$distance_line = $gis->distance( $dist_null_lat,$dist_null_lon => $lat_1, $lon_1 );	# Оприділення дистанції від 0 до N (останньої в рейсі)зупинки - довжина маршруту--------------
		#		print "direction_line: $distance_line, c= $c, $dist_null_lat, $dist_null_lon, $lat_1, $lon_1\n";
		$distance_line = $distance_line->meters();
	}
                $dist_null_lat = $lat_1;
                $dist_null_lon = $lon_1;
        $dist_summ = $dist_summ + $distance_line; 
$dist_summ = sprintf("%.2f", $dist_summ);
$line->{'distance_line'} = $dist_summ;
                $lines_gis = $line;
                push (@lines_gis, $lines_gis );
		#		$lines = to_json($line, {utf8 => 0});
		#push (@lines, $lines);

				#my $sth1 =  $db->prepare("UPDATE users_line_route SET distance_line = $dist_summ WHERE id_line = $id_line1"); $sth1->execute();
	$c++;
		};
     
    $summ_points_line += scalar keys @lines_gis;  # к-сть елементів у хеші
        if ( $summ_points_line == 0 ) {			# Коли не має лінії то видача повідомлення --------------------------------------
                                        set_flash("Трек для маршруту не побудований");
        }else{			
    # exit(1);
#----------------------------------- читаємо середню точку radio_pzz на лінії - для того щоб мати дві сторони маршрута - т.т. 2 рейси -------------------------------
	$sth = $db->prepare("SELECT id_line, lat, lng, radio_pzz  FROM users_line_route where (radio_pzz != 0) AND (id_routes = $pass_routes_id)"); $sth->execute();
		my @line_pzz = $sth->fetchrow_array();
#--------- -------------- Оприділення найближчої точки на треку маршруту до зупинки ------------------------------
my $lat1 = ();
my $lon1 = ();
my $lat2 = ();
my $lon2 = ();
my $lat22 = ();
my $lon22 = ();
my $distance = ();
my $distance1 = ();
my $distance2 = 0;
my $distance_min = ();
my @dist_min = ();
my @dist_m =();
my $dist_n =();
              my $prev_lat = ();
	      my $prev_lon = ();
	      my $prev1_lat;
              my $prev1_lon;
	      my $prev2_lat = ();
              my $prev2_lon = ();
my $x = ();
my $y = ();
my $dist_time = ();
my $point1 = ();
my $point2 = ();
my $t = ();
my $s = 0;
my $name2;
my $id_line2;
my $id_line;
my $const = 0;
my $distance_min_stops = 0;
my $direction_angle;
my $dis_line = 0;
                        my $lat3;
                        my $lon3;
			#open(my $fh, '>', 'output.txt') or die "Не вдалося відкрити файл: $!";
#------------------------------------опрриділяємо дистанцію від зупинки до найближчої точки на лінії для часової лінійки --------------------------------  
			#$sth =  $db->prepare("UPDATE users_line_route SET time = 0"); $sth->execute();
              $i=0;
for my $s (@line_stops ) {
                $distance_min = 0;
                $lat1  = $s->{'lat'}; $lon1 = $s->{'lng'}; $name2 = $s->{'name'};
                my $point3 = [$lat1, $lon1];
                $j = 0;
#------------------------- читаємо кут (напрямок) руху транспору на зупинці для оприділення + або - дистанцыъ (выддалы) зупинки до найближчоъ точки --------------------------
				my $id_point  = $s->{id_station};
				my $sth1 = $db->prepare("SELECT points_of_events_id FROM stations_scenario WHERE stations_id = $id_point AND routes_id  = $pass_routes_id ORDER BY id"); $sth1->execute();
                       		my $points  = $sth1->fetchrow_hashref;
				my $sth2 = $db->prepare("SELECT direction FROM points_of_events WHERE id = $points->{points_of_events_id}"); $sth2->execute();
                       		my $direction_a  = $sth2->fetchrow_hashref;
				#			print "direction_angle: $direction_a->{direction}\n";
		$direction_angle = $direction_a->{direction};

for my $t (@lines_gis ) {
	$lat2  = $t->{'lat'}; $lon2  = $t->{'lng'}; $id_line2 = $t->{'id_line'};
                        $distance = $gis->distance( $lat1,$lon1 => $lat2, $lon2 );
                        $distance1 = $distance->meters();
if ($j == 1) {
                        $distance_min = $distance->meters();
             }

if  (($i < $line_pzz[3]-1)  && ($id_line2 < $line_pzz[0]) ) {			# або один рейс $distance_min
                if ($distance_min >= $distance1) {
                                        $distance_min = $distance1;
                                        $id_line = $t->{'id_line'};
					$dis_line = $t->{'distance_line'};
                $lat22  = $t->{'lat'}; $lon22  = $t->{'lng'};
                        $prev_lat = $prev1_lat;
                        $prev_lon = $prev1_lon;
                        $lat3 = $lat1;
                        $lon3 = $lon1;
			#print $fh "1, i =$i, $j, id_l2=$id_line2, line_pzz[0]=$line_pzz[0], d_min1=$distance_min, $name2, route_pzz[3] =$line_pzz[3], $id_line, $lat22, $lon22\n";
                }
		#		open(my $fh, '>', 'output.txt') or die "Не вдалося відкрити файл: $!";
		#print $fh "1, i =$i, $j,id id_l2=$id_line2, d_min1=$distance_min, $name2, route_pzz[3] =$line_pzz[3]\n";
	}
if  (($i >= $line_pzz[3]-1)  && ($id_line2 >= $line_pzz[0])) {			 # або другий рейс $distance_min
                if ($distance_min >= $distance1) {
                                        $distance_min = $distance1;
                                        $id_line = $t->{'id_line'};
					$dis_line = $t->{'distance_line'};
                $lat22  = $t->{'lat'}; $lon22  = $t->{'lng'};
                        $prev_lat = $prev1_lat;					
                        $prev_lon = $prev1_lon;
			$lat3 = $lat1;
                        $lon3 = $lon1;
			#		print $fh "2, i =$i, $j, id_l2=$id_line2, line_pzz[0]=$line_pzz[0], d_min1=$distance_min, $name2, route_pzz[3] =$line_pzz[3], $id_line\n";

		}
		#		open(my $fh, '>', 'output.txt') or die "Не вдалося відкрити файл: $!";
		#		print $fh "2, i =$i, $j,id id_l2=$id_line2, id_l=$id_line, d_min1=$distance_min, $name2, id_line = $id_line, route_pzz[3] =$line_pzz[3]\n";

	}
		$prev2_lat = $prev1_lat;			# змінні -  щоб затримати змінні на цикл
                $prev2_lon = $prev1_lon;
                $prev1_lat = $lat2;
                $prev1_lon = $lon2;
		$j++;
	$t->{'distance_stops_two'} = 0;
	$t->{'distance_line_two'} = 0;
	$t->{'name'} = '';
	}
	#	close $fh;  # Закриття файлового дескриптора
	#	 print "3, i =$i, $j,id id_l2=$id_line2, id_l=$id_line, d_min1=$distance_min, $name2, id_line = $id_line, route_pzz[3] =$line_pzz[3]\n";
#---------------------------------------- оприділяємо кут вектора зупинки та найдлижчої точки для + або - часу часової лінійки (сторони світу) ------------------------                        
use constant PI => 3.14159265358979;

# calgary

$lat1 = $lat3;
$lon1 = $lon3;

# toronto

$lat2 = $lat22;
$lon2 = $lon22;

my $bearing = bearing($lat1, $lon1, $lat2, $lon2);
my $direction = direction($bearing);
 $direction_angle = $direction_angle - $bearing; 
 
 my $d = 0;
 if ($direction_angle > 90 ) { 
	 $d = sprintf("%.2f", $distance_min);
	 $d = '-'.$d;
} elsif ($direction_angle > -360 && $direction_angle < -180 ){
         $d = sprintf("%.2f", $distance_min);
         $d = '-'.$d;
} elsif ($direction_angle < 90){
         $d = sprintf("%.2f", $distance_min);
}
$t->{'distance_stops'} = $d;
$line_stops[$i]->{'distance_stops'} = $d;
$line_stops[$i]->{'distance_line'} = $dis_line;
$line_stops[$i]->{'id_line'} = $id_line;
#print "j =$j, $i, $line_stops[$i]->{'id_line'}, id_line= $id_line, $line_stops[$i]->{'distance_stops'}, dis_line=$dis_line\n";
#print "i= $i, bearing = $bearing,direction=  $direction, $name2, direction_angle = $direction_angle, d= $d, $distance_min \n";
#$sth =  $db->prepare("UPDATE users_line_route SET distance_stops = $d WHERE id_line = $id_line"); $sth->execute();
sub bearing {
    my ($lat1, $lon1, $lat2, $lon2) = map { ($_ * PI) / 180 } @_;
    my $d_lon = $lon2 - $lon1;

    my $y = sin($d_lon) * cos($lat2);
    my $x = cos($lat1) * sin($lat2)
            - sin($lat1)
            * cos($lat2) * cos($d_lon);

    my $rad = atan2($y, $x);
    my $deg = $rad * (180 / PI);

    return $deg < 0 ? $deg += 360 : $deg;
}
sub direction {
    my ($deg) = @_;

    my @directions = qw(
        Пн ПнПнС ПнС СхПн С СхСхПд СхПд ПдПдСх Пд ПдПдЗ ПдЗ ЗЗПд З ЗЗПн ЗПн ПнПнЗ Пн
    );

    my $calc = (($deg % 360) / 22.5) + .5;

    return $directions[$calc];
	}
#------------------------------------ завершення оприділення кута вектора напрямку (сторони світу)-----------------------------------------------------------------------------	
$i++;
}
#close $fh;  # Закриття файлового дескриптора

#------------------------------------ завершення опрриділення  дистанції від зупинки до найближчої точки на лінії для часової лінійки --------------------------------
#my $p=0;
#for my $i (@lines_gis ) {
#print "p=$p, id=$lines_gis[$p]->{'id_line'}, two=$lines_gis[$p]->{'distance_line_two'}, d_line = $lines_gis[$p]->{'distance_line'}, id_st=$lines_gis[$p]->{'id_station'}, name=$lines_gis[$p]->{'name'}\n";
#$p++;

#}
#say Dumper(@lines_gis);
#----------------- присвоюємо дані масиву @lines_gis - id_station та distance_stops найближчої віддалі ---------------------------------------- 
	my $k=0;
	my $p=0;
	#open(my $fh, '>', 'output.txt') or die "Не вдалося відкрити файл: $!";
	for my $s (@line_stops ) {
		#	print "k=$k, line_stops[$k] = $line_stops[$k]->{'id_line'}, $line_stops[$k]->{'distance_stops'}, $line_stops[$k]->{'name'}\n";
	$p = 0;
	if (defined $line_stops[$k]->{'id_line'}) {
			for my $t (@lines_gis ) {
				#print "k=$k, line_stops[$k] = $line_stops[$k]->{'id_line'}, $line_stops[$k]->{'distance_stops'}, $line_stops[$k]->{'name'}\n";
	$lines_gis[$p]->{'num_next_segment'} = 0; # поле для зберігання к-сті анімації
			if ($line_stops[$k]->{'id_line'} == $lines_gis[$p]->{'id_line'}) {
				$lines_gis[$p]->{'distance_stops'} = $line_stops[$k]->{'distance_stops'};
                                $lines_gis[$p]->{'id_station'} = $line_stops[$k]->{'id_station'};
                                $lines_gis[$p]->{'name'} = $line_stops[$k]->{'name'};

				my $f3 = [$line_stops[$k]->{'lat'}, $line_stops[$k]->{'lng'}];
				my $f1 = [$lines_gis[$p]->{'lat'}, $lines_gis[$p]->{'lng'}];
				my $f2 = [$lines_gis[$p+1]->{'lat'}, $lines_gis[$p+1]->{'lng'}];

				my $point_stops = PerpendicularFoot([$f1,$f2,$f3]);
			
				#	print "22 stops_idl=[$k] = $line_stops[$k]->{'id_line'}, gis_idl=$lines_gis[$p]->{'id_line'}, st_id=$line_stops[$k]->{'id_station'}, $line_stops[$k]->{'name'}, $lines_gis[$p]->{'name'}\n";

			if ($point_stops != 0){
				my ($lat_ps, $lng_ps) = @$point_stops;
				#	print "22line_stops[$k] = $line_stops[$k]->{'id_line'}, $line_stops[$k]->{'id_station'}, $line_stops[$k]->{'name'}, $lat_ps, $lng_ps\n";
			$lines_gis[$p]->{'point_stops_lat'} = $lat_ps;
			$lines_gis[$p]->{'point_stops_lng'} = $lng_ps;
			}else{
				if ($point_stops != 0){
					my ($lat_ps, $lng_ps) = @$point_stops;
					$f1 = [$lines_gis[$p-1]->{'lat'}, $lines_gis[$p-1]->{'lng'}];
					$point_stops = PerpendicularFoot([$f1,$f2,$f3]);
					($lat_ps, $lng_ps) = @$point_stops;
					$lines_gis[$p]->{'point_stops_lat'} = $lat_ps;
                        		$lines_gis[$p]->{'point_stops_lng'} = $lng_ps;
			 	}else{
					if ($point_stops != 0){
						my ($lat_ps, $lng_ps) = @$point_stops;
						$f1 = [$lines_gis[$p-1]->{'lat'}, $lines_gis[$p-1]->{'lng'}];
						$point_stops = PerpendicularFoot([$f1,$f2,$f3]);
	                                	($lat_ps, $lng_ps) = @$point_stops;
						$lines_gis[$p]->{'point_stops_lat'} = $lat_ps;
                                        	$lines_gis[$p]->{'point_stops_lng'} = $lng_ps;
					}else{
			 			$lines_gis[$p]->{'point_stops_lat'} = $line_stops[$k]->{'lat'};
                        			$lines_gis[$p]->{'point_stops_lng'} = $line_stops[$k]->{'lng'};
					}
				}
			}
				$lines_gis[$p]->{'distance_stops_two'} = $line_stops[$k+1]->{'distance_stops'};
				last;
			};
			#print "p=$p, id=$lines_gis[$p]->{'id_line'}, two=$lines_gis[$p]->{'distance_line_two'}, d_line = $lines_gis[$p]->{'distance_line'}, id_st=$lines_gis[$p]->{'id_station'}, name=$lines_gis[$p]->{'name'}\n";


			$p++;
		}	
$k++;
	}
}
#say Dumper(@lines_gis);
#$p=0;
#for my $m (@lines_gis ) {

#print "p=$p, id=$lines_gis[$p]->{'id_line'}, two=$lines_gis[$p]->{'distance_line_two'}, d_line = $lines_gis[$p]->{'distance_line'}, id_st=$lines_gis[$p]->{'id_station'}, name=$lines_gis[$p]->{'name'}\n";
#$p++;
#}
#say Dumper(@lines_gis);
        my $tr=0;
	#  my @track =();
for my $p (@lines_gis ) {
	#		print "$p->{'name'}\n";
	$track[$tr]->{'lat'} = $p->{'lat'};
	$track[$tr]->{'lng'} = $p->{'lng'};
	$track[$tr]->{'distance_line'} = $p->{'distance_line'};
	$track[$tr]->{'num_next_segment'} = 0;
	$track[$tr]->{'id'} = $tr;
	$track[$tr]->{'radio_pzz'} = $p->{'radio_pzz'};
	$track[$tr]->{'id_station'} = 0;
	$track[$tr]->{'distance_line_two'} = 0;
	$track[$tr]->{'name'} = '';
	if (defined $p->{'point_stops_lat'}){
	if ($p->{'distance_stops'} > 0) {
my $la_t = $track[$tr]->{'lat'};
my $lo_n = $track[$tr]->{'lng'};
my $distance_lin_e = $track[$tr]->{'distance_line'};
my $radio_pz_z = $track[$tr]->{'radio_pzz'};
my $id_statio_n = $track[$tr]->{'id_station'};
my $nam_e = $track[$tr]->{'name'};
my $distance_line_tw_o = $track[$tr]->{'distance_line_two'};

$track[$tr]->{'num_next_segment'} = 0;
$track[$tr]->{'id'} = $tr;
$track[$tr]->{'radio_pzz'} = 0;
$track[$tr]->{'lat'} = $p->{'point_stops_lat'};
$track[$tr]->{'lng'} = $p->{'point_stops_lng'};
$track[$tr]->{'id_station'} = $p->{'id_station'};
$track[$tr]->{'name'} = $p->{'name'};
$track[$tr]->{'distance_line_two'} = $p->{'distance_line_two'};
#print "5 = $tr, id $track[$tr]->{'id'}, $track[$tr]->{'distance_line'}, $p->{'distance_stops'}, $distance_lin_e, $track[$tr]->{'name'} \n";

#print "0= $tr, id $track[$tr]->{'id'}, $track[$tr]->{'distance_line_two'} \n";
$tr++;

	$track[$tr]->{'num_next_segment'} = 0;
	$track[$tr]->{'id'} = $tr;
 	$track[$tr]->{'lat'} = $la_t;
 	$track[$tr]->{'lng'} = $lo_n;
 	$track[$tr]->{'distance_line'} = $distance_lin_e + $p->{'distance_stops'};
 	$track[$tr]->{'radio_pzz'} = $radio_pz_z;
 	$track[$tr]->{'id_station'} = $id_statio_n;
	$track[$tr]->{'name'} = $nam_e;
	$track[$tr]->{'distance_line_two'} = 0;
	#	print "4 = $tr, id $track[$tr]->{'id'}, $track[$tr]->{'distance_line'}, $p->{'distance_stops'}, $distance_lin_e, $track[$tr]->{'name'} \n";
} else {

$tr++;
$track[$tr]->{'num_next_segment'} = 0;
$track[$tr]->{'id'} = $tr;
$track[$tr]->{'radio_pzz'} = 0;
$track[$tr]->{'lat'} = $p->{'point_stops_lat'};
$track[$tr]->{'lng'} = $p->{'point_stops_lng'};
$track[$tr]->{'id_station'} = $p->{'id_station'};
$track[$tr]->{'name'} = $p->{'name'};
$track[$tr]->{'distance_line_two'} = $p->{'distance_line_two'};

#$track[$tr]->{'distance_stops'} = $p->{'distance_stops'};
                $lat2  = $p->{'lat'}; $lon2 = $p->{'lng'}; $lat1 = $track[$tr]->{'lat'}; $lon1 = $track[$tr]->{'lng'};
                        $distance = $gis->distance( $lat1,$lon1 => $lat2,$lon2 );
                        $distance1 = $distance->meters();
			$distance1 = sprintf('%0.2f', $distance1);
			$track[$tr]->{'distance_line'}= $p->{'distance_line'} + $distance1;
			#		print "3 = $tr, id $track[$tr]->{'id'}, st=$track[$tr]->{'id_station'}, dis=$track[$tr]->{'distance_line'}, $p->{'name'}, $track[$tr]->{'distance_line_two'}, $track[$tr]->{'name'} \n";
		}
}
#print "2 = $tr, id $track[$tr]->{'id'}, $track[$tr]->{'lat'}, $track[$tr]->{'lng'}, dis=$track[$tr]->{'distance_line'} \n";
	$tr++;
}

	my $h=0;
	my @two;
for my $p (@track ) {
	if ($p->{'id_station'} != 0){
		$two[$h] = {distance_line_two => $p->{'distance_line_two'}, id_station => $p->{'id_station'}, distance_line => $p->{'distance_line'}, name => $p->{'name'}};
		$h++;
	}
}
for my $i (0 .. $#two-1) {
    		$two[$i]->{'distance_line_two'} = $two[$i+1]->{'distance_line'}
}

$p=0;
for my $i (0 .. $#track ) {
        for my $v (0 .. $#two ) {
        	if ($track[$i]->{'id_station'} == $two[$v]->{'id_station'}){
			$track[$i]->{'distance_line_two'} = $two[$v]->{'distance_line_two'};
		}
	}
}

	$i=0;
	$h=0;
for my $p (@track ) {
	# print "l = $i, id $p->{'id'}, id_st $p->{'id_station'}, dist_line $p->{'distance_line'}, two $p->{'distance_line_two'}\n";

$trac_k_l[$i] = { lat => $p->{lat}, lng => $p->{lng}, id_station => $p->{id_station}, name => $p->{name}, distance_line => $p->{distance_line}, distance_line_two => $p->{distance_line_two} }; 
        my $tre = to_json($trac_k_l[$i], {utf8 => 0});
	#         $hash =~ s/$/,/g;                       # в кінці стрічки ставить кому
                        push (@track_l, $tre);
			#		if ($p->{'id_station'} != 0){
			 
			#$two[$h] = {distance_line_two => $p->{'distance_line_two'}, id_station => $p->{'id_station'}, distance_line => $p->{'distance_line'}, name => $p->{'name'}};
			#		print "0 = $i, id_st $p->{'id_station'}, dist_line $p->{'distance_line'}, two $p->{'distance_line_two'}, $p->{name}\n";
								#$h++;
								#	print "0 = $i, id $p->{'id'}, id_st $p->{'id_station'}, dist_line $p->{'distance_line'}, two $p->{'distance_line_two'}, $p->{'name'}\n";
								$i++;
}

#say Dumper(@track_l);

=coment

for my $i (0 .. $#two-1) {
    $two[$i]->{'distance_line_two'} = $two[$i+1]->{'distance_line'};

    #   print "0 = $i,  id_st $two[$i]->{'id_station'}, dist_line $two[$i]->{'distance_line'}, two $two[$i]->{'distance_line_two'}, $two[$i]->{'name'}\n";

}
$p=0;
#for my $i (0.. $#lines_gis ) {

for my $i (0 .. $#track ) {
	for my $v (0 .. $#two ) {
	if ($track[$i]->{'id_station'} == $two[$v]->{'id_station'}){
$p++;
$track[$i]->{'distance_line_two'} = $two[$v]->{'distance_line_two'};
#print "0 = $i, $p,  id_st $track[$i]->{'id_station'}, $track[$i]->{'name'}\n";
#print "0 = $i, $p,  id_st $lines_gis[$i]->{'id_station'}, dist_line $lines_gis[$i]->{'distance_line'}, two $lines_gis[$i]->{'distance_line_two'}, $lines_gis[$i]->{'name'}\n";

#print "0 = $i, $p,  id_st $two[$v]->{'id_station'}, ds $two[$v]->{'distance_line'}, two $two[$v]->{'distance_line_two'},$two[$v]->{'name'},\n";
}
}
}
#	print "0 = $i,  id_st $h1->{'id_station'}, dist_line $h1->{'distance_line'}, two $h1->{'distance_line_two'}\n";
	say Dumper(@track_l);
	#say Dumper(@track);
#say Dumper(@line_stops);
coment
my @sorted_points = sort { $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] } @all_points;

for my $i (0 .. $#track ) {
        for my $v (0 .. $#two ) {
                if ($track[$i]->{'id_station'} == $two[$v]->{'id_station'}){
                        $track[$i]->{'distance_line_two'} = $two[$v]->{'distance_line_two'};
                }
        }
}

=cut
#--------- -------------- Маршрут id ------------------------------
#print "pass_routes $pass_routes, $pass_graphs\n";	
 $sth =  $db->prepare("SELECT id, transport_types_id, name FROM routes WHERE name = $pass_routes ");
        $sth->execute;
        $routes = $sth -> fetchall_arrayref
        or die "$sth-> errstr\n";
        for  $i ( 0 .. $#{$routes} ) {
        for  $j ( 0 .. $#{$routes->[$i]} )  {
		#print "routes=$routes->[$i][$j]\t";
}
#print "\n";
#print "Маршрут=$routes->[0][2] \n";
}
print "Маршрут=$routes->[0][2] \n";
my $graphs=()
;
#--------- -------------- Назви (Номера) графіків ------------------------------
	if ($pass_graphs eq 'All') {
$sth = $db->prepare("SELECT id, name FROM graphs WHERE routes_id = $routes->[0][0] ORDER BY id"); # AND (name = $graph_writhe)");
} else {
$sth = $db->prepare("SELECT id, name FROM graphs WHERE (routes_id = $routes->[0][0]) AND (name = $pass_graphs)");
}
        $sth->execute();
        $graphs = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$graphs} ) {
        for $j ( 0 .. $#{$graphs->[$i]} )  {
}
#print "Графік=$graphs->[$i][1], graphs->[$i][0]=$graphs->[$i][0] \n";
$graphs_id[$i] = $graphs->[$i][0];
$graphs_name[$i] = $graphs->[$i][1];
#say Dumper(@graphs_sum);
}
#my @shed_find = ();
#my @din_find = ();
#say Dumper($graphs);
        our $graf_sum=0;		# Цикл вибору графіків
for $graf_sum ( 0 .. $#{$graphs} ) {
	#my $distance = 0; my $distance_summ = 0; my $dist_s = 0;  # обнулення гео данних 

$sth = $db->prepare("SELECT id, histories_id FROM schedules WHERE (graphs_id = $graphs->[$graf_sum][0]) AND ($routes->[0][2])");
        $sth->execute();
        my $schedules = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$schedules} ) {
        for $j ( 0 .. $#{$schedules->[$i]} )  {
};
$schedules_max = $schedules->[$i][0];
#print "schedules->[$i][0]$schedules->[$i][0], $graphs->[$graf_sum][0]\n";
};
	my $shed = { schedules_max => $schedules_max, id => $graphs_id[$graf_sum], name => $graphs_name[$graf_sum] };
	my $sh = to_json($shed, {utf8 => 0});
		push (@schedules_max, $sh);

#----------------------------------------------- Обіди ----------------------
		
$sth = $db->prepare("SELECT workshift_id, schedules_id, flight_number, stations_id, pc_number, start_time, end_time, duration, elapsed_worktime FROM dinners WHERE schedules_id = $schedules_max");
        $sth->execute();
while( my $din = $sth -> fetchrow_hashref) {
	 my $diner = to_json($din, {utf8 => 0});
	push (@diners, $diner);
}
#--------- -------------- Графік руху - час в сек і ID зупинок------------------------------

$sth = $db->prepare("SELECT id, schedules_id, time, stations_id FROM schedule_times WHERE schedules_id = $schedules_max");
	$sth->execute();
 
while(my $tab  = $sth  -> fetchrow_hashref) {
                        my $table11 = to_json($tab, {utf8 => 0});
                        push (@table, $table11);
	 }
	 #			 	say Dumper(@table);
   	};

};
#----------------------------------------- Вибір часу оборотнього рейсу з двох рейсів (2 і 3) який найменший т.т. без обідів -----------------------------------------
#say Dumper(@table);
say Dumper(@schedules_max);
my @mas=();
my $lat=();
my $lon=();
our $stops_2  = 0;
our $stops_3  = 0;
my @stop_s =();
my @stop_s1 =();
my $sto_ps=();
my $smm_time_2 =0;
my $smm_time_3 =0;
my $x_i = 0;
$i=0;
	$sth = $db->prepare("SELECT stations_id, time, pc_number, flights_number FROM schedule_times WHERE schedules_id = ? AND flights_number IN (2, 3) ORDER BY id"); 
        $sth->execute($schedules_max);
        $sto_ps = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$sto_ps} ) {
        for $j ( 0 .. $#{$sto_ps->[$i]} )  {
	};
		#print "$i,$j,stan=$sto_ps->[$i][$j]\t";
	if ($sto_ps->[$i][3] == 2) {
		$x_i = $i;
		$smm_time_2 = $sto_ps->[$i][1] - $sto_ps->[0][1];
	}else{
		$smm_time_3 = $sto_ps->[$i][1] - $sto_ps->[$x_i+1][1];
		#print "$x_i,$smm_time_2, $smm_time_3\n";
	};
 	$sth = $db->prepare("SELECT name, latitude, longitude  FROM stations WHERE id = $sto_ps->[$i][0]");
        $sth->execute();
        my $row_ref = $sth -> fetchrow_arrayref
        or die "$sth -> errstr\n";
        $sto_ps->[$i][4] = $row_ref->[0];
(@mas) = split(//,$row_ref->[1], 3);          # перевід в Гугловську систему координат... розділення числа на три
        $lat = join("", $mas[0], $mas[1]);      # обеднання
        $lat = $mas[2]/60+$lat;                 # перевід
        $lat = sprintf('%06f', $lat);           # заокруглення до 6 знаків після коми
$sto_ps->[$i][2] = $lat;                         # запис координати в $table->[$i][6]
        $#mas = -1;                             # очищення масиву
        (@mas) = split(//,$row_ref->[2], 3);
        $lon = join("", $mas[0], $mas[1]);
        $lon = $mas[2]/60+$lon;
        $lon = sprintf('%06f', $lon);
$sto_ps->[$i][3] = $lon;
 $stops_2  = $sto_ps->[0][0];
	if ( $stops_2 == $sto_ps->[$i][0] ) {
 $stops_3++;
if ($stops_3 == 3) {     
	last
}
}
}
 print "ss,$x_i,$smm_time_2, $smm_time_3\n";
foreach my $i (0 .. $#{$sto_ps}) {
    if ($smm_time_2 <= $smm_time_3) {
	if ( $i <= $x_i) {
    	    $stop_s1[$i] = {
            station_id => $sto_ps->[$i][0],
            name       => $sto_ps->[$i][4],
            lat        => $sto_ps->[$i][2],
            lng        => $sto_ps->[$i][3],
            time       => $sto_ps->[$i][1]
        };
	my $st = to_json($stop_s1[$i], {utf8 => 0});
	push (@stop_s, $st);
	}
    } else {
        if ( $i > $x_i) {
	    $stop_s1[$i] = {
            station_id => $sto_ps->[$i][0],
            name       => $sto_ps->[$i][4],
            lat        => $sto_ps->[$i][2],
            lng        => $sto_ps->[$i][3],
            time       => $sto_ps->[$i][1]
        };
	my $st = to_json($stop_s1[$i], {utf8 => 0});
        push (@stop_s, $st);
    	}
    }
		}
		#	say Dumper(@stop_s);

        template 'simulation.tt', {
		msg      	=> get_flash(),
		passport        => \@passport,
		hash		=> \@hash,
		#		lines 		=> \@lines,
		lines_gis            => \@lines_gis, 		#@lines,
		table		=> \@table,
		track 		=> \@track,
		track_l		=> \@track_l,
		stop_s		=> \@stop_s,
		schedule_s 	=> \@schedules_max,
		diners		=> \@diners
		#		graphs 		=> \@graphs_max
	};

};

get '/simulation1' => sub {
        template 'simulation1.tt', {
        };

};


any ['get', 'post'] =>'/dangerous_areas' => sub {
	template 'dangerous_areas.tt', {
	};

};

any ['get', 'post'] =>'/general_indicators' => sub {
my $general_indicators = 0;
	my $db  = connect_db();
        my $sql = $db->prepare('select id, routes, name_directions, radio_pzz, general_indicators from passport where id=1');
        $sql->execute or die $db->errstr;
        my @passport = $sql->fetchrow_array;
        $sql->finish;
if ($passport[4] != 1 ) {
	redirect '/passport';
};

        $sql = $db->prepare('select id, long_route_dir, long_route_rev, flight_duration_dir, flight_duration_rev, bus_stations_dir, bus_stations_rev, control_points_dir, control_points_rev,
	       control_points, equipped_sites_dir, equipped_sites_rev from characteristics_route where id=1');
        $sql->execute or die $db->errstr;
        my @char_rout = $sql->fetchrow_array;
        $sql->finish;

	my $sth = $db->prepare("SELECT MAX(id) FROM passport_stops_routes");
	$sth->execute();
	my ($max_id) = $sth->fetchrow_array();

	$sth = $db->prepare("SELECT name FROM passport_stops_routes where id = $passport[3]");
        $sth->execute();
        my $equipped_sites_rev = $sth->fetchrow_array();

        $sth = $db->prepare("SELECT name FROM passport_stops_routes where id = 1");
        $sth->execute();
        my $equipped_sites_dir = $sth->fetchrow_array();

        $sth = $db->prepare("SELECT SUM(avto_stops) FROM passport_stops_routes where id < $passport[3]");
        $sth->execute();
        my ($sum_avto_stops_dir) = $sth->fetchrow_array();

	if ($sum_avto_stops_dir == 0) {
		$sum_avto_stops_dir = 'відсутні';
	};

        $sth = $db->prepare("SELECT SUM(avto_stops) FROM passport_stops_routes where id >= $passport[3]");
        $sth->execute();
        my ($sum_avto_stops_rev) = $sth->fetchrow_array();

        if ($sum_avto_stops_rev == 0) {
        	$sum_avto_stops_rev = 'відсутні';
        };

print"dir = $equipped_sites_dir, $equipped_sites_rev\n";

if ( request->method() eq "POST" ) {

		my $control_dir = body_parameters->get('control_points_dir');
		my $control_rev = body_parameters->get('control_points_rev');
		my $control = body_parameters->get('control_points');
	my $control_dir_n = $control_dir;
	my $control_rev_n = $control_rev;
	my $control_n = $control;

	my $control_dir_0 =  $control_dir_n  =~ tr/\200-\377/ /cs;		# підрахунок числа символів у рядку   - для оприділення чи вводили якісь символи в змінну
	my $control_rev_0 =  $control_rev_n  =~ tr/\200-\377/ /cs;
	my $control_0 =  $control_n  =~ tr/\200-\377/ /cs;


			if ($control_dir_0 == 0) {				# аналіз чи вводилися якісь символи, якщо НІ то зберігаємо старе значення в БД поле police
 				$control_dir = $char_rout[7];
			};
			if ($control_rev_0 == 0) {
                                $control_rev = $char_rout[8];
                        };
                        if ($control_0 == 0) {
                                $control = $char_rout[9];
                        };


		        unless (defined $control_dir) {                      # якщо $bus_dir не опиділено то зберігаємо старе значення в БД
                        	$control_dir = $char_rout[7];
                	};
			unless (defined $control_rev) {
                                $control_rev = $char_rout[8];
                        };
			unless (defined $control) {
                                $control = $char_rout[9];
                        };

print"dir2 = $control_dir, $control_rev , $control \n";


        $sth = $db->prepare("UPDATE characteristics_route SET bus_stations_dir = ?, bus_stations_rev = ?, control_points_dir = ?, control_points_rev = ?, control_points = ?, equipped_sites_dir = ?, equipped_sites_rev = ? WHERE id = 1");   #запис назви маршруту
        $sth->execute( $sum_avto_stops_dir, $sum_avto_stops_rev, $control_dir, $control_rev, $control, $equipped_sites_dir, $equipped_sites_rev );

	};
	template 'general_indicators.tt', {
		passport        => \@passport,
		char_rout       => \@char_rout,
		max_id	=>	$max_id,
		sum_avto_stops_dir	=> $sum_avto_stops_dir,
		sum_avto_stops_rev	=> $sum_avto_stops_rev,
		equipped_sites_rev	=> $equipped_sites_rev,
		equipped_sites_dir      => $equipped_sites_dir,
 	};

};

get '/chess' => sub {
	
	my $db  = connect_db();
        my $sql = $db->prepare('select id, routes, name_directions from passport where id=1');
        $sql->execute or die $db->errstr;
        my @passport = $sql->fetchrow_array;
        $sql->finish;

	my $sth = $db->prepare("select id_station, id, name, IFNULL(radio_pzz, 0) AS radio_pzz from passport_stops_routes where id order by id");
	$sth->execute or die $sth->errstr;

        template 'chess.tt', {
                passport        => \@passport,
                stops       => $sth->fetchall_hashref('id'),
        };
};

any ['get', 'post'] =>'/chess' => sub {
my $set_finish = 0;
if ( request->method() eq "POST" ) {
 my $db  = connect_db();

        my $sql = $db->prepare('select id, routes, name_directions from passport where id=1');
        $sql->execute or die $db->errstr;
        my @passport = $sql->fetchrow_array;
        $sql->finish;

        my $direct = body_parameters->get('val_select_direct');
        my $twisted = body_parameters->get('val_select_twisted');

	my $sth =  $db->prepare("UPDATE passport SET val_select_direct = ?, val_select_twisted = ? WHERE id = 1");
            $sth->execute( $direct, $twisted ) or die $db->errstr;
system('/root/Makom/views/chess');
system("mv -n /root/Makom/report_chess.xlsx /root/Makom/Report_Chess_$passport[1].xlsx");	# перейменування файла
system("cp /root/Makom/Report_Chess_$passport[1].xlsx /root/Makom/public/routes/");		# переписати/перезаписати (якщо є) файл
system("rm /root/Makom/Report_Chess_$passport[1].xlsx");						# знищити файл
	$set_finish = 1;
        template 'chess.tt', {
		passport        => \@passport,
		set_finish	=>  $set_finish,  
	};
	#	redirect '/';

	};
};

any ['get', 'post'] => '/title' => sub {

   	my $db  = connect_db();
my $set_finish = 0;

        my $sql = $db->prepare('select id, routes, name_directions from passport where id=1');
        $sql->execute or die $db->errstr;
        my @passport = $sql->fetchrow_array;
        $sql->finish; 

        $sql = $db->prepare('select id, police, organizer, number, route_type, regime, date, month_name from title where id=1');
        $sql->execute or die $db->errstr;
        my @title = $sql->fetchrow_array;
        $sql->finish;

	#	my $now = localtime;
	#	my $date_9 = $now->ymd;	# повертає дату у форматі yyyy-mm-dd
	#	my $time_9 = $now->hms;	# повертає час у форматі hh:mm:ss
	#	my $mon_9 = $now->fullmonth;

if ( request->method() eq "POST" ) {

	my $police = body_parameters->get('comment_police');
	my $organizer = body_parameters->get('comment_organizer');
	my $passport_number = body_parameters->get('passport_nomer');
	my $select_regime = body_parameters->get('val_select_regime');
	my $select_type = body_parameters->get('val_select_type');
	my $date_t = body_parameters->get('date');


	#	print "select_regime = $select_regime  \n";
	#print "date_t = $date_t  \n";


	my $str_pol = $police;
	my $str_organ = $organizer;
	my $str_pas   = $passport_number;
	my $date_time = $date_t;

	my $str_pol_0 =  $str_pol =~ tr/\200-\377/ /cs;		# підрахунок числа символів у рядку   - для оприділення чи вводили якісь символи в змінну $police	
	my $str_organ_0 =  $str_organ =~ tr/\200-\377/ /cs;
	my $str_pas_0 =  $str_pas =~ tr/\200-\377/ /cs;
	my $date_time_0 =  $date_time =~ tr/\200-\377/ /cs;
	# 			print "str_pol_0= $str_pol_0, str_organ_0= $str_organ_0, police_1= $police \n";

		if ($str_pol_0 == 0) {				# аналіз чи вводилися якісь символи, якщо НІ то зберігаємо старе значення в БД поле police
 			$police = $title[1];
		};

		if ($str_organ_0 == 0) {                        # аналіз чи вводилися якісь символи, якщо НІ то зберігаємо старе значення в БД поле $organizer
                        $organizer = $title[2];
                };

		if ($str_pas_0 == 0) {                        
                        $passport_number = $title[3];
                };

                if ($date_time_0 == 0) {
                        $date_t = $title[6];
                };


		unless (defined $police) {			# якщо $police не ориділено то зберігаємо старе значення в БД
        		$police = $title[1];
 		}

                unless (defined $organizer) {                      # якщо $organizer не ориділено то зберігаємо старе значення в БД
                        $organizer = $title[2];
                }

                unless (defined $passport_number) {                      
                        $passport_number = $title[3];
                }

		unless (defined $date_t) {                      # якщо $police не ориділено то зберігаємо старе значення в БД
                        $date_t = $title[6];
                }



        my $t = $date_t;
        my $date_obj = Time::Piece->strptime($t, "%Y-%m-%d");



        my $month_name = $date_obj->strftime("%B");

	#        print "month_name = $month_name, title[7] = $title[7]  \n"; # виведе "березень"
	#print "date_t999 = $date_t  \n";
	#print "month_name999 = $month_name  \n";
        my  $sth =  $db->prepare("UPDATE title SET police = ?, organizer = ?, number = ?, route_type = ?, regime = ?, date = ?, month_name = ? WHERE id = 1");
            $sth->execute($police, $organizer, $passport_number, $select_type, $select_regime, $date_t, $month_name ) or die $db->errstr;

	    #chmod +x /root/Makom/views/title_xlsl.pl;	    
system('/root/Makom/views/title_xlsl.pl');
system("cp /root/Makom/Title_$passport[1].xlsx /root/Makom/public/routes/");
system("rm /root/Makom/Title_$passport[1].xlsx");                                                # знищити файл
 $set_finish = 1;
 #print "set_finish = $set_finish  \n";

#	    redirect '/';
    }
        template 'title.tt', {
                passport        => \@passport,
                title           => \@title,
		select_regime	=> $title[5],
		select_type	=> $title[4],
		set_finish	=> $set_finish,
	};	

};

get '/edit_map' => sub {
	
	my %hash = ();
        my $hash = ();
        my @hash = ();
        my $line = ();
        my $lines = ();
        my @lines = ();
        my $i = 0;
        my $route_Lat_Lng = {};
	my $route_Lat_Lng_1 = {};

        my $db  = connect_db();
my $sth = $db->prepare("select name, lat, lng, radio_pzz from passport_stops_routes where id order by id"); $sth->execute();

while(my $row  = $sth  -> fetchrow_hashref) {
                	$hash = to_json($row, {utf8 => 0});
               		$hash =~ s/$/,/g;                       # в кінці стрічки ставить кому
               		push (@hash, $hash);
        		#       print "name: $row->{name} lat: $row->{lat} lng: $row->{lng} \n";
	}

my $sql = 'select routes_id from passport where id=1'; $sth = $db->prepare($sql) or die $db->errstr; my $rv = $sth->execute or die $sth->errstr;
	my @passport = $sth->fetchrow_array;
	my $rc = $sth->finish; # освобождаем память
	my $routes_id = $passport[0];

$sth = $db->prepare("select lat, lng from users_line_route where id_routes = $routes_id"); $sth->execute();

while( $line = $sth -> fetchrow_hashref) {
        		$lines = to_json($line, {utf8 => 0});
        		push (@lines, $lines);
			#			say Dumper(@lines);
			#			print "@lines\n";
	};

	template 'edit_map.tt', {
                hash     => \@hash,
                lines => \@lines,
        };
};


post '/edit_map' => sub {	
my $gis = GIS::Distance->new();
	my $route_Lat_Lng = {};
 	my $i = 0;
	my $id_request = 0;
	my $db  = connect_db();
	my $distance_min;	
	my $distance1;
	my $distance;
			my $sql = 'select routes_id, radio_pzz from passport where id=1'; my $sth = $db->prepare($sql) or die $db->errstr; my $rv = $sth->execute or die $sth->errstr;
        my @passport = $sth->fetchrow_array;
        my $rc = $sth->finish; # освобождаем память
        my $routes_id = $passport[0];
	my $radio_pzz = $passport[1];


	if ( request->method() eq "POST" ) {
	

my $info;
#if ( defined(body_parameters->get('info')) eq ('2') ) {
#$info = body_parameters->get('info');
#	        $info = request->body);
#print "bbbbbbbbbb  info $info->{'info'} \n";
 #if ( $info eq '2' ) {
 #       print "aaaaaaaaaaaaaaaa\n";
 #                      $sql = "DELETE FROM users_line_route WHERE id_routes = $routes_id";                             # знищення старої лінії (якщо є)
 #                      $sth = $db->prepare($sql) or die $db->errstr; $sth->execute() or die $sth->errstr;
			#       };


	      if ( defined(body_parameters->get('track_map')) eq ('1') ) {
		
		$id_request = 0;
		$i =0;
			
 			$sth = 'TRUNCATE TABLE users_line'; $sth = $db->prepare($sth); $sth->execute() or die $sth->errstr;
 				redirect '/';
		};
	if ($id_request == 0) {

			if ($id_request >= 1) {
				last;
			};

		$id_request++;

       	$route_Lat_Lng =  from_json( request->body );
			$sql = "DELETE FROM users_line_route WHERE id_routes = $routes_id";                             # знищення старої лінії (якщо є)
                	$sth = $db->prepare($sql) or die $db->errstr; $sth->execute() or die $sth->errstr;
unless(defined($route_Lat_Lng)) {
	redirect '/';
}	
		while ( defined($route_Lat_Lng->[$i] )) {
			#					 print "route_Lat_Lng[$i]-> $route_Lat_Lng->[$i]->{'lat'}, $route_Lat_Lng->[$i]->{'lng'}\n";
                        $sth =  $db->prepare("INSERT INTO users_line ( lat, lng ) VALUES ( ?, ? )");
                        $sth->execute( $route_Lat_Lng->[$i]->{'lat'}, $route_Lat_Lng->[$i]->{'lng'} ) or die $db->errstr;

		$i++;
          	}
                        $sql = "INSERT INTO users_line_route (id_routes, lat, lng) SELECT $routes_id, lat, lng FROM users_line";    # збереження лінії
                        $sth = $db->prepare($sql) or die $db->errstr; $sth->execute() or die $sth->errstr;
#--------------- збереження в лінії radio_pzz ---------------------------------------------
       			$sql = "select lat, lng from  passport_stops_routes where id = $radio_pzz"; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $sth->errstr;
		 	my @s_latlng = $sth->fetchrow_array;
			 $sth->finish;
		 	my $s_lat  = $s_latlng[0]; my $s_lon  = $s_latlng[1];
			#print "$s_lat, s_lon $s_lon\n";
		                $sth = $db->prepare("select id_line, lat, lng from users_line_route where id_routes = $passport[0]"); $sth->execute();

			       	my $lines_gis;
		       		my @lines_gis;	       
	while(my $line = $sth -> fetchrow_hashref) {
		$lines_gis = $line;
		push (@lines_gis, $lines_gis );
	}
			my $id_line;
			my $j = 0;
		for my $t (@lines_gis ) {
			my $lat2  = $t->{'lat'}; my $lon2  = $t->{'lng'};
			$distance = $gis->distance( $s_lat,$s_lon => $lat2,$lon2 );
                        $distance1 = $distance->meters();
 if ($j == 0) {
                        $distance_min = $distance->meters();

                }
	                        if ($distance_min >= $distance1) {
                			$distance_min = $distance1;
					$id_line = $t->{'id_line'};
					#	print "distance_min $distance_min id_line $id_line\n";
				}
$j++;	
}
		if ( defined($id_line )) {
		 $sth =  $db->prepare("UPDATE users_line_route SET radio_pzz = $radio_pzz WHERE id_line = $id_line"); $sth->execute();
	 };	
	 };
    };
};

any ['get', 'post'] => '/print_map' => sub {
        my %hash = ();
        my $hash = ();
        my @hash = ();
	my $line = ();
	my $lines = ();
	my @lines = ();
        my $i = 0;
        my $db  = connect_db();
	my $route_Lat_Lng = {};

my $dbh = DBI->connect('DBI:mysql:makom', 'vizor', 'MBfhSg^4h5b%g3K'
                   ) || die "Could not connect to database: $DBI::errstr";
                        $dbh->{mysql_enable_utf8} = 1;
                        $dbh->do("SET NAMES 'utf8'");

        my $sql = 'select routes_id from passport where id=1';
        	my $sth = $db->prepare($sql) or die $db->errstr; my $rv = $sth->execute or die $sth->errstr;
		my @passport = $sth->fetchrow_array;
		my $rc = $sth->finish; # освобождаем память
		my $routes_id = $passport[0];

			$sth =  $dbh->prepare("select id_station, name, lat, lng, IFNULL(radio_pzz, 0) AS radio_pzz from passport_stops_routes where id order by id"); $sth->execute();
		# $sth = my $dbh->prepare("select id_station, name, lat, lng from passport_stops_routes where id order by id"); $sth->execute();

        while(my $row  = $sth->fetchrow_hashref) {
				my $id_point  = $row->{id_station};
				my $sth1 = $dbh->prepare("SELECT points_of_events_id FROM stations_scenario WHERE stations_id = $id_point AND routes_id  = $routes_id ORDER BY id"); $sth1->execute();
                       		my $points  = $sth1->fetchrow_hashref;
		my $sth2 = $dbh->prepare("SELECT direction FROM points_of_events WHERE id = $points->{points_of_events_id}"); $sth2->execute();
                       		my $direction_angle  = $sth2->fetchrow_hashref;
			#print "direction_angle: $direction_angle->{direction}\n";
				$row->{'direction'} = $direction_angle->{direction};
			 		$hash = to_json($row, {utf8 => 0});     # {utf8 => 0, pretty => 1}); гарно видаэ на друк
                        	$hash =~ s/$/,/g;                       # в кінці стрічки ставить кому
                        	push (@hash, $hash);
			#print "id_station: $row->{id_station} name: $row->{name} lat: $row->{lat} lng: $row->{lng} radio_pzz: $row->{radio_pzz} direction = $row->{'direction'} \n";      
  	};
		$sth = $dbh->prepare("select lat, lng from users_line_route where id_routes = $routes_id"); $sth->execute();
	while( $line = $sth -> fetchrow_hashref) {
			$lines = to_json($line, {utf8 => 0}); 
 			push (@lines, $lines);
			#say Dumper(@lines);
	};
	if ( request->method() eq "POST" ) {
                	if ( defined(body_parameters->get('track_map')) eq ('1') ) {
                        	redirect '/';
			};
	};
			#my $session_user = session->read('user');
			#print "session_user = $session_user\n";
		template 'print_map.tt', {
			hash     => \@hash,
			lines => \@lines,
        	};
};

get '/track' => sub {
	template 'track.tt', {
 	 };
	#redirect '/';
};

get '/test_map_cluster' => sub {
         template 'test_map_cluster.tt', {
        };
#redirect '/';
};

ajax '/treck' => sub {

	my @messages = (
        'Boo! I betcha I scared you, ha-ha!',
        'A girl has no name, but she still has a list.',
        'Space, the final frontier.',
        '',
        '<h1>Really big text</h1>',
    );
    send_as JSON => { message => @messages[int(rand(5))] };

};

get '/menu' => sub {
	my $db  = connect_db();
    	my $sql = 'select id, routes, graphs from passport where id=1';
    	my $sth = $db->prepare($sql)
            or die $db->errstr;
    	$sth->execute
        or die $sth->errstr;

	$sql = 'UPDATE passport SET general_indicators = 0 WHERE id = 1';
        $sth = $db->prepare($sql)
            or die $db->errstr;
        $sth->execute
        or die $sth->errstr;
       		template 'menu.tt', {
        msg           => get_flash(),
        menu_add => uri_for('/menu/add'),
	#      passport => $sth->fetchall_hashref('id'),
        };
};

post '/menu' => sub {
    my $db  = connect_db();
    my $sql = 'UPDATE passport SET routes = ?, routes_id = ?, transport_types_id = ?, graphs = ?, graphs_id = ?, transport_types_id = ? WHERE id = 1';
    my $sth = $db->prepare($sql)
        or die $db->errstr;
    $sth->execute(
     my $a1 = body_parameters->get('routes'),
my $a2 =	body_parameters->get('routes_id'),
my $a3 =	body_parameters->get('transport_types_id'),
my $a4 =        body_parameters->get('graphs'),
my $a5 =	body_parameters->get('graphs_id'),
	body_parameters->get('val_select'),
    ) or die $sth->errstr;
    set_flash('Опубліковано новий запис');

    # print "a1=$a1,a2=$a2,a3=$a3,a4=$a4,a5=$a5\n";
       redirect '/arrangement_stops';
    # redirect '/';
};

any ['get', 'post'] => '/passport' => sub {
 	my $err;
	my $but_fil = 0; 
    	my $db  = connect_db();

	my $general_indicators =1;
	my  $sth =  $db->prepare("UPDATE passport SET general_indicators = ? WHERE id = 1");
	$sth->execute( $general_indicators ) or die $db->errstr;

        $sth = $db->prepare("select id_station, id, name, IFNULL(radio_pzz, 0) AS radio_pzz from passport_stops_routes where radio_pzz = 1");
	$sth->execute();
        my @stops_routes = $sth->fetchrow_array;
        $sth =  $db->prepare("UPDATE passport SET radio_pzz = ? WHERE id = 1");
        $sth->execute( $stops_routes[1] ) or die $db->errstr;
 	$sth->finish;

        $sth = $db->prepare('select id, routes, graphs from passport where id=1');
        $sth->execute  or die $sth->errstr;
	my @passport = $sth->fetchrow_array;
        $sth->finish; # освобождаем память

if ( request->method() eq "POST" ) {
	       	if (body_parameters->get('option1') eq setting(' Графік руху')) {
	set_flash("Графік руху не зкореговано!");
       	} elsif 
		( body_parameters->get('option2') eq setting(' Зачин'))  {
        set_flash("Зачин не зкореговано!");
        } elsif 
		( body_parameters->get('option3') eq setting(' Зупинки'))  {
        set_flash("Зупинки не зкореговано!");
        } elsif 
		( body_parameters->get('option4') eq setting(' Помічено зворотню зупинку'))  {
        set_flash("Не помічено зворотню зупинку!");
       	} else {

my      $ro_ute = $passport[1];
my      $gra_phs = $passport[2];
	
	$but_fil = 1;
 	set_flash('Створюємо паспорт...');
print "/root/Makom/Route_${ro_ute}_$gra_phs.xlsx\n";
system('/root/Makom/views/schedules.pl');
system("mv -n /root/Makom/Route_$ro_ute.xlsx /root/Makom/Route_${ro_ute}_$gra_phs.xlsx");	# перейменування файла
system("cp /root/Makom/Route_${ro_ute}_$gra_phs.xlsx /root/Makom/public/routes/");		# переписати/перезаписати (якщо є) файл
system("rm /root/Makom/Route_${ro_ute}_$gra_phs.xlsx");						# знищити файл

	set_flash('Паспорт маршруту створено!');
	$but_fil = 1;
#print "11ro_ute=$ro_ute\n";
	}
}
        template 'passport.tt', {
        	msg           => get_flash(),
		passport	=> \@passport,
		but_fil  => $but_fil,
        };
};

get '/ss77' => sub {
        template 'ss77.tt', {
        };
};

get '/react-bootstrap-table2' => sub {
        template 'react-bootstrap-table2.tt', {
        };
};


get '/arrangement' => sub {
	template 'arrangement.tt', {
	};
};


our $schedules_max = ();

any ['get', 'post'] => '/arrangement_stops' => sub {
our $i = 0;
our $j = 0;
my @routes=();
our $schedules_max = ();
our @table = (); 
my $passport=();
my @mass;
my $ceck_id = 0;
my $ceck_pavilion = 0;
my $name_directions = ();
my $name_dir = ();
my $pzz = 0;
my        $db  = connect_db();
	my $sql = 'select id, routes, routes_id, graphs, graphs_id, directions_id, preliminary_final_time, radio_pzz, transport_types_id from passport order by id desc';
   	my $sth = $db->prepare($sql) or die $db->errstr;
	my $rv = $sth->execute or die $sth->errstr;
	my @passport = $sth->fetchrow_array;
	my $rc = $sth->finish; # освобождаем память
	$pzz = $passport[7];
#--------- -------------- Назва маршруту ------------------------------
	$sql = $db->prepare("select id, name from route_directions where routes_id = $passport[2]");
        $sql->execute();

while( $name_directions = $sql -> fetchrow_hashref) {
				#print "id: $name_directions->{id} name: $name_directions->{name}  \n";
		$name_dir = $name_directions->{name};
}
	$sql = $db->prepare("UPDATE passport SET name_directions = ? WHERE id = 1");             # запис назви маршруту
        $sql->execute($name_dir);
print "passport[2]=$passport[2], passport[1]=$passport[1]\n";
#--------- -------------- Назви (Номера) графіків ------------------------------
my $dbh = DBI->connect('DBI:mysql:makom', 'vizor', 'MBfhSg^4h5b%g3K'
                   ) || die "Could not connect to database: $DBI::errstr";
$dbh->{mysql_enable_utf8} = 1;
$dbh->do("SET NAMES 'utf8'");
	$sth = $dbh->prepare("SELECT id, name FROM graphs WHERE routes_id = $passport[2]"); 
        $sth->execute();
        my $graphs = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$graphs} ) {
        for $j ( 0 .. $#{$graphs->[$i]} )  {
}
if ($graphs->[$i][1] == 2) {
last
}
}
print "Графік_2=$graphs->[0][1], graphs->[0][0]=$graphs->[0][0] \n";
#--------- -------------- Графіки (ID графіка) ------------------------------
	$sth = $dbh->prepare("SELECT id, histories_id FROM schedules WHERE graphs_id = $graphs->[0][0]");
        $sth->execute();
        my $schedules = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$schedules} ) {
        for $j ( 0 .. $#{$schedules->[$i]} )  {
	}
$schedules_max = $schedules->[$i][0];
#print "schedules_2->[$i][0]$schedules->[$i][0]\n";
}
#print "id_schedules_max = $schedules_max \n";
#--------- ??????????????????????
$sql = 'TRUNCATE TABLE passport_stops_routes'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
#--------- -------------- Вибір зупинок маршруту ------------------------------
my $suma_stops = 0;
our @mass_summ = ();
our @mass_summ_2 = ();
my $invent = 0;
our $stops_2  = 0;
our $stops_3  = 0;
our $ss2 = 0;
my @mas=();
my $lat=();
my $lon=();
	$sth = $dbh->prepare("SELECT stations_id, time, pc_number, flights_number FROM schedule_times WHERE schedules_id = $schedules_max AND flights_number = 2 ORDER BY pc_number"); 
        $sth->execute();
        my $table = $sth -> fetchall_arrayref
        or die "$sth -> errstr\n";
        for $i ( 0 .. $#{$table} ) {
        for $j ( 0 .. $#{$table->[$i]} )  {
#   print "tabls[$i][0]=$table->[$i][0], tabls[$i][1]=$table->[$i][1], tabls[$i][2]=$table->[$i][2], tabls[$i][3]=$table->[$i][3]  \n";
};
 	$sth = $dbh->prepare("SELECT name, latitude, longitude  FROM stations WHERE id = $table->[$i][0]");
        $sth->execute();
        my $row_ref = $sth -> fetchrow_arrayref
        or die "$sth -> errstr\n";
        $table->[$i][1] = $row_ref->[0];
(@mas) = split(//,$row_ref->[1], 3);          # перевід в Гугловську систему координат... розділення числа на три
        $lat = join("", $mas[0], $mas[1]);      # обеднання
        $lat = $mas[2]/60+$lat;                 # перевід
        $lat = sprintf('%06f', $lat);           # заокруглення до 6 знаків після коми
$table->[$i][2] = $lat;                         # запис координати в $table->[$i][6]
        $#mas = -1;                             # очищення масиву
        (@mas) = split(//,$row_ref->[2], 3);
        $lon = join("", $mas[0], $mas[1]);
        $lon = $mas[2]/60+$lon;
        $lon = sprintf('%06f', $lon);
$table->[$i][3] = $lon;
my $id_station_tabl = $table->[$i][0];
	$sth = $dbh->prepare("SELECT radio_pzz, avto_stops, pavilion, navis, lava, ekran  FROM stations_equipment WHERE id_station = $id_station_tabl");
#        $sth = $dbh->prepare("SELECT radio_pzz, avto_stops, pavilion, navis, lava, ekran  FROM stations_equipment_old WHERE id_station = $table->[$i][0]");
        $sth->execute();
        $invent = $sth -> fetchrow_arrayref
        or die "$sth -> errstr\n";
		unless (defined($invent->[0])) { $table->[$i][4] = 0;
	}else{ $table->[$i][4] = $invent->[0];
	};
                unless (defined($invent->[1])) { $table->[$i][5] = 0;
        }else{ $table->[$i][5] = $invent->[1];
        };
                unless (defined($invent->[2])) { $table->[$i][6] = 0;
        }else{ $table->[$i][6] = $invent->[2];
        };
                unless (defined($invent->[3])) { $table->[$i][7] = 0;
        }else{ $table->[$i][7] = $invent->[3];
        };
                unless (defined($invent->[4])) { $table->[$i][8] = 0;
        }else{ $table->[$i][8] = $invent->[4];
	};        
                unless (defined($invent->[5])) { $table->[$i][9] = 0;
        }else{ $table->[$i][9] = $invent->[5];
        };
 $stops_2  = $table->[0][0];
	if ( $stops_2 == $table->[$i][0] ) {
 $stops_3++;
if ($stops_3 == 2) {     
	last
}
}
#print "table->[$i][0]=$table->[$i][0], table->[$i][1]=$table->[$i][1], table->[$i][2]=$table->[$i][2], table->[$i][3]=$table->[$i][3], [$i][4]=$table->[$i][4], [$i][5]=$table->[$i][5], [$i][6]=$table->[$i][6]\n";

my @c = ();
my @a = ();
my $str = ();
my @str_2 = ();
#@a = ( $$table[$i][0], $$table[$i][1], $$table[$i][2], $$table[$i][3], $$table[$i][4], $$table[$i][5], $$table[$i][6] );

$sql = "INSERT INTO passport_stops_routes ( id_station, lat, lng, radio_pzz, avto_stops, pavilion, navis, lava, ekran, name ) VALUES ($$table[$i][0], $$table[$i][2], $$table[$i][3], $$table[$i][4], $$table[$i][5], $$table[$i][6], $$table[$i][7], $$table[$i][8], $$table[$i][9], (SELECT name FROM stations WHERE id = $table->[$i][0]))";
 $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
 # $sth->execute or warn("DBD::mysql::st execute failed: " . $sth->errstr);
        $sql = "select id_station, id, name, radio_pzz, avto_stops, pavilion, navis, lava, ekran from passport_stops_routes where id";
 $ss2 = $db->prepare($sql) or die $db->errstr; $ss2->execute  or die $ss2->errstr;
#------------------- Приклади ------------------------------------------------
#chomp(@a);
#$str =~ s/\n//s;              # замінює символи на пробіл і стискає
#$str =~ s/\r//s;
#$str = join(',',@a);
#@c = join(',',@c); 
#push(@mass_summ,@c);
#push(@mass_summ,':');

#$route_ss =~ s!]! !s;                  # Заміна
#$route_ss =~ s/^.{1}//;                        # Вилучення зпочатку стріччки 1 символа
#$route_ss =~ s/},/} /g;                        # Заміна
#@route_ss = split(/ /, $route_ss);     # з стрічки масив
#my $number = @route_ss-1;              # к-сть ел. в масиві
#----------------------------------------------------------------------------
$suma_stops++;
}
#print "suma_stops= $suma_stops \n";

my $str_stops = 0;
my $kol_real = ();
my $id_ss2 = ();
my $radio_pzz_ss2 = ();
my $avto_stops_ss2 = (); 
my $pavilion_ss2 = ();
my $navis_ss2 = ();
my $lava_ss2 =();
my $ekran_ss2 = ();
my $x= $kol_real;
if ( request->method() eq "POST" ) {
	 
		for $str_stops ( $str_stops .. $suma_stops ) {
#print "str_stops=$str_stops \n";
    	$sql = "UPDATE passport_stops_routes SET radio_pzz = ?, avto_stops = ?, pavilion = ?, navis = ?, lava= ?, ekran= ? WHERE id = $str_stops";
       	$sth = $db->prepare($sql)
       		or die $db->errstr;
   	$sth->execute(
		 $radio_pzz_ss2 = body_parameters->get("radio_pzz_$str_stops"),
		 $avto_stops_ss2 = body_parameters->get("avto_stops_$str_stops"),
		 $pavilion_ss2 = body_parameters->get("pavilion_$str_stops"),
		 $navis_ss2 = body_parameters->get("navis_$str_stops"),
		 $lava_ss2 = body_parameters->get("lava_$str_stops"),
		 $ekran_ss2 = body_parameters->get("ekran_$str_stops"),
	) or die $sth->errstr;
       set_flash("Супер");
}
#---------------------------------------------- Запис № PZZ ----------------------------------------
        $sth = $db->prepare("select id_station, id, name, IFNULL(radio_pzz, 0) AS radio_pzz from passport_stops_routes where radio_pzz = 1");
        $sth->execute();
        my @stops_routes = $sth->fetchrow_array;
	$sth->finish;

        $sth =  $db->prepare("UPDATE passport SET radio_pzz = ? WHERE id = 1");
            $sth->execute( $stops_routes[1] ) or die $db->errstr;
#--------------------------------------------------------------------------------------------------
        	if ( defined(body_parameters->get('id_pzz')) eq ('1') ) {
        	 	$sql = 'select radio_pzz from passport id';
        	 	$sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $sth->errstr;
        	 	($pzz) = $sth->fetchrow_array;
        			$sth->finish;
		if ($pzz == 0) {set_flash("Не призначено ПЗЗ - Перша Зворотня Зупинка")}else{redirect '/';}
        	}

        };
        template 'arrangement_stops.tt', {
 		msg      	=> get_flash(),
                passport   	=> \@passport,
		#                route_directions => $ss->fetchall_hashref('id'),
		ss2 		=> $ss2->fetchall_hashref('id'),
        	kol_real    	=>  $kol_real,
		mass_summ	=> \@mass_summ,
	};
};

get '/audit' => sub {
        my $db  = connect_db();
        my $sql = 'select radio_pzz from passport id';
        my $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $sth->errstr;
  	my ($pzz) = $sth->fetchrow_array;
	$sth->finish;
	#	redirect '/';
print "pzz=  $pzz\n";
		if ($pzz == 0) {set_flash("Не призначено ПЗЗ - Перша Зворотня Зупинка")}else{redirect '/';}
     	template 'audit.tt', {
        	msg           => get_flash(),
       };
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
        template 'synchronization.tt', {
	msg           => get_flash(),
        };
};

my $val_select1 = ();
post '/synchronization' => sub {
    my $db  = connect_db();
    my $sql = 'UPDATE passport SET synchron_type = ? WHERE id = 1';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute(
       		$val_select1 =	body_parameters->get('val_select'),
    ) or die $sth->errstr;
print "val_select1=$val_select1\n";
    		redirect '/synchron';
};

my $val_select_1 = ();
get '/synchron' => sub {
	        template 'synchron.tt', {
	 };
};

my $content = ();
hook after_template_render => sub {
    my $ref_content = shift;
	$content     = ${$ref_content};
   @start => $content;
    };

get '/synch_ron' => sub {
       system('mysqldump --user=vizor --password=MBfhSg^4h5b%g3K  makom > /makom_backup.sql');           # копія БД з даними до синхронізації
	   my $db  = connect_db();

     my $sql = 'DELETE FROM graphs'; my $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'DELETE FROM dinners'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'DELETE FROM routes'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'DELETE FROM route_directions'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'DELETE FROM schedules'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'DELETE FROM schedule_times'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'DELETE FROM stations'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'DELETE FROM workshift'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
	$sql = 'DELETE FROM stations_scenario'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
	$sql = 'DELETE FROM points_of_events'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;

	$sql = 'TRUNCATE TABLE stations_equipment_copy'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;


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
        $sql = 'INSERT INTO makom.stations_scenario SELECT * FROM maklutsk.stations_scenario';
        $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;        
	$sql = 'INSERT INTO makom.points_of_events SELECT * FROM maklutsk.points_of_events';
        $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;

	$sql = 'INSERT INTO stations_equipment_copy SELECT * FROM stations_equipment'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;

#--------------------------------------------------------------------------------------------------- 
         $sql = 'select id, synchron_type from passport where id=1';
         $sth = $db->prepare($sql)
            or die $db->errstr;

my         $rv = $sth->execute or die $sth->errstr;
my         @passport = $sth->fetchrow_array;
my         $rc = $sth->finish; # освобождаем память
#print "passport[1]=$passport[1]\n";
#print "passport=$passport[1]\n";
if ($passport[1] eq 2) {
#print "passport[0]2=$passport[1]\n";
        $sql = 'TRUNCATE TABLE stations_equipment'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = 'INSERT INTO stations_equipment (id_station, name_station, latitude, longitude) SELECT id, name, latitude, longitude  FROM stations';
        $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
	#print "passport22[1]=$passport[1]\n";

};
#----------------------------------------------------------------------------------------------------
        $sql = $db->prepare('select preliminary_final_time from passport where id=1');
        $sql->execute or die $db->errstr;
        my ($passport) = $sql->fetchrow_array;
        $sql->finish;
	$sql = 'DELETE FROM passport'; $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;
        $sql = "INSERT INTO passport (id, routes, graphs, preliminary_final_time) VALUES (1, 0, 'X', $passport)";
        $sth = $db->prepare($sql) or die $db->errstr; $sth->execute or die $db->errstr;

our @routes=();
our @graphs=();
my $rout_writhe = 30;
our @media=();
my $str = 0;
our $id_menu = 'id_menu';
our ($i, $j, $x, $y, @na, $elem, $fi1);

my $dbh = DBI->connect('DBI:mysql:makom', 'vizor', 'MBfhSg^4h5b%g3K'
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
$sth = $dbh->prepare("SELECT * FROM graphs ORDER BY id");
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
truncate(F2, 0);
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


if ($routes->[$i][1] == 1){
	#print "routes->[$i][0]=$routes->[$i][0], routes->[$i][1]=$routes->[$i][1],routes->[$i][2]=$routes->[$i][2],routes->[$i][3]=$routes->[$i][3],\n";
print F2<<MET;       
<li class="mb-1">
        <button onclick = "checkAttr_$routes->[$i][4]()" class="btn btn-toggle d-inline-flex align-items-center rounded border-0 collapsed" data-bs-toggle="collapse" data-bs-target="#$id_menu-collapse" aria-expanded="false">
          $routes->[$i][4]
        </button>
<script>
function checkAttr_$routes->[$i][4]() {
document.getElementById('routes').value = $routes->[$i][4]
document.getElementById('routes_id').value = $routes->[$i][0]
document.getElementById('transport_types_id').value = $routes->[$i][1]
document.getElementById('graphs').value = 'All'
}
</script>
MET
}
if ($routes->[$i][1] == 1){
print F2<<MET;
        <div class="collapse" id="$id_menu-collapse">
          <ul class="btn-toggle-nav list-unstyled fw-normal pb-1 small">
MET
}
        for $x ( 0 .. $#{$graphs} ) {
        for $y ( 0 .. $#{$graphs->[$x]} ) {
        }
        if ($routes->[$i][0] == $graphs->[$x][2] && $routes->[$i][1] == 1){
print F2<<MET;
            <li><a href="#" onclick = "checkAttr_$routes->[$i][4]_$graphs->[$x][1]()" class="link-dark d-inline-flex text-decoration-none rounded">$graphs->[$x][1]</a></li>
<script>
function checkAttr_$routes->[$i][4]_$graphs->[$x][1]() {
document.getElementById('routes').value = $routes->[$i][4]
document.getElementById('routes_id').value = $routes->[$i][0]
document.getElementById('transport_types_id').value = $routes->[$i][1]
document.getElementById('graphs').value = $graphs->[$x][1]
document.getElementById('graphs_id').value = $graphs->[$x][0]
}
</script>
MET

}
}
if ($routes->[$i][1] == 1){
print F2<<MET;
          </ul>
        </div>
      </li>
MET
}
}


print F2<<MET;
    </div>
   </ul>
 </div>


<div class="flex-shrink-0 p-3 bg-white" style="width: 140px;">
    <a href="/" class="d-flex align-items-center pb-3 mb-3 link-dark text-decoration-none border-bottom">
<!-- <img class="bi pe-none me-2" src="images/gear-wide.svg" alt="Bootstrap" width="16" height="16">-->
      <span class="fs-5 fw-semibold">Тролейбуси</span>
    </a>
<div class="prokrutka shadow p-3 mb-5 bg-body rounded">
    <ul class="list-unstyled ps-0">
MET
 for $i ( 0 .. $#{$routes} ) {
        for $j ( 0 .. $#{$routes->[$i]} )  {
        }
$str = $routes->[$i][4].$routes->[$i][1];
$id_menu = 'id_menu'."$str";

if ($routes->[$i][1] == 2){

print F2<<MET
<li class="mb-1">
	<button onclick = "checkAttr_$routes->[$i][1]_$routes->[$i][4]()" class="btn btn-toggle d-inline-flex align-items-center rounded border-0 collapsed" data-bs-toggle="collapse" data-bs-target="#$id_menu-collapse" aria-expanded="false">
          $routes->[$i][4]
        </button>
<script>
function checkAttr_$routes->[$i][1]_$routes->[$i][4]() {
document.getElementById('routes').value = $routes->[$i][4]
document.getElementById('routes_id').value = $routes->[$i][0]
document.getElementById('transport_types_id').value = $routes->[$i][1]
document.getElementById('graphs').value = 'All'
}
</script>
MET
}
if ($routes->[$i][1] == 2){
print F2<<MET;
<div class="collapse" id="$id_menu-collapse">
          <ul class="btn-toggle-nav list-unstyled fw-normal pb-1 small">
MET
}
        for $x ( 0 .. $#{$graphs} ) {
        for $y ( 0 .. $#{$graphs->[$x]} ) {
        }
        if ($routes->[$i][0] == $graphs->[$x][2] && $routes->[$i][1] == 2){
print F2<<MET;
            <li><a href="#" onclick = "checkAttr_$routes->[$i][1]_$routes->[$i][4]_$graphs->[$x][1]()" class="link-dark d-inline-flex text-decoration-none rounded">$graphs->[$x][1]</a></li>
<script>
function checkAttr_$routes->[$i][1]_$routes->[$i][4]_$graphs->[$x][1]() {
document.getElementById('routes').value = $routes->[$i][4]
document.getElementById('routes_id').value = $routes->[$i][0]
document.getElementById('transport_types_id').value = $routes->[$i][1]
document.getElementById('graphs').value = $graphs->[$x][1]
document.getElementById('graphs_id').value = $graphs->[$x][0]
}
</script>
MET
}
}
if ($routes->[$i][1] == 2){
print F2<<MET;
          </ul>
        </div>
      </li>
MET
}
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
                <P><input type="text" id="routes" size="10" name=routes readonly></P>
		<input type="hidden" id="transport_types_id" name=transport_types_id>
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
                <P><input type="text" id="graphs" size="10" name=graphs readonly></P>
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
                        <a href="/" class="btn btn-outline-primary">Вихід</a>
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
redirect '/menu';
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
	my $news_password = 0;
	my $db  = connect_db();
if ( request->method() eq "POST" ) {

	my $user = body_parameters->get('username');
	my $pass_word = body_parameters->get('password');

	my $salt = 'garlic';                                               # сіль - слово - garlic (часник) - для шифрації
	my $cryptedpassword = unix_md5_crypt($pass_word, $salt);
					#print "ВВ user = $user, pass_word = $pass_word\n";
        	my $sth =  $db->prepare("select name, pass, role from users where name LIKE ?");
              		$sth->execute("%$user%");
		my @login = $sth->fetchrow_array;

		my $user_name = $login[0];
		my $password = $login[1];
		my $role = $login[2];

					#print "БД user_name = $user_name, password = $password\n";

if ( body_parameters->get('username') ne $user_name ) {
	            	$err = "Недійсне ім’я користувача";
        	}
        	elsif ($cryptedpassword ne $password ) {
			$err = "Недійсний пароль";
        	}
        	else {
            	session 'logged_in' => true;
		#set_flash('Ви ввійшли в систему.');
print "Content-type: text/html; charset=windows-1251\n\n"; 	# відравляємо заголовок броузеру і отрмуємо Cookies користувача

		  my $c1 = new CGI::Cookie(			# оприділяємо і записуємо в с1 ы....   , і більше нічого не робимо :) з Cookies  
		        	-name => "superrr",
	         	       	-expires => "+1y",
	    	    		-secure  =>  1,
	                	-value => {
	                             username => $user_name,
	                             cryptedpassword => $cryptedpassword
	                          }
	            );
		    #   print header(-cookie=>$c1);


	my $now = localtime;
	my $date = $now->ymd;	# повертає дату у форматі yyyy-mm-dd
	my $time = $now->hms;	# повертає час у форматі hh:mm:ss

	my $hash = session;					# оприділяємо і записуємо в $hash дані сесії
		session user => $user_name;
		session ip_address => request->env->{'REMOTE_ADDR'};
		session date => $date;
		session time => $time;
		session host => request->host();
		#		say Dumper($hash);

	
					#print "news_password = $news_password, user_name = $user_name, role = $role, 'ss_superadmin'\n";

	
		my $session_id = session->id;
      		my $session_user = session->read('user');
      		my $session_ip = session->read('ip_address');
		my $session_host = session->read('host');
					#print "$session_id, $session_user, $session_ip, $session_host\n";
          $sth =  $db->prepare("INSERT INTO session (session, user, ip, host) VALUES (?, ?, ?, ?)");
          $sth->execute($session_id, $session_user, $session_ip, $session_host ) or die $db->errstr;

if ( $role eq 'ss_superadmin' ) {                       # вход на сторінку реєстрації новоо користувача
                redirect '/register';

		};

	return redirect '/';
        };
   };
    	template 'login.tt', {
		'err' => $err,
		#             	msg           => get_flash(),
	};
 
};

get '/register' => sub {

	my $db  = connect_db();
	my $sql = $db->prepare('select id, preliminary_final_time from passport where id=1');
	$sql->execute or die $db->errstr;
	my @passport = $sql->fetchrow_array;
        $sql->finish;

    template 'register.tt', { 
        	passport	=> \@passport,
	};
};

post '/register' => sub {
	my $err;
	my $db  = connect_db();

    my $username = body_parameters->get('username');
    my $password = body_parameters->get('password');
    my $confirm_password = body_parameters->get('confirm_password');
    my $val_select = body_parameters->get('val_select');
    my $preliminary_final_time = body_parameters->get('preliminary_final_time');	

if ($val_select == 1) {
    		$val_select = 'superadmin';
	}elsif ($val_select == 2) {
		$val_select = 'admin';
        }elsif ($val_select == 3) {
                $val_select = 'user';
	};

                my $sth =  $db->prepare("select name, pass, role from users where name LIKE ?");
                        $sth->execute("%$username%");
                my @login = $sth->fetchrow_array;

        my $user_name = $login[0];
	if (defined $user_name) {
                return template 'register', {
                 err => "Логін існує в системі"
         };
    };


    #print "val_select = $val_select, username = $username, password = $password, confirm_password = $confirm_password \n";

 if ($password ne $confirm_password) {
	return template 'register', {
		 err => "Паролі не збігаються"
	 };
    };
        my $now = localtime;
        my $datetime = $now->datetime;   # повертає дату і час
        my $date = $now->ymd;   # повертає дату у форматі yyyy-mm-dd
        my $time = $now->hms;   # повертає час у форматі hh:mm:ss

	my $sql = $db->prepare('select id, preliminary_final_time from passport where id=1');
        $sql->execute or die $db->errstr;
        my @passport = $sql->fetchrow_array;
        $sql->finish;


my $preliminary_final_t = $preliminary_final_time;
my $preliminary_final_t_0 = $preliminary_final_t =~ tr/\200-\377/ /cs;
                if ($preliminary_final_t_0 == 0) {
                        $preliminary_final_time = $passport[1];
                };
		                unless (defined $preliminary_final_time) {                      # якщо $police не ориділено то зберігаємо старе значення в БД
                        $preliminary_final_time = $passport[1];
                };

        $sth =  $db->prepare("UPDATE passport SET preliminary_final_time = ? WHERE id = 1");
            $sth->execute( $preliminary_final_time ) or die $db->errstr;

my ($salt, $cryptedpassword);
$salt = 'garlic';						# сіль - слово - garlic (часник) - для шифрації
$cryptedpassword = unix_md5_crypt($password, $salt);
#print "cryptedpassword = $cryptedpassword  \n";
		$sth = $sth =  $db->prepare("INSERT INTO users (name, pass, role) VALUES (?, ?, ?)");
		$sth->execute($username, $cryptedpassword, $val_select) or die $db->errstr;

	redirect '/logout';
};


get '/logout' => sub {

     print "v=1\n";
	app->destroy_session;
   set_flash('Ви вийшли з системи.');
   redirect '/';
};
 
true;
