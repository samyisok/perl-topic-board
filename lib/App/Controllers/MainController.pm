package MainController;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../";
use Plack;
use Plack::Request;
use Plack::Response;
use Template;
use App::Models::DBlogic;
use App::Core::Render;
use App::Core::File;
use Plack::App::Path::Router::PSGI;
use Path::Router;
use utf8;

#our %PATHES = (
#        '/posts' => \&get_posts,
#        '/b' => \&get_topic_b,
#        '/err' => \&get_error,
#);

BEGIN {
    our $router = Path::Router->new();

    $router->add_route('/:board/:topic_id'=> target => \&get_posts );
    $router->add_route('/:board' => target => \&get_topic_b );
    $router->add_route('/err' => target => \&get_error );
}



sub get_posts {
   my $env = shift;
   my ($board,$topic_id) = @{ $env->{'plack.router.match.args'} };
   my $request = Plack::Request->new($env);
   if ($request->method() eq "POST"){
      use Data::Dumper;
      my $vars = $request->body_parameters();
      my $uploads = $request->uploads();
      my @img_names = (undef, undef);
      if ($uploads->{'filepic'} and App::Core::File::get_file_info($uploads->{'filepic'}))
          {
              @img_names = App::Core::File::save_file(App::Core::File::get_file_info($uploads->{'filepic'}));
          }
      App::Models::DBlogic::create_post($vars->{'msg'}, @img_names, $topic_id);
      my $response = Plack::Response->new();
      $response->redirect( "/" . $board . "/" . $topic_id);
      return $response->finalize;
   }
   #GET request     
   else {
       my $result = App::Models::DBlogic::get_posts($topic_id);
       return get_error if $result;
       return App::Core::Render::render_template('posts.html', {posts => $result, topic_id => $topic_id, board => $board});
   }
}

sub get_error {
    return App::Core::Render::render_template('err.html');
}

sub get_topic_b {
    my $env = shift;
    my ($board) = @{ $env->{'plack.router.match.args'} };
    my $request = Plack::Request->new($env);
    if ($request->method() eq "POST"){
        use Data::Dumper;
        my $vars = $request->body_parameters();
        my $uploads = $request->uploads();
        if ($uploads->{'filepic'} and App::Core::File::get_file_info($uploads->{'filepic'})){
            my @img_names = App::Core::File::save_file(App::Core::File::get_file_info($uploads->{'filepic'}));
            App::Models::DBlogic::create_topic_w_posts($vars->{'msg'}, @img_names, $board);
            my $response = Plack::Response->new();
            $response->redirect("/" . $board);
            return $response->finalize;
        }
        else  {
                  my $response = Plack::Response->new();
                  $response->redirect("err");
                  return $response->finalize;
              }
    
    }
    else {
            my $result = App::Models::DBlogic::get_topics_w_posts($board);
            use Data::Dumper;
            print Dumper(\$result);
            return App::Core::Render::render_template('topics.html', {topics => $result, board => { id => $board }});
    }
}


1;
