use strict;
use utf8;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Plack;
use Plack::Request;
use App::Controllers::MainController;
use Plack::Builder;
use Plack::Middleware::Static;
use Plack::Middleware::Debug;
use Plack::App::Path::Router::PSGI;

my $router = $MainController::router;




my $app = Plack::App::Path::Router::PSGI->new( router => $router );



builder {
        enable 'Debug', panels =>
          [ qw(Environment Response Timer Memory),
            [ 'DBITrace', level => 2 ]
          ]; 
    
    mount "/public" => Plack::App::File->new(root => "./public");
    mount "/img" => Plack::App::File->new(root => "./public/img");
    mount "/" => $app;
};
