use utf8;
package App::Models::Schema::Result::Message;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

App::Models::Schema::Result::Message

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<messages>

=cut

__PACKAGE__->table("messages");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 message

  data_type: 'mediumtext'
  is_nullable: 1

=head2 img_path

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 pre_img_path

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 topic_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "message",
  { data_type => "mediumtext", is_nullable => 1 },
  "img_path",
  { data_type => "char", is_nullable => 1, size => 255 },
  "pre_img_path",
  { data_type => "char", is_nullable => 1, size => 255 },
  "date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "topic_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 topic

Type: belongs_to

Related object: L<App::Models::Schema::Result::Topic>

=cut

__PACKAGE__->belongs_to(
  "topic",
  "App::Models::Schema::Result::Topic",
  { id => "topic_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 topics

Type: has_many

Related object: L<App::Models::Schema::Result::Topic>

=cut

__PACKAGE__->has_many(
  "topics",
  "App::Models::Schema::Result::Topic",
  { "foreign.op_post_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-01-05 17:55:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NITpXW9yMzScYx6bgGuHVg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
