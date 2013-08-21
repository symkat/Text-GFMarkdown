package Text::GFMarkdown::Compile;
use warnings;
use strict;
use base 'Text::GFMarkdown::Utils';
use Data::Dumper;

sub new {
    return bless {}, shift;
}


sub compile {
    my ( $self, @tree ) = @_;

    #print Dumper \@tree;

    return $self->_compile( \@tree );
}

sub _compile {
    my ( $self, $tree ) = @_;
    my $str;
    $self->{compile}++;
    my $space = "\t" x $self->{compile};

    $self->debug( "$space compiling..."  );

    while ( defined ( my $node = shift @{ $tree } ) ) {
        if ( ref $node->{tokens} eq 'ARRAY' ) {
            $self->debug( "$space found array of type " . $node->{type} );
            if ( my $c = $self->can($node->{type}) ) {
                $self->debug( "$space Calling " . $node->{type} . " on " . Dumper $node->{tokens} );
                $str .= $c->( { content => $self->_compile( delete $node->{tokens} ), %{ $node } } );
            } else {
                $self->debug( "$space calling compiler on type " . $node->{type} );
                $str .= $self->_compile( $node->{tokens} );
            }
        } else {
            if ( my $c = $self->can($node->{type}) ) {
                $self->debug( "$space calling " . $node->{type} . " on " . ($node->{content}  ? $node->{content} :"" ));
                $str .= $c->($node);
            } else {
                $self->debug( "$space calling " . $node->{type} . " on " . $node->{content} );
                warn "Unknown type " . $node->{type} . " returning content.";
                $str .= $node->{content};
            }
        }
    }
    return $str;
}

sub paragraph {
    my ( $node ) = @_;
    return "" unless length $node->{content} >= 1; 
    return "<p>" . $node->{content} . "</p>";
    my ( $content ) = @_;
    return "" unless $content;
    return "<p>$content</p>";
}

sub italic {
    my ( $node ) = @_;
    if ( ref $node ) {
        return "<em>" . $node->{content} . "</em>";
    } else {
        return "<em>$node</em>";
    }
}

sub blockquote {
    my ( $node ) = @_;
    return "<blockquote>" . $node->{content} . "</blockquote>";
}

sub code_block {
    my ( $node ) = @_;
    return "\n<pre language=" . $node->{language} . ">\n" . $node->{content} . "\n</pre>\n";
    print "Found node: ";
    print Dumper $node;
}

sub bold {
    my ( $node ) = @_;
    if ( ref $node ) {
        return "<strong>" . $node->{content} . "</strong>";
    } else {
        return "<strong>$node</strong>";
    }
}

sub url {
    my ( $node ) = @_;
    my $content = ref $node ? $node->{content} : $node;
    return "<a href=\"$content\">$content</a>"; 
}

sub link {
    my ( $node ) = @_;
    my $content = ref $node ? $node->{content} : $node;
    return '<a href="' . $node->{content} . '" title="' . $node->{title} .'">' . $node->{text} . "</a>" if $node->{title};
    return '<a href="' . $node->{content} . '">' . $node->{text} . "</a>";
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
