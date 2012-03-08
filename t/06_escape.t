#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Text::GFMarkdown;

my $m = Text::GFMarkdown->new();

my $tests = [
    {
        in  => '\\',
        out => '<p>\</p>',
        des => 'Escaping \\',
    },
    {
        in  => '\`',
        out => '<p>`</p>',
        des => 'Escaping `',
    },
    {
        in  => '\*',
        out => '<p>*</p>',
        des => 'Escaping *',
    },
    {
        in  => '\_',
        out => '<p>_</p>',
        des => 'Escaping _',
    },
    {
        in  => '\{',
        out => '<p>{</p>',
        des => 'Escaping {',
    },
    {
        in  => '\}',
        out => '<p>}</p>',
        des => 'Escaping }',
    },
    {
        in  => '\[',
        out => '<p>[</p>',
        des => 'Escaping [',
    },
    {
        in  => '\]',
        out => '<p>]</p>',
        des => 'Escaping ]',
    },
    {
        in  => '\(',
        out => '<p>(</p>',
        des => 'Escaping (',
    },
    {
        in  => '\)',
        out => '<p>)</p>',
        des => 'Escaping )',
    },
    {
        in  => '\#',
        out => '<p>#</p>',
        des => 'Escaping #',
    },
    {
        in  => '\+',
        out => '<p>+</p>',
        des => 'Escaping +',
    },
    {
        in  => '\-',
        out => '<p>-</p>',
        des => 'Escaping -',
    },
    {
        in  => '\.',
        out => '<p>.</p>',
        des => 'Escaping .',
    },
    {
        in  => '\!',
        out => '<p>!</p>',
        des => 'Escaping !',
    },

];

for my $test ( @{$tests} ) {
    ok( exists $test->{in},  "Missing input for test case." );
    ok( exists $test->{out}, "Missing output for test case." );
    ok( exists $test->{des}, "Missing description of test case." );
    is( $m->markdown($test->{in}), $test->{out}, $test->{des} );
}

done_testing;
