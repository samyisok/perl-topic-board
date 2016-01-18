package App::Core::Auth;

use strict;
use utf8;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../";

sub generate_sha_hash {
  my $var = shift;
  use Digest::SHA1 qw(sha1_hex);
  use App::Config::Core;
  my $config = App::Config::Core->new();
  return sha1_hex($config->get_secret() . $var);
}

sub pack_data {
    return join(':', @_);
}

sub unpack_data {
    my $var = shift;
    my (@array) = split(':', $var);
    return \@array;
}

1;
