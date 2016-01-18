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
use App::Core::Auth;
use utf8;

BEGIN {
    our $router = Path::Router->new();

    $router->add_route('/:board/:topic_id'=> target => \&get_posts );
    $router->add_route('/:board' => target => \&get_topic_b );
    $router->add_route('/err' => target => \&get_error );
    $router->add_route('/' => target => \&get_main_page );
    $router->add_route('/auth' => target => \&get_auth );
    $router->add_route('/signout' => target => \&get_signout );
}

sub get_index{
       return App::Models::DBlogic::get_list_topics();
}

sub get_signout{
       my $env = shift;
       my $request = Plack::Request->new($env);
       my $cookies_data = App::Core::Auth::unpack_data($request->cookies->{'session_data'});
       my ($username) = @{$cookies_data};
       my $response = Plack::Response->new();
       $response->redirect("/auth");
       $response->cookies->{'session_data'} = {value => undef};
       App::Models::DBlogic::update_user_token($username, "");
       $response->finalize;
}

sub get_main_page {
       return App::Core::Render::render_template('main_page.html', {index=>get_index()});
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
      App::Models::DBlogic::create_post($vars->{'msg'}, @img_names, $topic_id, $vars->{'name'});
      my $response = Plack::Response->new();
      $response->redirect( "/" . $board . "/" . $topic_id);
      return $response->finalize;
   }
   #GET request     
   else {
       my $result = App::Models::DBlogic::get_posts($topic_id);
       return get_error unless @{$result};
       return App::Core::Render::render_template('posts.html', {posts => $result, topic_id => $topic_id, board => $board, index=>get_index()});
   }
}

sub get_error {
    return App::Core::Render::render_template('err.html');
}

sub get_auth {
   my $env = shift;
   my $request = Plack::Request->new($env);
   my $cookies = $request->cookies();
   if ($request->method() eq "POST"){
        my $vars = $request->body_parameters();
        use Data::Dumper;
        print Dumper($vars);
        my $login = $vars->{'login'};
        my $pass_hash = App::Core::Auth::generate_sha_hash($vars->{'password'});
        my $user_data = App::Models::DBlogic::get_user_by_hash($login, $pass_hash);
        my $login_time = time;
        if ($user_data) {
            my $response = Plack::Response->new( '200', 
                                                [ 'Content-Type' => 'text/html' ],
                                                [ 'Granted' ],);
            my $session_token = App::Core::Auth::generate_sha_hash($login . $pass_hash . $login_time);
            App::Models::DBlogic::update_user_token($login, $session_token, $login_time);
            my $role = $user_data->{'role'};
            $response->cookies->{'session_data'} = {
                                           value => App::Core::Auth::pack_data($login, $role, $session_token, $login_time),
                                                   };
            $response->finalize();
        }
        else {
            return get_error();
        }
    }
    else{
            my $cookies_data = App::Core::Auth::unpack_data($cookies->{'session_data'});
            use Data::Dumper;
            print Dumper(\$cookies_data);
            return App::Core::Render::render_template('auth.html', {
                    cookies => $cookies_data,
                    });
    }

}

sub get_topic_b {
    my $env = shift;
    my ($board) = @{ $env->{'plack.router.match.args'} };
    my $request = Plack::Request->new($env);
    if ($request->method() eq "POST"){
        my $vars = $request->body_parameters();
        my $uploads = $request->uploads();
        if ($uploads->{'filepic'} and App::Core::File::get_file_info($uploads->{'filepic'})){
            my @img_names = App::Core::File::save_file(App::Core::File::get_file_info($uploads->{'filepic'}));
            App::Models::DBlogic::create_topic_w_posts($vars->{'msg'}, @img_names, $board, $vars->{'name'});
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
            return App::Core::Render::render_template('topics.html', {topics => $result, index=>get_index() , board => { id => $board }});
    }
}


1;
