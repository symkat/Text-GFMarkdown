package Text::GFMarkdown::Lex;
use warnings;
use strict;
use Regexp::Common qw( URI );
use base 'Text::GFMarkdown::Utils';

sub new {
    my ( $class, $args ) = @_;
    my $self = bless { }, $class;

    return $self;
}

sub lex {
    my ( $self, $str ) = @_;
    my @tokens;


    pos($str) = 0;

    $self->debug( "Begin Lexing." );
    while ( length($str) != pos($str) ) {
        # Escaped Thingies.
        if ( $str =~ /\G(\\\\|\\\`|\\\*|\\\_|\\\{|\\\}|\\\[|\\\]|\\\(|\\\)|\\\#|\\\+|\\\-|\\\.|\\\!)/gc ) {
            push @tokens, $self->make_token( "char", substr($1,1,1) );
            $self->debug( "\tEscaped sequence (" . substr($1,1,1). ")" );
        } elsif ( $str =~ /\G\`\`\` (\S+)\n/gc ) {
            push @tokens, $self->make_token( "code_block", $1 );
            $self->debug( "\tcode_block sequence type ($1)" );
        } elsif ( $str =~ /\G\`\`\`\n/gc ) {
            push @tokens, $self->make_token( "code_block" );
            $self->debug( "\tcode_block sequence type (undef)" );

        } elsif ( $str =~ /\G([\#]+) (.+?)(?=\n|$)/gc  ) {
            push @tokens, $self->make_token( "header", $2, { size => length($1) } );
            $self->debug( "\tHeader sequence (" . $2 . ")" );
        } elsif ( $str =~ /\G\*\*\*/gc ) {
            push @tokens, $self->make_token("bold_italic");
            $self->debug( "\tbold_italics sequence." );
        } elsif ( $str =~ /\G___/gc  ) {
            push @tokens, $self->make_token("bold_italic");
            $self->debug( "\tbold_italics sequence." );
        } elsif ( $str =~ /\G\*\*/gc ) {
            push @tokens, $self->make_token("italic");
            $self->debug( "\titalics sequence." );
        } elsif ( $str =~ /\G(?:(?<=^)|(?<=[\s]))\*(?=\S|$)/gc or $str =~ /\G(?<=[\S])\*/gc ) {
            push @tokens, $self->make_token( "bold" );
            $self->debug( "\tbold sequence." );
        } elsif ( $str =~ /\G__/gc ) {
            push @tokens, $self->make_token( "italic" );
            $self->debug( "\titalics sequence." );
        } elsif ( $str =~ /\G_/gc ) {
            push @tokens, $self->make_token( "bold" );
            $self->debug( "\tbold sequence." );
        } elsif ( $str =~ /\G($RE{URI}{HTTP})/gc ) {
            push @tokens, $self->make_token( "url", $1 );
            $self->debug( "\turl sequence ($1)." );
        } elsif ( $str =~ /\G\n\n/gc ) {
            push @tokens, $self->make_token( "paragraph_end" );
            $self->debug( "\tparagraph end sequence" );
        } elsif ( $str =~ /\G\n/gc ) {
            push @tokens, $self->make_token( "line_break" );
            $self->debug( "\tline break sequence" );
        } elsif ( $str =~ /\G(.+?)(?=\\|\*|\#|_|$RE{URI}{HTTP}|\n)/gc ) {
            push @tokens, $self->make_token( "string", $1 );
            $self->debug( "\tstring sequence ($1)" );
        } elsif ( $str =~ /\G(.)/sgc ) {
            push @tokens, $self->make_token( "char", $1 );
            $self->debug( "\tchar sequence ($1)" );
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
