#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Text::GFMarkdown;

my $m = Text::GFMarkdown->new();

my $tests = [
    {
        in  => "Hello __world__.",
        out => "<p>Hello <em>world</em>.</p>",
        des => "Italic word with underscore.",
    },
    {
        in  => "__Hello world__.",
        out => "<p><em>Hello world</em>.</p>",
        des => "Italic phrase with underscore.",
    },
    {
        in  => "Hello *__world__*.",
        out => "<p>Hello <strong><em>world</em></strong>.</p>",
        des => "Italics inside of bold word.",
    },
    {
        in  => "*__Hello world__*.",
        out => "<p><strong><em>Hello world</em></strong>.</p>",
        des => "Italics inside of bold phrase with underline.",
    },
    {
        in  => "Hello **world**.",
        out => "<p>Hello <em>world</em>.</p>",
        des => "Italic word with atrerix.",
    },
    {
        in  => "**Hello world**.",
        out => "<p><em>Hello world</em>.</p>",
        des => "Italic phrase with asterix.",
    },
    {
        in  => "Hello ***world***.",
        out => "<p>Hello <strong><em>world</em></strong>.</p>",
        des => "Italics inside of bold word with asterix.",
    },
    {
        in  => "***Hello world***.",
        out => "<p><strong><em>Hello world</em></strong>.</p>",
        des => "Italics inside of bold phrase with asterix.",
    },
];

for my $test ( @{$tests} ) {
    ok( exists $test->{in},  "Missing input for test case." );
    ok( exists $test->{out}, "Missing output for test case." );
    ok( exists $test->{des}, "Missing description of test case." );
    is( $m->markdown($test->{in}), $test->{out}, $test->{des} );
}

done_testing;
