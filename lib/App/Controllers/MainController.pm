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
use utf8;

our %PATHES = (
        '/posts' => \&get_posts,
        '/b' => \&get_topic_b,
        '/err' => \&get_error,
);

sub get_posts {
   my $env = shift;
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
      App::Models::DBlogic::create_post($vars->{'msg'}, @img_names);
      my $response = Plack::Response->new();
      $response->redirect("posts");
      return $response->finalize;
   }
   #GET request     
   else {
       my $result = App::Models::DBlogic::get_posts(); 
       return App::Core::Render::render_template('posts.html', {posts => $result});
   }
}

sub get_error {
    return App::Core::Render::render_template('err.html');
}

sub get_topic_b {
    my $env = shift;
    my $request = Plack::Request->new($env);
    if ($request->method() eq "POST"){
        use Data::Dumper;
        my $vars = $request->body_parameters();
        my $uploads = $request->uploads();
        if ($uploads->{'filepic'} and App::Core::File::get_file_info($uploads->{'filepic'})){
            my @img_names = App::Core::File::save_file(App::Core::File::get_file_info($uploads->{'filepic'}));
            App::Models::DBlogic::create_topic_w_posts($vars->{'msg'}, @img_names);
            my $response = Plack::Response->new();
            $response->redirect("/b");
            return $response->finalize;
        }
        else  {
                  my $response = Plack::Response->new();
                  $response->redirect("err");
                  return $response->finalize;
              }
    
    }
    else {
            my $result = App::Models::DBlogic::get_topics_w_posts();
            use Data::Dumper;
            print Dumper(\$result);
            return App::Core::Render::render_template('topics.html', {topics => $result});
    }
}
