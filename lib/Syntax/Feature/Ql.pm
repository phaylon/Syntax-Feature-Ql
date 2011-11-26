use strictures 1;

# ABSTRACT: Turns the quoted string into a single line

package Syntax::Feature::Ql;
use Devel::Declare ();
use B::Hooks::EndOfScope;
use Sub::Install            qw( install_sub );

use aliased 'Devel::Declare::Context::Simple', 'Context';

use syntax qw( simple/v2 );
use namespace::clean;

my @NewOps  = qw( ql qql );
my %QuoteOp = (ql => 'q', qql => 'qq');

method install ($class: %args) {
    my $target = $args{into};
    Devel::Declare->setup_for($target => {
        map {
            my $name = $_;
            ($name => {
                const => sub {
                    my $ctx = Context->new;
                    $ctx->init(@_);
                    return $class->_transform($name, $ctx);
                },
            });
        } @NewOps,
    });
    for my $name (@NewOps) {
        install_sub {
            into => $target,
            as   => $name,
            code => $class->_run_callback,
        };
    }
    on_scope_end {
        namespace::clean->clean_subroutines($target, @NewOps);
    };
    return 1;
}

method _run_callback {
    return sub ($) {
        my $string = shift;
        $string =~ s{(?:^\s+|\s+$)}{}gsm;
        return join ' ', split m{\s*\n\s*}, $string;
    };
}

method _transform ($class: $name, $ctx) {
    $ctx->skip_declarator;
    my $linestr = $ctx->get_linestr;
    substr($linestr, $ctx->offset, 0) = ' ' . $QuoteOp{$name};
    $ctx->set_linestr($linestr);
    return 1;
}

1;

__END__

=head1 SYNOPSIS

    use syntax qw( ql );

    # prints on one line
    say ql{
        Do you know the feeling when you want to generate a long
        string for a message without having to concatenate or end
        up with newlines and indentation?
    };

=head1 DESCRIPTION

This is a syntax extension feature suitable for L<syntax>.

It provides two new quote-like operators named C<ql> and C<qql>. These
work in the same way as C<q> and C<qq> (including the ability to change
the delimiters), except they put the returned string on a single line.

The following all output C<foo bar baz>:

    # simple
    say ql{foo bar baz};

    # multiline
    say ql{
        foo
        bar
        baz
    };

    # different delimiters and interpolation
    my $qux = q{ # <- this is a normal quote!
        bar
        baz
    };
    say qql!
        foo
        $qux
    !;

As you can see with the last example, interpolated values are also
normalized to fit on the single line.

=method install

    Syntax::Feature::Ql->install( into => $target );

Installs the C<ql> and C<qql> operators into the C<$target>.

=head1 SEE ALSO

=over

=item * L<syntax>

=item * L<perlop>

=back

=cut
