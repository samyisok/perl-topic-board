use utf8;
package App::Models::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

App::Models::Schema::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 password

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 email

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 1
  size: 32

=head2 role

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 token_session

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 login_time

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "username",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "password",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "email",
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 32 },
  "role",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "token_session",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "login_time",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-01-18 19:08:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ejUYvrPkw5REHDJnPmwjDA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
