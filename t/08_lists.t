#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Text::GFMarkdown;

my $m = Text::GFMarkdown->new();

my $tests = [
    {
        in  => "* Hello World",
        out => "<ul><li>Hello World</li></ul>",
        des => "Single item",
    },
    {
        in  => "* Hello World\n* This is another",
        out => "<ul><li>Hello World</li><li>This is another</li></ul>",
        des => "Two items",
    },
    {
        in  => "Hello World\n\n* This is another\n\nThis isn't a list item.",
        out => "<p>Hello World</p><ul><li>This is another</li></ul><p>This isn't a list item.</p>",
        des => "Items with paragraphs around them.",
    },
    {
        in  => "> * Hello World",
        out => "<blockquote><p><ul><li>Hello World</li></ul></p></blockquote>",
        des => "List inside a blockquote.",
    },
];

for my $test ( @{$tests} ) {
    ok( exists $test->{in},  "Missing input for test case." );
    ok( exists $test->{out}, "Missing output for test case." );
    ok( exists $test->{des}, "Missing description of test case." );
    is( $m->markdown($test->{in}), $test->{out}, $test->{des} );
}

done_testing;
