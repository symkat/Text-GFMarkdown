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

sub register_hook($&) {
    my ( $self, $hook ) = @_;
    push @{$self->{hooks}}, $hook;
}

sub run_hooks {
    my ( $self, @tokens ) = @_;

    for ( my $i = 0; $i <= $#tokens; $i++ ) {
        for my $hook ( @{$self->{hooks}} ) {
            $hook->($i, \@tokens );
        }
    }
    return @tokens;
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

        # Block quotes start with "> " and may be preceeded
        # by a newline, or another block quote.
        } elsif ( $str =~ /\G(?:(?<=^)|(?<=\n))(?:(\*\s*\*\s*\*)|(-\s*-\s*-)|(_\s*_\s*_))[-_*\s]*\n/gc ) {
            push @tokens, $self->make_token( "hr" );
            $self->debug( "\thr sequence" );
        } elsif ( $str =~ /\G!\[(.*)\]\(($RE{URI}{HTTP})\s+"([^"]+)"\s*\)/gc ) {
            push @tokens, $self->make_token( "img", $2, { title => $3, text => $1 } );
            $self->debug( "\tlink sequence (text => $1, title => $3, href => $2)." );
        } elsif ( $str =~ /\G!\[(.*)\]\(($RE{URI}{HTTP}\s*)\)/gc ) {
            push @tokens, $self->make_token( "img", $2, { text => $1 } );
            $self->debug( "\tlink sequence (text => $1, href => $2)." );
        } elsif ( $str =~ /\G\[(.*)\]\(($RE{URI}{HTTP})\s+"([^"]+)"\s*\)/gc ) {
            push @tokens, $self->make_token( "link", $2, { title => $3, text => $1 } );
            $self->debug( "\tlink sequence (text => $1, title => $3, href => $2)." );
        } elsif ( $str =~ /\G\[(.*)\]\(($RE{URI}{HTTP}\s*)\)/gc ) {
            push @tokens, $self->make_token( "link", $2, { text => $1 } );
            $self->debug( "\tlink sequence (text => $1, href => $2)." );
        } elsif ( $str =~ /\G($RE{URI}{HTTP})/gc ) {
            push @tokens, $self->make_token( "url", $1 );
            $self->debug( "\turl sequence ($1)." );
        } elsif ( $str =~ /\G(?:(?=^)|(?=\n))(?:\*|\+|\-) /gc or ( exists $tokens[-1] and $tokens[-1]->{type} eq 'line_break' and $str =~ /\G(?:\*|\+|\-) /gc ) ) {
            push @tokens, $self->make_token( "item" );
            $self->debug( "\titem sequence." );
        } elsif ( $str =~ /\G(?:(?=^)|(?=\n)|(?=>\s))> \* /gc ) {
            push @tokens, $self->make_token( "blockquote" ), $self->make_token( "item" );
            $self->debug( "\tblockquote item sequence." );
        } elsif ( $str =~ /\G(?:(?=^)|(?=\n)|(?=>\s))> /gc ) {
            push @tokens, $self->make_token( "blockquote" );
            $self->debug( "\tblockquote sequence." );
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
        } elsif ( $str =~ /\G\n/gc ) {
            push @tokens, $self->make_token( "line_break" );
            $self->debug( "\tline break sequence" );
        } elsif ( $str =~ /\G(\s+)/gc ) {
            push @tokens, $self->make_token( "space", $1 );
            $self->debug( "\tspace sequence ($1)" );
        } elsif ( $str =~ /\G(.+?)(?=\\|\*|\#|_|$RE{URI}{HTTP}|\n|\s)/gc ) {
            push @tokens, $self->make_token( "word", $1 );
            $self->debug( "\tword sequence ($1)" );
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
