#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Text::GFMarkdown;

my $m = Text::GFMarkdown->new();

my $tests = [
    {
        in  => "Hello World",
        out => "<p>Hello World</p>",
        des => "Single paragraph.",
    },
    {
        in  => "Hello World\nHello World",
        out => "<p>Hello World<br />Hello World</p>",
        des => "Single new-line treated as break.",
    },
    {
        in  => "Hello World\n\nNew World",
        out => "<p>Hello World</p><p>New World</p>",
        des => "Double Line break treated as new paragraph.",
    },
    {
        in  => "Hello World\n\nNew World\n\n",
        out => "<p>Hello World</p><p>New World</p>",
        des => "Extra line breaks are ignored for paragraphs.",
    },
    {
        in  => "Hello World\n\nNew World\n",
        out => "<p>Hello World</p><p>New World</p>",
        des => "Extra line breaks are dropped.",
    },
];

for my $test ( @{$tests} ) {
    ok( exists $test->{in},  "Missing input for test case." );
    ok( exists $test->{out}, "Missing output for test case." );
    ok( exists $test->{des}, "Missing description of test case." );
    is( $m->markdown($test->{in}), $test->{out}, $test->{des} );
}

done_testing;
