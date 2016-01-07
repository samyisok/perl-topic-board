package App::Models::DBlogic;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../";

use App::Models::Schema;
use App::Config::Core;


sub init_schema {
    my $dbconfig = App::Config::Core->new();
    my $schema = App::Models::Schema->connect(
        $dbconfig->db_pref, $dbconfig->db_user, $dbconfig->db_pass, {
            quote_names => 1,
            mysql_enable_utf8 => 1,
        });
    return $schema;

}

sub get_posts {
    my $topic_id = shift;
    my $db = init_schema();
    my $result = $db->resultset('Message')->search({topic_id => $topic_id}); 
    my $tmp_arr = extract_posts($result);
    return $tmp_arr;
    }

sub get_op_post {
    my $op_id = shift;
    my $db = init_schema();
    my $result = $db->resultset('Message')->search( id => $op_id); 
    my $tmp_arr = extract_posts($result);
    return $tmp_arr->[0];
}

sub get_topic_last_tree_posts {
    my $topic_id = shift;
    my $op_id = shift;
    my $db = init_schema();
    my $result = $db->resultset('Message')->search(
        {
            topic_id => $topic_id,
            id => { 'not in' => $op_id },
            
        },
        {
            order_by => { -desc => 'date' },
            rows => 3,
        },
    );
    my $tmp_arr = extract_posts($result);
    my @final_arr = reverse @{$tmp_arr};
    return \@final_arr;

}

sub extract_posts {
    my $result_obj = shift;
    my @array_of_hashes;
    for my $string ($result_obj->all) {
        push(
            @array_of_hashes,
            {
                    id => $string->id, 
               message => $string->message,
                  date => $string->date,
          pre_img_path => $string->pre_img_path,
              img_path => $string->img_path,
            });
    }
    return \@array_of_hashes;

}

sub get_topics {
    my $db = init_schema();
    my $dest = shift;
    my $result = $db->resultset('Topic')->search({
        dest => $dest,
        });
    #$result->result_class('DBIx::Class::ResultClass::HashRefInflator');
    my %hash_of_topic_id;
    for my $string ($result->all){
        $hash_of_topic_id{$string->id} = $string->op_post_id;
    }
    return %hash_of_topic_id;
    }

sub get_topics_w_posts {
    my $board = shift;
    my @topics_posts;
    my %hash = get_topics($board);
    use Data::Dumper;
    #print Dumper(\%hash);
    for my $topic_id (keys %hash) {
           my $anon = { 
               topic_id => $topic_id,
               op_post => get_op_post($hash{$topic_id}),
               list_of_posts => get_topic_last_tree_posts($topic_id, $hash{$topic_id}),
            };
            #    print Dumper($anon);
        push(@topics_posts, $anon);
    }
    #print Dumper(\@topics_posts);
    return \@topics_posts;
}


sub create_post {
    my $db = init_schema();
    my $msg = shift;
    my $img_path = shift;
    my $pre_img_path = shift;
    my $topic_id = shift;
    my $request = $db->resultset('Message')->create({
            message => $msg,
            img_path => $img_path,
            pre_img_path => $pre_img_path,
            date => \'NOW()',
            topic_id => $topic_id,
        },
        );
    return $request->{_column_data}->{id}
}



sub create_topic {
    my $board = shift;
    my $db = init_schema();
    my $request = $db->resultset('Topic')->create({
        dest => $board,},
        );
    return $request->{_column_data}->{id}
}

sub update_topic_op_id {
    my $db = init_schema();
    my $topic_id = shift;
    my $op_id = shift;
    my $topic_post = $db->resultset('Topic')->find($topic_id);
    $topic_post->op_post_id($op_id);
    $topic_post->update;

}


sub create_topic_w_posts {
    my $msg = shift;
    my $img_path = shift;
    my $pre_img_path = shift;
    my $board = shift;
    my $topic_id = create_topic($board);
    my $op_id = create_post($msg, $img_path, $pre_img_path, $topic_id);
    update_topic_op_id($topic_id, $op_id);

}

1;
