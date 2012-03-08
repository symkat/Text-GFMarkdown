package Text::GFMarkdown::Lex;
use warnings;
use strict;
use Regexp::Common qw( URI );

sub new {
    my ( $class, $args ) = @_;
    my $self = bless { }, $class;

    return $self;
}

sub lex {
    my ( $self, $str ) = @_;
    my @tokens;

    pos($str) = 0;

    while ( length($str) != pos($str) ) {
        if ( $str =~ /\G\*\*\*/gc ) {
            push @tokens, $self->make_token("bold_italic");
        } elsif ( $str =~ /\G___/gc  ) {
            push @tokens, $self->make_token("bold_italic");
        } elsif ( $str =~ /\G\*\*/gc ) {
            push @tokens, $self->make_token("italic");
        } elsif ( $str =~ /\G\*/gc ) {
            push @tokens, $self->make_token( "bold" );
        } elsif ( $str =~ /\G__/gc ) {
            push @tokens, $self->make_token( "italic" );
        } elsif ( $str =~ /\G_/gc ) {
            push @tokens, $self->make_token( "bold" );
        } elsif ( $str =~ /\G($RE{URI}{HTTP})/gc ) {
            push @tokens, $self->make_token( "url", $1 );
        } elsif ( $str =~ /\G(.)/gc ) {
            push @tokens, $self->make_token( "char", $1 );
        } elsif ( $str =~ /\G\n\n/gc ) {
            push @tokens, $self->make_token( "paragraph_end" );
        } else {
            # TODO  I need MUCH nicer debug information.
            die "Parser blew up!";
        }
    }

    return @tokens;
}

sub make_token {
    my ( $self, $type, $content ) = @_;
    return {
        type => $type,
        content => ($content ? $content : "" ),
    }
}

1;
