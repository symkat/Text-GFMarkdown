#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Text::GFMarkdown;

my $m = Text::GFMarkdown->new();

my $tests = [
    {
        in  => "That one http://google.com/",
        out => "<p>That one <a href=\"http://google.com/\">http://google.com/</a></p>",
        des => "Autolinking full HTTP addresses.",
    },
    {
        in  => "That one __ http://google.com/ __",
        out => "<p>That one <em> <a href=\"http://google.com/\">http://google.com/</a> </em></p>",
        des => "Autolinking full HTTP addresses inside italics.",
    },
];

for my $test ( @{$tests} ) {
    ok( exists $test->{in},  "Missing input for test case." );
    ok( exists $test->{out}, "Missing output for test case." );
    ok( exists $test->{des}, "Missing description of test case." );
    is( $m->markdown($test->{in}), $test->{out}, $test->{des} );
}

done_testing;
