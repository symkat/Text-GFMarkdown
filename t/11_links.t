#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Text::GFMarkdown;

my $m = Text::GFMarkdown->new();

my $tests = [
    {
        in  => 'This is [an example](http://example.com/ "Title") inline link.',
        out => '<p>This is <a href="http://example.com/" title="Title">an example</a> inline link.</p>',
        des => "Link with title",
    },
    {
        in  => '[This link](http://example.net/) has no title attribute.',
        out => '<p><a href="http://example.net/">This link</a> has no title attribute.</p>',
        des => "Link without title",
    },
    {
        in  => '> This is [an example](http://example.com/ "Title") inline link.',
        out => '<blockquote><p>This is <a href="http://example.com/" title="Title">an example</a> inline link.</p></blockquote>',
        des => "Link with title in bloack quote",
    },
    {
        in  => '> [This link](http://example.net/) has no title attribute.',
        out => '<blockquote><p><a href="http://example.net/">This link</a> has no title attribute.</p></blockquote>',
        des => "Link without title in blockquotes",
    },
];

for my $test ( @{$tests} ) {
    ok( exists $test->{in},  "Missing input for test case." );
    ok( exists $test->{out}, "Missing output for test case." );
    ok( exists $test->{des}, "Missing description of test case." );
    is( $m->markdown($test->{in}), $test->{out}, $test->{des} );
}

done_testing;
