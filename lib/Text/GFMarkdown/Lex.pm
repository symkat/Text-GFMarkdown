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
        # Escaped Thingies.
        if ( $str =~ /\G(\\\\|\\\`|\\\*|\\\_|\\\{|\\\}|\\\[|\\\]|\\\(|\\\)|\\\#|\\\+|\\\-|\\\.|\\\!)/gc ) {
            push @tokens, $self->make_token( "char", substr($1,1,1) );
        } elsif ( $str =~ /\G([\#]+) (.+?)\n/gc  ) {
            push @tokens, $self->make_token( "header", $2, { size => length($1) } );
            # We need to add that \n back, since it's part of the language....
            my $pos = pos($str);
            $str = "\n$str";
            pos($str) = ($pos);
        } elsif ( $str =~ /\G\*\*\*/gc ) {
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
        } elsif ( $str =~ /\G\n\n/gc ) {
            push @tokens, $self->make_token( "paragraph_end" );
        } elsif ( $str =~ /\G\n/gc ) {
            push @tokens, $self->make_token( "line_break" );
        } elsif ( $str =~ /\G(.)/sgc ) {
            push @tokens, $self->make_token( "char", $1 );
        } else {
            # TODO  I need MUCH nicer debug information.
            die "Lexer blew up: " . substr($str,(pos($str)-5),10) . "\n" 
            . ( "-" x 9 ) . "^ HERE";
        }
    }

    return @tokens;
}

sub make_token {
    my ( $self, $type, $content, $meta ) = @_;
    return {
        type => $type,
        content => ($content ? $content : "" ),
        %{ defined $meta ? $meta : {} },
    }
}

1;
