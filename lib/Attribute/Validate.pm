package Attribute::Validate;

use v5.16.0;

use strict;
use warnings;

use Attribute::Handlers;
use Type::Params qw/signature/;
use Carp::Always;
use Carp qw/confess/;

use parent 'Exporter';    # inherit all of Exporter's methods
our @EXPORT_OK = qw(anon_requires);

our $VERSION = "0.0.8";

{
    my %compilations_of_types;

    sub UNIVERSAL::Requires : ATTR(CODE) {
        no warnings 'redefine';
        no strict 'refs';
        my (
            $package, $symbol, $referent, $attr,
            $data,    $phase,  $filename, $linenum
        ) = @_;
        if ( $symbol eq 'ANON' ) {
            local $Carp::Internal{'Attribute::Validate'} = 1;
            confess "Unable to add signature to anon subroutine";
        }
        my $orig_sub = *{$symbol}{CODE};
        my $compiled = $compilations_of_types{$referent};
        if ( !defined $compiled ) {
            $compilations_of_types{$referent} = _requires_compile_types(@$data);
        }
        *{$symbol} =
          _requires_new_sub( $compilations_of_types{$referent}, $orig_sub );
    }
}

sub UNIVERSAL::ScalarContext : ATTR(CODE) {
    no warnings 'redefine';
    no strict 'refs';
    my (
        $package, $symbol, $referent, $attr,
        $data,    $phase,  $filename, $linenum
    ) = @_;
    if ( $symbol eq 'ANON' ) {
        local $Carp::Internal{'Attribute::Validate'} = 1;
        confess "Unable to add validation to anon subroutine";
    }
    my $orig_sub = *{$symbol}{CODE};
    *{$symbol} = sub {
        local $Carp::Internal{'Attribute::Validate'} = 1;
        if ( !defined wantarray  ) {
            confess 'The return of this sub must be used in scalar context';
        }
        if (wantarray) {
            confess 'The return of this sub must be used in scalar context';
        }
        goto &$orig_sub;
    }
}

sub UNIVERSAL::NoScalarContext : ATTR(CODE) {
    no warnings 'redefine';
    no strict 'refs';
    my (
        $package, $symbol, $referent, $attr,
        $data,    $phase,  $filename, $linenum
    ) = @_;
    if ( $symbol eq 'ANON' ) {
        local $Carp::Internal{'Attribute::Validate'} = 1;
        confess "Unable to add validation to anon subroutine";
    }
    my $orig_sub = *{$symbol}{CODE};
    *{$symbol} = sub {
        local $Carp::Internal{'Attribute::Validate'} = 1;
        if ( !defined wantarray  ) {
            goto &$orig_sub;
        }
        if (wantarray) {
            goto &$orig_sub;
        }
        confess 'The return of this sub must never be used in scalar context';
    }
}

sub UNIVERSAL::ListContext : ATTR(CODE) {
    no warnings 'redefine';
    no strict 'refs';
    my (
        $package, $symbol, $referent, $attr,
        $data,    $phase,  $filename, $linenum
    ) = @_;
    if ( $symbol eq 'ANON' ) {
        local $Carp::Internal{'Attribute::Validate'} = 1;
        confess "Unable to add validation to anon subroutine";
    }
    my $orig_sub = *{$symbol}{CODE};
    *{$symbol} = sub {
        local $Carp::Internal{'Attribute::Validate'} = 1;
        if ( !wantarray ) {
            confess 'The return of this sub must be used in list context';
        }
        goto &$orig_sub;
    }
}

sub UNIVERSAL::NoListContext : ATTR(CODE) {
    no warnings 'redefine';
    no strict 'refs';
    my (
        $package, $symbol, $referent, $attr,
        $data,    $phase,  $filename, $linenum
    ) = @_;
    if ( $symbol eq 'ANON' ) {
        local $Carp::Internal{'Attribute::Validate'} = 1;
        confess "Unable to add validation to anon subroutine";
    }
    my $orig_sub = *{$symbol}{CODE};
    *{$symbol} = sub {
        local $Carp::Internal{'Attribute::Validate'} = 1;
        if ( wantarray ) {
            confess 'The return of this sub must never be used in list context';
        }
        goto &$orig_sub;
    }
}

sub UNIVERSAL::NoVoidContext : ATTR(CODE) {
    no warnings 'redefine';
    no strict 'refs';
    my (
        $package, $symbol, $referent, $attr,
        $data,    $phase,  $filename, $linenum
    ) = @_;
    if ( $symbol eq 'ANON' ) {
        local $Carp::Internal{'Attribute::Validate'} = 1;
        confess "Unable to add validation to anon subroutine";
    }
    my $orig_sub = *{$symbol}{CODE};
    *{$symbol} = sub {
        local $Carp::Internal{'Attribute::Validate'} = 1;
        if ( !defined wantarray ) {
            confess 'The return of this sub must be used or stored';
        }
        goto &$orig_sub;
    }
}

sub UNIVERSAL::VoidContext : ATTR(CODE) {
    no warnings 'redefine';
    no strict 'refs';
    my (
        $package, $symbol, $referent, $attr,
        $data,    $phase,  $filename, $linenum
    ) = @_;
    if ( $symbol eq 'ANON' ) {
        local $Carp::Internal{'Attribute::Validate'} = 1;
        confess "Unable to add validation to anon subroutine";
    }
    my $orig_sub = *{$symbol}{CODE};
    *{$symbol} = sub {
        local $Carp::Internal{'Attribute::Validate'} = 1;
        if ( defined wantarray ) {
            confess 'It is forbidden to store or use the return of this sub';
        }
        goto &$orig_sub;
    }
}

