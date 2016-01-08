package App::Core::Parser;
use strict;
use warnings;
use utf8;

sub bbcode {
	my $text = shift;
	$text =~ s/(http:\/\/|https:\/\/|ftp:\/\/)([^(\s<|\[)]*)/<a href=\"$1$2\">$1$2<\/a>/ig;
	$text =~ s/\[b\](.+?)\[\/b\]/<b>$1<\/b>/isg;
	$text =~ s/\[i\](.+?)\[\/i\]/<i>$1<\/i>/igs; 
	$text =~ s/\[u\](.+?)\[\/u\]/<span style="border-bottom: 1px solid">$1<\/span>/igs; 
	$text =~ s/\[s\](.+?)\[\/s\]/<strike>$1<\/strike>/igs;
	$text =~ s/\[spoiler\](.+?)\[\/spoiler\]/<span class="spoiler" onmouseover="this.style.color=\'white\';" onmouseout="this.style.color=\'black\'">$1<\/span>/igs; 
    $text =~ s/\n/<br>/igs;
	return $text;
}
 
1;
        
