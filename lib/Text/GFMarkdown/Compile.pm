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
                $str .= $c->($node);
            } else {
                warn "Unknown type " . $node->{type} . " returning content.";
                $str .= $node->{content};
            }
        }
    }
    return $str;
}

sub italic {
    my ( $node ) = @_;
    if ( ref $node ) {
        return "<em>" . $node->{content} . "</em>";
    } else {
        return "<em>$node</em>";
    }
}

sub bold {
    my ( $node ) = @_;
    if ( ref $node ) {
        return "<strong>" . $node->{content} . "</strong>";
    } else {
        return "<strong>$node</strong>";
    }
}

sub paragraph_start {
    return '<p>';
}

sub paragraph_end {
    return '</p>';
}

sub url {
    my ( $node ) = @_;
    my $content = ref $node ? $node->{content} : $node;
    return "<a href=\"$content\">$content</a>"; 
}

sub string {
    my ( $node ) = @_;
    return ref $node ? $node->{content} : $node;
}

sub line_break {
    return '<br />';
}

sub header {
    my ( $node ) = @_;

    my $size = $node->{size};
    $size = 1 if ( $size > 7 || $size < 1 );
    my $header = $node->{content};
    
    $header =~ s/^\s//;
    return "<h$size>$header</h$size>";
}

1;
