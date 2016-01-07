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


my %ROUTING = %MainController::PATHES;

#use Data::Dumper;
#print Dumper(%ROUTING);

    my $app = sub {
        my $env = shift;
     
        my $request = Plack::Request->new($env);
        my $route = $ROUTING{$request->path_info};
        if ($route) {
            return $route->($env);
        }
        return [
            '404',
            [ 'Content-Type' => 'text/html' ],
            [ '404 Not Found' ],
        ];
    };

builder {
        enable 'Debug', panels =>
          [ qw(Environment Response Timer Memory),
            [ 'DBITrace', level => 2 ]
          ]; 
    
    mount "/public" => Plack::App::File->new(root => "./public");
    mount "/img" => Plack::App::File->new(root => "./public/img");
    mount "/" => $app;
};