sub _requires_compile_types {
    my $data = [];
    @$data = @_;
    my %extra_options;
    if ( 'HASH' eq ref $data->[0] ) {
        %extra_options = %{ shift @$data };
    }
    return signature( %extra_options, positional => $data );
}

sub anon_requires {
    my $orig_sub = shift;
    if ( !defined $orig_sub || 'CODE' ne ref $orig_sub ) {
        die 'Anon requires didn\'t receive a sub';
    }
    my $compiled = _requires_compile_types(@_);
    return _requires_new_sub( $compiled, $orig_sub );
}

sub _requires_new_sub {
    my ( $compiled, $orig_sub ) = @_;
    if ( !defined $orig_sub ) {
        die 'Didn\'t receive a sub';
    }
    return sub {
        local $Carp::Internal{'Attribute::Validate'} = 1;
        eval { $compiled->(@_); };
        if ($@) {
            confess _filter_error("$@");
        }
        goto &$orig_sub;
    };
}

sub _filter_error {
    my $error = shift;
    $error =~ s{at lib/Attribute/Validate.pm line \d+}{}g;
    return $error;
}
1;

=encoding utf8

=head1 NAME

Attribute::Validate - Validate your subs with attributes

=head1 SYNOPSIS

    use Attribute::Validate;

    use Types::Standard qw/Maybe InstanceOf ArrayRef Str/

    use feature 'signatures';

    sub install_gentoo: Requires(Maybe[ArrayRef[InstanceOf['Linux::Capable::Computer']]], Str) ($maybe_computers, $hostname) {
        # Do something here
    }

    install_gentoo([$computer1, $computer2], 'Tux');

=head1 DESCRIPTION

This module allows you to validate your non-anonymous subs using the powerful attribute syntax of Perl, bringing easy type-checks to
your code, thanks to L<Type::Tiny> you can create your own types to enforce your program using the data you expect it to use.

=head1 INSTANCE METHODS

This module cannot and shouldn't be instanced.

=head1 ATTRIBUTES

=head2 Requires

    sub say_word: Requires(Str) {
        say shift;
    }

    sub say_word_with_spec: Requires(\%spec, Str) {
        say shift;
    }

Receives a list of L<Type::Tiny> types and enforces those types into the arguments, the first argument may be a HashRef containing the
spec of L<Type::Params> to change the behavior of this module, for example {strictness => 0} as the first argument will allow the user
to have more arguments than the ones declared.

=head2 VoidContext

    sub doesnt_return: VoidContext {
    }
    my $lawless = doesnt_return(); # Dies
    doesnt_return(); # Works

Enforces the caller to use this sub in Void Context and do nothing with the return to avoid programmer errors and incorrect assumptions.

=head2 NoVoidContext

    sub returns: NoVoidContext {
    }
    my $lawful = returns(); # Works
    returns(); # Dies

Enforces the caller to do something with the return of a sub to avoid programmer errors and assumptions.

=head2 ListContext

    sub only_use_in_list_context: ListContext {
        return (0..10);
    }
    my $list = only_use_in_list_context(); # Dies
    only_use_in_list_context(); # Dies
    my @list = only_use_in_list_context(); # Works

Enforces the caller to use the subroutine in List Context to prevent errors and misunderstandings.

=head2 NoListContext

    sub never_use_in_list_context: NoListContext {
        return 'scalar_or_void';
    }
    my $list = never_use_in_list_context(); # Works
    never_use_in_list_context(); # Works
    my @list = never_use_in_list_context(); # Dies

Enforces the caller to never use the subroutine in List Context to prevent errors and misunderstandings.

=head2 ScalarContext

    sub only_use_in_scalar_context: ScalarContext {
        return 'hey';
    }
    my @scalar = only_use_in_scalar_context(); # Dies
    only_use_in_scalar_context(); # Dies
    my $scalar = only_use_in_scalar_context(); # Works

Enforces the caller to use the subroutine in Scalar Context to prevent errors and misunderstandings.

=head2 NoScalarContext

    sub never_scalar_context: NoScalarContext {
        return @array;
    }
    my @list = never_scalar_context(); # Works
    never_scalar_context(); # Works
    my $scalar = never_scalar_context(); # Dies

Enforces the caller to never use the subroutine in Scalar Context to prevent errors and misunderstandings.

=head1 EXPORTABLE SUBROUTINES

=head2 anon_requires

    my $say_thing = anon_requires(sub($thing) {
        say $thing;
    ), Str);

    my $say_thing = anon_requires(sub($thing) {
        say $thing;
    }, \%spec, Str);

Enforces types into anonymous subroutines since those cannot be enchanted using attributes.

=head1 DEPENDENCIES

The module will pull all the dependencies it needs on install, the minimum supported Perl is v5.16.3, although latest versions are mostly tested for 5.38.2

=head1 CONFIGURATION AND ENVIRONMENT

If your OS Perl is too old perlbrew can be used instead.

=head1 BUGS AND LIMITATIONS

Enchanting anonymous subroutines with attributes won't allow them to be used by this module because of limitations of the language.

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2025 by Sergio Iglesias.

This is free software, licensed under:

  The MIT (X11) License

=head1 CREDITS

Thanks to MultiSafePay and the Tech Leader of MultiSafePay for agreeing in creating this CPAN module inspired in a similar feature in their codebase, this code was inspired by code found there, but was
written without the code in front from scratch.

MultiSafePay is searching for Perl Developers for working in their offices on Estepona on Spain next to the beach, if you apply and do not get a reply and you think you are a 
experienced/capable enough Perl Developer drop me a e-mail so I can try to help you get a job L<mailto:sergioxz@cpan.org>.

=head1 INCOMPATIBILITIES

None known.

=head1 VERSION

0.0.x

=head1 AUTHOR

Sergio Iglesias

=cut
