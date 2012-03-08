package Text::GFMarkdown::Parse;
use warnings;
use strict;
use Data::Dumper;

my $debug = 1;

sub debug {
    my ( $self, $message ) = @_;
    if ( $debug ) {
        print "[DEBUG] " . $message . "\n";
    }
}

sub new {
    my ( $class, $args ) = @_;
    my $self = bless { }, $class;

    return $self;
}

sub in_block {

}

sub paragraph_open {
    my $self = shift;
    $self->{paragraph_open} = shift if @_;
    return $self->{paragraph_open};
}

sub parse {
    my ( $self, @tokens ) = @_;
    
    my $context;
    my @tree;

    $self->pre_process( \@tokens );

    push @tree, $self->_parse(\@tokens);

    $self->post_process( \@tree );


    return @tree;
}

sub pre_process {
    my ( $self, $tokens ) = @_;

    # If the last token is a line break, remove it.
    if ( $tokens->[-1]->{type} eq 'line_break' ) {
        pop @{ $tokens };
    }
}

sub post_process {
    my ( $self, $tree ) = @_;

    # Remove final line breaks 
#    pop @tree if $tree[-1]->{type} eq 'line_break';
}

sub _parse_paragraph {
    my ( $self, $tokens ) = @_;
    my @tree;

    $self->debug( __PACKAGE__ . "->_parse_paragraph() called." );

    while ( defined ( my $token = shift @{ $tokens } ) ) {
        $self->debug( "Checking token type " . $token->{type} . " with content \"" . $token->{content} . "\"" );
        if ( $token->{type} eq 'char' ) {
            unshift @{ $tokens }, $token;
            push @tree, { type => 'string', content => $self->parse_string($tokens) };
            $self->debug( "\tFound string: " . $tree[-1]->{content} );
        } elsif ( $token->{type} eq 'url' ) {
            push @tree, { type => 'url', content => $token->{content} };
            $self->debug( "\tFound URL: " . $token->{content} );
        } elsif ( $token->{type} eq 'bold_italic' ) {
            $self->debug( "\tFound bold_italic.");
            my @todo;
            while ( defined ( my $todo_token = shift @{ $tokens } ) ) {
                last if $todo_token->{type} eq 'bold_italic';
                push @todo, $todo_token;
            }
            push @tree, { type => 'bold', tokens => [ { type => 'italic', tokens => [ $self->_parse_paragraph(\@todo) ] } ] };

        } elsif ( $token->{type} eq 'bold' ) {
            $self->debug( "\tFound bold");
            my @todo;
            while ( defined ( my $todo_token = shift @{ $tokens } ) ) {
                last if $todo_token->{type} eq 'bold';
                push @todo, $todo_token;
            }
            push @tree, { type => 'bold', tokens => [ $self->_parse_paragraph(\@todo)  ] };
        } elsif ( $token->{type} eq 'italic' ) {
            $self->debug( "\tFound italic");
            my @todo;
            while ( defined ( my $todo_token = shift @{ $tokens } ) ) {
                last if $todo_token->{type} eq 'italic';
                push @todo, $todo_token;
            }
            push @tree, { type => 'italic', tokens => [ $self->_parse_paragraph(\@todo) ] };
        } elsif ( $token->{type} eq 'line_break' ) {
            $self->debug( "\tFound line_break.");
            push @tree, { type => 'line_break' };
        } elsif ( $token->{type} eq 'paragraph_end' ) {
            $self->debug( "\tFound paragraph_end, returning.");
            return @tree;
        } else {
            die "Parse failed at token: " . Dumper $token;
        }
    }
    return @tree;
}

sub _parse {
    my ( $self, $tokens ) = @_;
    my @tree;
    $self->debug( "$self->_parse() called." );
    
    while ( defined ( my $token = shift @{ $tokens } ) ) {
        if ( $token->{type} eq 'header' ) {
            $self->debug( "Found header, pushing into \@tree." );
            push @tree, $token;
        } else {
            $self->debug( "Found paragraph, calling $self-->_parse_paragraph" );
            unshift @{ $tokens }, $token; # Put the token back!
            push @tree, { type => "paragraph", tokens => [ $self->_parse_paragraph( $tokens ) ] };
        }
    }
    return @tree;
}

sub parse_string {
    my ( $self, $tokens ) = @_;
    my $string;
    while ( defined ( my $token = shift @{ $tokens } ) ) {
        if ( $token->{type} ne 'char' ) {
            unshift @{ $tokens }, $token;
            last;
        }
        $string .= $token->{content};
    }
    return $string;
}

1;
