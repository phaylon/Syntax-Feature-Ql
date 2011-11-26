use strictures 1;
use Test::More;

use syntax qw( ql );

subtest "ql" => sub {
    is ql{foo}, 'foo', 'simple string';
    is ql{
        foo
        bar
    }, 'foo bar', 'multiline string';
    is ql{
        $foo
        $bar
    }, '$foo $bar', 'ql{} is a real q{}';
    is ql!
        foo
        bar
    !, 'foo bar', 'different quotesigns';
    is_deeply [ 23, \ql/52/, 17 ], [23, \52, 17], 'can be referenced';
    is sprintf(ql{
        foo: %d,
        bar: %d
    }, 23, 17), 'foo: 23, bar: 17', 'with sprintf';
    is ql 2 8 2, q 2 8 2, 'spaced and numerical delimiters';
    done_testing;
};

subtest "qql" => sub {
    is qql{foo}, 'foo', 'simple string';
    is qql{
        foo
        bar
    }, 'foo bar', 'multiline string';
    my ($foo, $bar) = (23, 17);
    is qql{
        $foo
        $bar
    }, '23 17', 'qql{} is a real qq{}';
    is qql!
        foo
        bar
    !, 'foo bar', 'different quotesigns';
    is_deeply [ 23, \qql/52/, 17 ], [23, \52, 17], 'can be referenced';
    done_testing;
};

done_testing;
