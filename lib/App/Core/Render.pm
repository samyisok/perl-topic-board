package App::Core::Render;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../";
use Template;
use App::Config::Core;
use Encode;

sub render_template {
    my $tplname = shift;
    my $refhash = shift;
 
    my $config = App::Config::Core->new();
    my $html;
    my $parser = Template->new(INCLUDE_PATH => $config->get_tpldir(),
                               ENCODING => 'utf-8',);
    $parser->process( $tplname, $refhash, \$html);
    if ($parser) {
        return [
                    '200',
                    [ 'Content-Type' => 'text/html' ],
                    [ encode_utf8($html)],
                ]
    }
    else {
        return [
                    '504',
                    [ 'Content-Type' => 'text/html' ],
                    [ "504 Errno" ],
                ]
    }


}




1;
