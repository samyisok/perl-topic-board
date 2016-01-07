package App::Core::File;
use strict;
use utf8;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../";

sub get_file_info {
    my $file_hash = shift;
    my $tempname = $file_hash->{'tempname'};
    my $file_size = $file_hash->{'size'};
    my $content_type = $file_hash->{'headers'}->{'content-type'};
    #print "OK CHECKFILE\n" if check_file($file_size,$content_type);   
    return ($tempname, $content_type) if check_file($file_size,$content_type);   
}

sub check_file {
    my $file_size = shift;
    my $file_type = shift;
    use App::Config::Core;
    use List::MoreUtils qw{any}; 
    my $config = App::Config::Core->new();
    return 1 if ($file_size <= $config->get_file_size 
                and any {$_ eq $file_type} keys %{$config->get_file_type} );
}

sub print_debug {
    use Data::Dumper;
    my $var = shift;
    print "XXXXXXXXXX\n";
    print Dumper($var);
    print "XXXXXXXXXX\n";

}

sub save_file {
    my $orig_file = shift;
    my $file_type = shift;
    my $config = App::Config::Core->new();
    my $file_name = generate_name($orig_file, $file_type);
    my $pre_file_name = $config->get_save_prefix() . $file_name;
    my $dest_file = $config->get_save_pic_dir . "/" . $file_name;
    my $dest_file_prev =  $config->get_save_pic_dir . "/". $config->get_save_prefix() . $file_name;
    create_preview($orig_file, $dest_file_prev);
    use File::Copy;
    move($orig_file, $dest_file);
    return ($file_name, $pre_file_name);
}

sub create_preview {
    my $file_path = shift;
    my $dest_path =  shift;
    use Image::Magick;
    my $img = Image::Magick->new();
    my $tmp;
    $tmp = $img->Read($file_path);
    $tmp = $img->AdaptiveResize(200);
    $tmp = $img->write($dest_path);

}

sub generate_name {
    my $file_path = shift;
    my $file_type = shift;
    open my $fh, "<", $file_path;
    my $file_content;
    while ( readline($fh) ) {
            $file_content .= $_;
        };
    use Digest::SHA1 qw(sha1_hex);
    use App::Config::Core;
    my $config = App::Config::Core->new();
    my $final_name = sha1_hex($file_content) . "." . ${$config->get_file_type}{$file_type};
    return $final_name;
}







1;
