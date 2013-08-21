#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Text::GFMarkdown;

my $m = Text::GFMarkdown->new();

my $tests = [
    {
        in  => 'This is ![an example](http://example.com/image.jpeg "Title") inline image.',
        out => '<p>This is <img src="http://example.com/image.jpeg" title="Title" alt="an example"> inline image.</p>',
        des => "Image with title",
    },
    {
        in  => '![This image](http://example.net/image.jpeg) has no title attribute.',
        out => '<p><img src="http://example.net/image.jpeg" alt="This image"> has no title attribute.</p>',
        des => "Image without title",
    },
    {
        in  => '> This is ![an example](http://example.com/image.jpeg "Title") inline image.',
        out => '<blockquote><p>This is <img src="http://example.com/image.jpeg" title="Title" alt="an example"> inline image.</p></blockquote>',
        des => "Image with title",
    },
    {
        in  => '> ![This image](http://example.net/image.jpeg) has no title attribute.',
        out => '<blockquote><p><img src="http://example.net/image.jpeg" alt="This image"> has no title attribute.</p></blockquote>',
        des => "Image without title",
    },
];

for my $test ( @{$tests} ) {
    ok( exists $test->{in},  "Missing input for test case." );
    ok( exists $test->{out}, "Missing output for test case." );
    ok( exists $test->{des}, "Missing description of test case." );
    is( $m->markdown($test->{in}), $test->{out}, $test->{des} );
}

done_testing;
