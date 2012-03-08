#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Text::GFMarkdown;

my $m = Text::GFMarkdown->new();

my $tests = [
    {
        in  => "Hello _world_.",
        out => "<p>Hello <strong>world</strong>.</p>",
        des => "Bold word with underline.",
    },
    {
        in  => "_Hello world_.",
        out => "<p><strong>Hello world</strong>.</p>",
        des => "Bold phrase with underline.",
    },
    {
        in  => "Hello _world_.",
        out => "<p>Hello <strong>world</strong>.</p>",
        des => "Bold word with asterix.",
    },
    {
        in  => "_Hello world_.",
        out => "<p><strong>Hello world</strong>.</p>",
        des => "Bold phrase with asterix.",
    },
];

for my $test ( @{$tests} ) {
    ok( exists $test->{in},  "Missing input for test case." );
    ok( exists $test->{out}, "Missing output for test case." );
    ok( exists $test->{des}, "Missing description of test case." );
    is( $m->markdown($test->{in}), $test->{out}, $test->{des} );
}

done_testing;
