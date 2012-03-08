package Text::GFMarkdown::Parse;
use warnings;
use strict;
use Data::Dumper;

sub new {
    my ( $class, $args ) = @_;
    my $self = bless { }, $class;

    return $self;
}

sub parse {
    my ( $self, @tokens ) = @_;
    
    my $context;
    my @tree;

    if ( $tokens[0]->{type} ne 'header' ) {
        push @tree, { type => "paragraph_start" };
    }

    push @tree, $self->_parse(\@tokens);

    # Our last token should be a paragraph ending.
    push @tree, { type => 'paragraph_end' };

    return @tree;
}

sub _parse {
    my ( $self, $tokens ) = @_;
    my @tree;
    
    while ( defined ( my $token = shift @{ $tokens } ) ) {
        if ( $token->{type} eq 'char' ) {
            unshift @{ $tokens }, $token;
            push @tree, { type => 'string', content => $self->parse_string($tokens) };
        } elsif ( $token->{type} eq 'url' ) {
            push @tree, { type => 'url', content => $token->{content} };
        } elsif ( $token->{type} eq 'bold_italic' ) {
            my @todo;
            while ( defined ( my $todo_token = shift @{ $tokens } ) ) {
                last if $todo_token->{type} eq 'bold_italic';
                push @todo, $todo_token;
            }
            push @tree, { type => 'bold', tokens => [ { type => 'italic', tokens => [ $self->_parse(\@todo) ] } ] };

        } elsif ( $token->{type} eq 'bold' ) {
            my @todo;
            while ( defined ( my $todo_token = shift @{ $tokens } ) ) {
                last if $todo_token->{type} eq 'bold';
                push @todo, $todo_token;
            }
            push @tree, { type => 'bold', tokens => [ $self->_parse(\@todo)  ] };
        } elsif ( $token->{type} eq 'italic' ) {
            my @todo;
            while ( defined ( my $todo_token = shift @{ $tokens } ) ) {
                last if $todo_token->{type} eq 'italic';
                push @todo, $todo_token;
            }
            push @tree, { type => 'italic', tokens => [ $self->_parse(\@todo) ] };
        } elsif ( $token->{type} eq 'paragraph_end' ) {
            push @tree, { type => 'paragraph_end' };
            push @tree, { type => 'paragraph_start' };
        } else {
            die "Parse failed at token: ";
            print Dumper $token;
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
