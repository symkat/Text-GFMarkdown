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
    {
        in  => "5 * 3 * 4",
        out => "<p>5 * 3 * 4</p>",
        des => "Normal multiplication when space proceeds.",
    },
    {
        in  => "5 * 3",
        out => "<p>5 * 3</p>",
        des => "Normal multiplication when space proceeds.",
    },
    {
        in  => "*Hello World*",
        out => "<p><strong>Hello World</strong></p>",
        des => "Bold when * is list elem.",
    },
    {
        in  => "*Hello* World",
        out => "<p><strong>Hello</strong> World</p>",
        des => "Bold works with space after closing.",
    },
    {
        in  => "Hello *World*",
        out => "<p>Hello <strong>World</strong></p>",
        des => "Bold works with space before opening.",
    }
];

for my $test ( @{$tests} ) {
    ok( exists $test->{in},  "Missing input for test case." );
    ok( exists $test->{out}, "Missing output for test case." );
    ok( exists $test->{des}, "Missing description of test case." );
    is( $m->markdown($test->{in}), $test->{out}, $test->{des} );
}

done_testing;
