#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Text::GFMarkdown;

my $m = Text::GFMarkdown->new();

my $tests = [
    {
        des => "Metadata is not rendered",
        in  => "---\ntitle: Hello World\n---\n\nHello World",
        out => "<p>Hello World</p>",
    },
    {
        in  => "---\ntitle: Hello World\n---\n\nHello World",
        out => "<p>Hello World</p>",
        des => "Single element meta data is collected.",
        metadata => {
            title => 'Hello World',
        },
    },
    {
        in  => "---\ntitle: Hello World\ndate: 2020-09-13 5:40 PM\n---\n\nHello World",
        out => "<p>Hello World</p>",
        des => "Single element meta data is collected.",
        metadata => {
            title => 'Hello World',
            date  => '2020-09-13 5:40 PM',
        },
    },
];

for my $test ( @{$tests} ) {
    ok( exists $test->{in},  "Missing input for test case." );
    ok( exists $test->{out}, "Missing output for test case." );
    ok( exists $test->{des}, "Missing description of test case." );
    is( $m->markdown($test->{in}), $test->{out}, $test->{des} );
    if ( $test->{metadata} ) {
        is_deeply( $m->metadata($test->{in}), $test->{metadata}, "Metadata: " . $test->{des} );
    }
}

done_testing;
