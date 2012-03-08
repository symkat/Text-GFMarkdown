package Text::GFMarkdown::Parse;
use warnings;
use strict;
use Data::Dumper;

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

    if ( $tokens[0]->{type} ne 'header' ) {
        push @tree, { type => "paragraph_start" };
        $self->paragraph_open(1);
    }

    push @tree, $self->_parse(\@tokens);

    # Kill extra <br />'s at the end.
    pop @tree if $tree[-1]->{type} eq 'line_break';

    my $ptags = scalar map { $_->{type} =~ /^paragraph/ } @tree;
    if ( $ptags % 2 == 1 ) {
        push @tree, { type => 'paragraph_end' };
    }

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
            # Do we need to terminate a previous paragraph_start ?
            if ( $self->paragraph_open ) {
                push @tree, { type => 'paragraph_end' };
            }
            # If the next thing isn't a block, we'll make another paragraph.
            my $look_ahead = shift @{$tokens};
            next unless $look_ahead; # We don't have a next thing.
            if ( $look_ahead->{type} ne 'header' ) {
                push @tree, { type => 'paragraph_start' };
                unshift @{ $tokens }, $look_ahead; # Put it back.
            } else {
                $self->paragraph_open(0);
                unshift @{ $tokens }, $look_ahead; # Put it back.
            }
        } elsif ( $token->{type} eq 'line_break' ) {
            push @tree, { type => 'line_break' };
        } elsif ( $token->{type} eq 'header' ) {
            push @tree, $token;
        } else {
            die "Parse failed at token: " . Dumper $token;
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
