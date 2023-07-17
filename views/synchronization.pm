#!/usr/bin/perl

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
system('mysqldump -u vizor -pMBfhSg^4h5b%g3K  makom > /makom_backup.sql');           # копія БД з даними до синхронізації

  	my $dbh = DBI->connect('DBI:mysql:makom', 'vizor', 'MBfhSg^4h5b%g3K'
                   ) || die "Could not connect to database: $DBI::errstr";
		$dbh->{mysql_enable_utf8} = 1;
		$dbh->do('set names "UTF8"');

			my $sth = $dbh->prepare("DELETE FROM graphs"); $sth->execute();
			$sth = $dbh->prepare("DELETE FROM dinners"); $sth->execute();
			$sth = $dbh->prepare("DELETE FROM routes"); $sth->execute();
			$sth = $dbh->prepare("DELETE FROM route_directions"); $sth->execute();
			$sth = $dbh->prepare("DELETE FROM schedules"); $sth->execute();
			$sth = $dbh->prepare("DELETE FROM schedule_times"); $sth->execute();
			$sth = $dbh->prepare("DELETE FROM stations"); $sth->execute();
			$sth = $dbh->prepare("DELETE FROM workshift"); $sth->execute();
			$sth = $dbh->prepare("DELETE FROM menu_routes_graphs"); $sth->execute();

			$sth = $dbh->prepare("TRUNCATE TABLE menu_routes_graphs"); $sth->execute();	# скидування AUTO_INCREMENT

			
			$sth = $dbh->prepare("DROP INDEX idx_routes ON routes"); $sth->execute();
			$sth = $dbh->prepare("DROP INDEX idx_graphs ON graphs"); $sth->execute();
			$sth = $dbh->prepare("DROP INDEX idx_menu_routes_graphs ON menu_routes_graphs"); $sth->execute();
#system('mysqldump -u vizor -pMBfhSg^4h5b%g3K  makom > /makom_backup_0.sql');	#	чисті таблиці
#--------- -------------- Копія з БД maklutsk -----------------------------
 	$sth = $dbh->prepare("INSERT INTO makom.routes SELECT * FROM maklutsk.routes");
	$sth->execute();
 	$sth = $dbh->prepare("INSERT INTO makom.graphs SELECT * FROM maklutsk.graphs");
	$sth->execute();
	$sth = $dbh->prepare("INSERT INTO makom.route_directions SELECT * FROM maklutsk.route_directions");
	$sth->execute();
	$sth = $dbh->prepare("INSERT INTO makom.dinners SELECT * FROM maklutsk.dinners");
	$sth->execute();
	$sth = $dbh->prepare("INSERT INTO makom.schedules SELECT * FROM maklutsk.schedules");
	$sth->execute();
	$sth = $dbh->prepare("INSERT INTO makom.schedule_times SELECT * FROM maklutsk.schedule_times");
	$sth->execute();
	$sth = $dbh->prepare("INSERT INTO makom.stations SELECT * FROM maklutsk.stations");
	$sth->execute();
	$sth = $dbh->prepare("INSERT INTO makom.workshift SELECT * FROM maklutsk.workshift");
	$sth->execute();

  	$sth = $dbh->prepare("CREATE INDEX idx_routes ON routes (name)");
        $sth->execute();
        $sth = $dbh->prepare("CREATE INDEX idx_graphs ON graphs (routes_id, name)");
        $sth->execute();

	$sth = $dbh->prepare("INSERT INTO menu_routes_graphs (transport_types_id, routes_id, name_routes) SELECT transport_types_id, id, name FROM routes");
        $sth->execute();  
	$sth = $dbh->prepare("SELECT menu_routes_graphs.graphs_id, menu_routes_graphs.name_graphs, graphs.id, graphs.name FROM menu_routes_graphs LEFT JOIN graphs ON menu_routes_graphs.routes_id = graphs.routes_id");


#        $sth = $dbh->prepare("INSERT INTO menu_routes_graphs (graphs_id, name_graphs) SELECT id, name FROM graphs WHERE graphs.routes_id");
        $sth->execute();

#UPDATE `table_name` SET `field_name` = replace (`field_name`,'from_str','to_str') WHERE `field_name` LIKE '%from_str%'
#SELECT  t1.c1, t1.c2, t2.c1, t2.c2 FROM    t1        LEFT JOIN    t2 ON t1.c1 = t2.c1;


        $sth = $dbh->prepare("CREATE INDEX idx_menu_routes_graphs ON menu_routes_graphs (transport_types_id, name_routes, name_graphs)");
        $sth->execute();

print "Vasja\n";
#--------- -------------- Графіки (ID графіка) ------------------------------
$sth->finish;
$dbh->disconnect;
__END__
