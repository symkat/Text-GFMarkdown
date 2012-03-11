#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Text::GFMarkdown;

my $m = Text::GFMarkdown->new();

my $tests = [
    {
        in  => "> Hello World",
        out => "<blockquote>Hello World</blockquote>",
        des => "One line blockquote.",
    },
];

for my $test ( @{$tests} ) {
    ok( exists $test->{in},  "Missing input for test case." );
    ok( exists $test->{out}, "Missing output for test case." );
    ok( exists $test->{des}, "Missing description of test case." );
    is( $m->markdown($test->{in}), $test->{out}, $test->{des} );
}

done_testing;
