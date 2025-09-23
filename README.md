# NAME

Attribute::Validate - Validate your subs with attributes

# SYNOPSIS

    use Attribute::Validate;

    use Types::Standard qw/Maybe InstanceOf ArrayRef Str/

    use feature 'signatures';

    sub install_gentoo: Requires(Maybe[ArrayRef[InstanceOf['Linux::Capable::Computer']]], Str) ($maybe_computers, $hostname) {
        # Do something here
    }

    install_gentoo([$computer1, $computer2], 'Tux');

# DESCRIPTION

This module allows you to validate your non-anonymous subs using the powerful attribute syntax of Perl, bringing easy type-checks to
your code, thanks to [Type::Tiny](https://metacpan.org/pod/Type%3A%3ATiny) you can create your own types to enforce your program using the data you expect it to use.

# INSTANCE METHODS

This module cannot and shouldn't be instanced.

# ATTRIBUTES

## Requires

    sub say_word: Requires(Str) {
        say shift;
    }

    sub say_word_with_spec: Requires(\%spec, Str) {
        say shift;
    }

Receives a list of [Type::Tiny](https://metacpan.org/pod/Type%3A%3ATiny) types and enforces those types into the arguments, the first argument may be a HashRef containing the
spec of [Type::Params](https://metacpan.org/pod/Type%3A%3AParams) to change the behavior of this module, for example {strictness => 0} as the first argument will allow the user
to have more arguments than the ones declared.

# DEPENDENCIES

The module will pull all the dependencies it needs on install, the minimum supported Perl is v5.16.3, although latest versions are mostly tested for 5.38.2

# CONFIGURATION AND ENVIRONMENT

If your OS Perl is too old perlbrew can be used instead.

# BUGS AND LIMITATIONS

Enchanting subroutines with attributes won't allow them to be used by this module because of limitations of the language.

# LICENSE AND COPYRIGHT

Copyright (c) 2025 Sergio Iglesias

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the " Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice (including the next paragraph) shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# CREDITS

Thanks to MultiSafePay and the Tech Leader of MultiSafePay for agreeing in creating this CPAN module inspired in a similar feature in their codebase, this code was inspired by code found there, but was
written without the code in front from scratch.

MultiSafePay is searching for Perl Developers for working in their offices on Estepona on Spain next to the beach, if you apply and do not get a reply and you think you are a 
experienced/capable enough Perl Developer drop me a e-mail so I can try to help you get a job [mailto:sergioxz@cpan.org](mailto:sergioxz@cpan.org).

# INCOMPATIBILITIES

None known.

# VERSION

0.0.x

# AUTHOR

Sergio Iglesias
