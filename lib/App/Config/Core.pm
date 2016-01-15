package App::Config::Core;
use strict;
use warnings;
use FindBin;

sub new {
    my $class = shift;
    my $TPLDIR = "$FindBin::Bin/lib/App/Views";
    my $PUBLIC_DIR = "$FindBin::Bin/public/img";


    my $self = {
           dbpass => '123456',
           dbuser => 'root',
           dbpref => 'dbi:mysql:host=127.0.0.1;database=Webdb',
           save_pic_dir => $PUBLIC_DIR,
           tpldir => $TPLDIR,
           file_size => 1551755,
           file_type => {
                         'image/jpeg' => 'jpg',
                         'image/png' => 'png',
                         'image/gif' => 'gif',
                        },
           save_prefix => "prew_",
           username => "Anonymous",
       };
       bless $self, $class;
       return $self;
}

sub db_user {
    my $self = shift;
    return $self->{dbuser};
}

sub db_pass {
    my $self = shift;
    return $self->{dbpass};
}

sub db_pref {
    my $self = shift;
    return $self->{dbpref};
}


sub get_tpldir {
    my $self = shift;
    return $self->{tpldir};
}

sub get_save_pic_dir {
    my $self = shift;
    return $self->{save_pic_dir};
}


sub get_file_size {
    my $self = shift;
    return $self->{file_size};
}


sub get_save_prefix {
    my $self = shift;
    return $self->{save_prefix};
}
sub get_file_type {
    my $self = shift;
    return $self->{file_type};
}

sub get_username {
    my $self = shift;
    return $self->{username};
}


1;
