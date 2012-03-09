package Text::GFMarkdown::Utils;
use warnings;
use strict;

sub debug {
    my ( $self, $message ) = @_;
    my ( $package, $filename, $line, $sub ) = caller(1);
    my ($class, $function ) = ((split( /::/, $sub ))[-2,-1]);
    print "[debug $class->$function]: $message\n" if $ENV{'GFM_TRACE'};
}

1;
