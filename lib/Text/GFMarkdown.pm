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
