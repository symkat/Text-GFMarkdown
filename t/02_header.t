#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Text::GFMarkdown;

my $m = Text::GFMarkdown->new();

my $tests = [
    {
        in  => "# Hello World\n",
        out => "<h1>Hello World</h1>",
        des => "H1",
    },
    {
        in  => "## Hello World\n",
        out => "<h2>Hello World</h2>",
        des => "H2",
    },
    {
        in  => "### Hello World\n",
        out => "<h3>Hello World</h3>",
        des => "H3",
    },
    {
        in  => "#### Hello World\n",
        out => "<h4>Hello World</h4>",
        des => "H4",
    },
    {
        in  => "##### Hello World\n",
        out => "<h5>Hello World</h5>",
        des => "H5",
    },
    {
        in  => "###### Hello World\n",
        out => "<h6>Hello World</h6>",
        des => "H6",
    },
];

for my $test ( @{$tests} ) {
    ok( exists $test->{in},  "Missing input for test case." );
    ok( exists $test->{out}, "Missing output for test case." );
    ok( exists $test->{des}, "Missing description of test case." );
    is( $m->markdown($test->{in}), $test->{out}, $test->{des} );
}

done_testing;
