#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Text::GFMarkdown;

my $m = Text::GFMarkdown->new();

my $tests = [
    {
        in  => "> Hello World",
        out => "<blockquote><p>Hello World</p></blockquote>",
        des => "One line blockquote.",
    },
    {
        in  => "> Hello World\n> > Again",
        out => "<blockquote><p>Hello World\n</p><blockquote><p>Again</p></blockquote></blockquote>",
        des => "Multiple Lines.",
    },
#    {
#        in  => "> Hello World\n\n> > Again",
#        out => "<blockquote><p>Hello World</p><blockquote>"
#            . "\n<p>Again</p>\n</blockquote>\n</blockquote>\n",
#        des => "Multiple new lines.",
#    },
#    {
#        in  => "> Hello World\n\n> > # Again",
#        out => "<blockquote>\n<p>Hello World</p>\n\n<blockquote>\n" 
#            . "<h1>Again</h1>\n</blockquote>\n</blockquote>\n",
#        des => "With a header.",
#    }

];

for my $test ( @{$tests} ) {
    ok( exists $test->{in},  "Missing input for test case." );
    ok( exists $test->{out}, "Missing output for test case." );
    ok( exists $test->{des}, "Missing description of test case." );
    is( $m->markdown($test->{in}), $test->{out}, $test->{des} );
}

done_testing;
