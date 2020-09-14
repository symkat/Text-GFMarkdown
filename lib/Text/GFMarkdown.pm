# ABSTRACT: Markdown Lexer, Parser, and Compiler.
package Text::GFMarkdown;
use warnings;
use strict;

use Text::GFMarkdown::Lex;
use Text::GFMarkdown::Parse;
use Text::GFMarkdown::Compile;

my $lex = Text::GFMarkdown::Lex->new;
my $parse = Text::GFMarkdown::Parse->new;
my $compile = Text::GFMarkdown::Compile->new;


$lex->register_hook(sub {
    my ( $i, $ref ) = @_;

    return unless $i == 0; # Only run once, on the first token.
    my @new_start;

    if ( $ref->[$i]->{type} eq 'hr' ) {
        my $meta_start = shift @$ref;

        while ( my $key = shift @$ref ) {
            last if $key->{type} eq 'hr';
            my $metadata_value;
            my $metadata_key = $key->{content};
            $metadata_key =~ s/:$//;

            shift @$ref; # Drop the first token (space).
            while ( my $value = shift @$ref ) {
                if ( $value->{type} eq 'space' ) {
                    $metadata_value .= ' ';
                } elsif ( $value->{type} eq 'word' ) {
                    $metadata_value .= $value->{content};
                } elsif ( $value->{type} eq 'line_break' ) {
                    last;
                } else {
                    die "Unexpected token in hook";
                }
            }
            push @new_start,
                { type => 'metadata_key',   content => $metadata_key },
                { type => 'metadata_value', content => $metadata_value };
        }
        unshift @{$ref}, @new_start;
    }
});

$lex->register_hook(
    sub { 
        my ( $i, $ref ) = @_; 
        # #Testing compatiablity layer.
        #warn "i => $i, size => " . $#$ref . "\n\n";
        $ref->[$i]->{type} = "string" 
            if $ref->[$i]->{type} eq 'word' or $ref->[$i]->{type} eq 'space';

        if ( exists $ref->[$i+1] ) { # Look ahead enabled code.
            if ( $ref->[$i]->{type} eq 'line_break' and $ref->[$i+1]->{'type'} eq 'line_break' ) {
                splice(@$ref,$i,2,{ type => "paragraph_end", content => "" });
            }
        }
        if ( $ref->[$i]->{type} eq 'item' and ( exists $ref->[$i-1] and $ref->[$i-1]->{type} eq 'line_break' ) ) {
            # Remove the line break between list items.
            $ref->[$i-1] = { type => "string", content => "" };
        }
    }
);

sub new {
    my ( $class, $args ) = @_;
    
    my $self = bless {  }, $class;
    
    return $self;
}

sub markdown {
    my ( $self, $content ) = @_;

    return $compile->compile($parse->parse($lex->run_hooks($lex->lex($content))));
}

sub metadata {
    my ( $self, $content ) = @_;

    my @tree = $lex->run_hooks($lex->lex($content));

    my $data = {};
    while ( my $elem = shift @tree ) {
        if ( $elem->{type} eq 'metadata_key' ) {
            $data->{$elem->{content}} = $tree[0]->{type} eq 'metadata_value'
                ? (shift @tree)->{content}
                : undef;
        }
    }
    return $data;
}

1;
