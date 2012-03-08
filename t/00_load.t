#!/usr/bin/perl
use warnings;
use strict;
use Test::More;

my @classes = qw(
    Text::GFMarkdown 
    Text::GFMarkdown::Lex 
    Text::GFMarkdown::Parse
    Text::GFMarkdown::Format
    Regexp::Common::URI
);

for my $class ( @classes ) {
    use_ok $class;
}

done_testing;
