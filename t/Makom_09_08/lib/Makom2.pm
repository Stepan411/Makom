package Makom;
use Dancer2;
use Dancer2::Plugin::Database;
use Dancer::Plugin::Database::Core::Handle;
binmode(STDOUT,':utf8');
use utf8;
use open qw(:utf8 :std);
use File::Slurper qw/ read_text /;


our $VERSION = '0.1';

#printf "template: %s\n", config->{'template'}; # simple
#printf "log: %s\n",      config->{'log'};      # undef
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

hook before_template_render => sub {
    my $tokens = shift;
 
    $tokens->{'css_url'} = request->base . 'css/style.css';
    $tokens->{'login_url'} = uri_for('/login');
    $tokens->{'logout_url'} = uri_for('/logout');
};

hook 'database_error' => sub {
    my $error = shift;
    die $error;
};

sub connect_db {
	my $mak_lutsk_dbh = database('mak_lutsk');
	return $mak_lutsk_dbh;
};


get '/' => sub {
#	my $dbh = database('mak_lutsk');
    my $sql = 'select id, title, text from entries order by id desc';
    my $sth = database->prepare($sql);
    $sth->execute;
    template 'show_entries.tt', {
        msg           => get_flash(),
        add_entry_url => uri_for('/add'),
        entries       => $sth->fetchall_hashref('id'),
    };
};

get '/myfile' => sub {
 	template 'myfile.tt', {
	 msg           => get_flash(),
        add_entry_url => uri_for('/add')
	};
};

post '/add' => sub {
    if ( not session('logged_in') ) {
        send_error("Not logged in", 401);
    }
 
    my $sql = 'insert into entries (title, text) values (?, ?)';
    my $sth = database->prepare($sql);
    $sth->execute(
        body_parameters->get('title'),
        body_parameters->get('text')
    );
 
    set_flash('Опубліковано новий запис');
    redirect '/';
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
