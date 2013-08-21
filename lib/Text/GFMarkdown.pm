package Text::GFMarkdown;
use warnings;
use strict;

use Text::GFMarkdown::Lex;
use Text::GFMarkdown::Parse;
use Text::GFMarkdown::Compile;

my $lex = Text::GFMarkdown::Lex->new;
my $parse = Text::GFMarkdown::Parse->new;
my $compile = Text::GFMarkdown::Compile->new;


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

1;
