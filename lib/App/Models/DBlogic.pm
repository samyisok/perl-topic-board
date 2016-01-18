package App::Models::DBlogic;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../";
use utf8;
use App::Models::Schema;
use App::Config::Core;
use App::Core::Parser;


sub init_schema {
    my $dbconfig = App::Config::Core->new();
    my $schema = App::Models::Schema->connect(
        $dbconfig->db_pref, $dbconfig->db_user, $dbconfig->db_pass, {
            quote_names => 1,
            mysql_enable_utf8 => 1,
            on_connect_do     => [ 'SET NAMES utf8', ],
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
    my $result = $db->resultset('Message')->search({ id => $op_id }); 
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
           ref_answers => [ sort {$a <=> $b } split(' ', $string->ref_answers) ],
                  name => $string->name,
            });
    }
    return \@array_of_hashes;

}



sub get_user_by_hash {
    my $username = shift;
    my $pass_hash = shift;
    my $db = init_schema();
    my $result = $db->resultset('User')->single({ username => $username, password => $pass_hash});
    my $string = $result; 
    return { 
                username => $string->username,
                email => $string->email,
                role => $string->role,
                token_session => $string->token_session,
            } if $string;
}



sub get_topics {
    my $db = init_schema();
    my $dest = shift;
    my $result = $db->resultset('Topic')->search({
            dest => $dest,
        },
        {
            order_by => { -desc => 'date' },
        },
        );
    my @array_hash_of_topic_id;
    for my $string ($result->all){
       push(@array_hash_of_topic_id,
           {     topic_id => $string->id,
               op_post_id => $string->op_post_id,
               count_pics => $string->count_pics,
              count_posts => $string->count_posts,
           } );
    }
    return @array_hash_of_topic_id;
    }

sub get_topics_w_posts {
    my $board = shift;
    my @topics_posts;
    my @array_of_topics = get_topics($board);
    for my $topic (@array_of_topics) {
           my %hash = %{$topic};
           my $topic_id = $hash{'topic_id'};
           my $op_post_id = $hash{'op_post_id'};
           my $count_posts = $hash{'count_posts'};
           my $count_pics = $hash{'count_pics'};
           my $anon = { 
               topic_id => $topic_id,
               op_post => get_op_post($op_post_id),
               list_of_posts => get_topic_last_tree_posts($topic_id, $op_post_id),
               count_posts => $count_posts,
               count_pics => $count_pics,
            };
        push(@topics_posts, $anon);
    }
    return \@topics_posts;
}

sub update_topic_date {
    my $topic_id = shift;
    my $db = init_schema();
    my $topic_post = $db->resultset('Topic')->find($topic_id);
    $topic_post->date(\'NOW()');
    $topic_post->update;
}

sub update_user_token {
    my $username = shift;
    my $new_token = shift;
    my $time = shift;
    my $db = init_schema();
    my $user = $db->resultset('User')->find({username => $username});
    $user->token_session($new_token);
    $user->login_time($time) if $time;
    $user->update;
}

sub create_post {
    my $db = init_schema();
    my $msg = shift;
    my $img_path = shift;
    my $pre_img_path = shift;
    my $topic_id = shift;
    my $username = shift;
    my $config = App::Config::Core->new();
    $username = $config->get_username() unless $username;
    my $ref_list_id_answers;
    ($msg, $ref_list_id_answers) = App::Core::Parser::bbcode($msg);
    my $request = $db->resultset('Message')->create({
            message => $msg,
            img_path => $img_path,
            pre_img_path => $pre_img_path,
            date => \'NOW()',
            topic_id => $topic_id,
            ref_answers => '',
            name => $username,
        },
        );
    update_topic_date($topic_id);
    update_topic_count($topic_id, $img_path);
    my $post_id = $request->{_column_data}->{id};
    update_post_ref($ref_list_id_answers, $post_id);
    return $post_id;
}

sub update_post_ref {
    my $ref_list_id_answers = shift;
    my $post_id = shift;
    for my $ref_post_id (@{$ref_list_id_answers}){
        update_post_ref_by_id($ref_post_id, $post_id);
    }
}

sub update_post_ref_by_id {
    my $ref_post_id = shift;
    my $post_id = shift;
    my $db = init_schema();
    my $post = $db->resultset('Message')->find($ref_post_id);
    $post->update({
        ref_answers => \"CONCAT($post_id, ' ', ref_answers)",
    });
}

sub create_topic {
    my $board = shift;
    my $db = init_schema();
    my $request = $db->resultset('Topic')->create({
        dest => $board,
        count_pics => 0,
        count_posts => 0,
        },);
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

sub update_topic_count {
    my $db = init_schema();
    my $topic_id = shift;
    my $img = shift;
    my $topic_post = $db->resultset('Topic')->find($topic_id);
    if(!$img) {
        $topic_post->update({
            count_posts => \'count_posts + 1',
            });
    }
    else {
        $topic_post->update({
            count_posts => \'count_posts + 1',
            count_pics => \'count_pics + 1',
            });
    }
}

sub create_topic_w_posts {
    my $msg = shift;
    my $img_path = shift;
    my $pre_img_path = shift;
    my $board = shift;
    my $username = shift;
    my $topic_id = create_topic($board);
    my $op_id = create_post($msg, $img_path, $pre_img_path, $topic_id, $username);
    update_topic_op_id($topic_id, $op_id);

}


sub get_list_topics {
    my $db = init_schema();
    my $topic_list = $db->resultset('Topic')->search(undef, {
        columns => [qw/ dest /],
        });
    my %result_hash;
    for my $string ($topic_list->all){
        if (exists $result_hash{$string->dest}){
            $result_hash{$string->dest}++;
        }
        else {
            $result_hash{$string->dest} = 1;
        }
    }
    my @sorted_result_array;
    for my $key (sort(keys %result_hash)){
        push(@sorted_result_array, 
            {$key => $result_hash{$key}}
        );

    }
    return \@sorted_result_array;
}





1;
