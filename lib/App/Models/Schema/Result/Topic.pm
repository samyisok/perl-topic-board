use utf8;
package App::Models::Schema::Result::Topic;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

App::Models::Schema::Result::Topic

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<topics>

=cut

__PACKAGE__->table("topics");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 dest

  data_type: 'char'
  is_nullable: 1
  size: 11

=head2 op_post_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "dest",
  { data_type => "char", is_nullable => 1, size => 11 },
  "op_post_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 messages

Type: has_many

Related object: L<App::Models::Schema::Result::Message>

=cut

__PACKAGE__->has_many(
  "messages",
  "App::Models::Schema::Result::Message",
  { "foreign.topic_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 op_post

Type: belongs_to

Related object: L<App::Models::Schema::Result::Message>

=cut

__PACKAGE__->belongs_to(
  "op_post",
  "App::Models::Schema::Result::Message",
  { id => "op_post_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-01-08 11:54:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CDEyBU3lS2PHg/vY5/3Pvg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
