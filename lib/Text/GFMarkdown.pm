package Text::GFMarkdown;
use warnings;
use strict;

use Text::GFMarkdown::Lex;
use Text::GFMarkdown::Parse;
use Text::GFMarkdown::Compile;

my $lex = Text::GFMarkdown::Lex->new;
my $parse = Text::GFMarkdown::Parse->new;
my $compile = Text::GFMarkdown::Compile->new;


sub new {
    my ( $class, $args ) = @_;
    
    my $self = bless {  }, $class;
    
    return $self;
}

sub markdown {
    my ( $self, $content ) = @_;

    return $compile->compile($parse->parse($lex->lex($content)));
}

1;
