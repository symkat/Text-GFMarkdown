package Text::GFMarkdown::Compile;
use warnings;
use strict;
use Data::Dumper;

sub new {
    return bless {}, shift;
}


sub compile {
    my ( $self, @tree ) = @_;

    return $self->_compile( \@tree );
}

sub _compile {
    my ( $self, $tree ) = @_;
    my $str;


    while ( defined ( my $node = shift @{ $tree } ) ) {


        if ( ref $node->{tokens} eq 'ARRAY' ) {
            if ( my $c = $self->can($node->{type}) ) {
                $str .= $c->( $self->_compile( $node->{tokens} ) );
            } else {
                $str .= $self->_compile( $node->{tokens} );
            }
        } else {
            if ( my $c = $self->can($node->{type}) ) {
                $str .= $c->($node->{content});
            } else {
                warn "Unknown type " . $node->{type} . " returning content.";
                $str .= $node->{content};
            }
        }
    }
    return $str;
}

sub italic {
    my ( $content ) = @_;
    return "<em>$content</em>";
}

sub bold {
    my ( $content ) = @_;
    return "<strong>$content</strong>";
}

sub paragraph_start {
    return '<p>';
}

sub paragraph_end {
    return '</p>';
}

sub url {
    my ( $content ) = @_;
    return "<a href=\"$content\">$content</a>"; 
}

sub string {
    return shift;
}

1;
