package App::Core::Parser;
use strict;
use warnings;
use utf8;
use List::MoreUtils qw(uniq);

sub bbcode {
	my $text = shift;
    my @id_matches = uniq ($text =~ />>(\w+\/|\d+\/|\d+)/g);
    $text =~ s/>>((\w+\/|)(\d+\/|)\d+)/<a onclick="focuspost($1)" data-ref="$1" href="#$1" class="msg_ref">$&<\/a>/igs;
	$text =~ s/(http:\/\/|https:\/\/|ftp:\/\/)([^(\s<|\[)]*)/<a href=\"$1$2\">$1$2<\/a>/ig;
	$text =~ s/\[b\](.+?)\[\/b\]/<b>$1<\/b>/isg;
	$text =~ s/\[i\](.+?)\[\/i\]/<i>$1<\/i>/igs; 
	$text =~ s/\[u\](.+?)\[\/u\]/<span style="border-bottom: 1px solid">$1<\/span>/igs; 
	$text =~ s/\[s\](.+?)\[\/s\]/<strike>$1<\/strike>/igs;
	$text =~ s/\[spoiler\](.+?)\[\/spoiler\]/<span class="spoiler" onmouseover="this.style.color=\'white\';" onmouseout="this.style.color=\'black\'">$1<\/span>/igs; 
    $text =~ s/\n/<br>/igs;
	return $text, \@id_matches;
}
 
1;
        
