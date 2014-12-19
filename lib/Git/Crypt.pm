package Git::Crypt;
use strict;
use warnings;
use Moo;
use IO::All;
use Crypt::CBC;
use MIME::Base64;

has files       => ( is => 'rw', default => sub { [] } );
has salt        => ( is => 'rw', default => sub { 0 } );
has key         => ( is => 'rw', default => sub { 0 } );
has cipher_name => ( is => 'rw', default => sub { 'Blowfish' } );
has cipher      => (
    is      => "lazy",
    default => sub {
        my $self = shift;
        Crypt::CBC->new(
            -key    => $self->key,
            -cipher => $self->cipher_name,
            -salt   => pack( "H16", $self->salt )
        );
    }
);

sub encrypt {
    my $self = shift;
    for ( @{ $self->files } ) {
        my @lines_crypted =
          map { encode_base64 $self->cipher->encrypt($_); } io($_)->getlines;
        io($_)->print(@lines_crypted);
    }
}

sub decrypt {
    my $self = shift;
    for ( @{ $self->files } ) {
        my @lines_decrypted = map {
            my $line = decode_base64 $_;
            $self->cipher->decrypt($line);
        } io($_)->getlines;
        io($_)->print(@lines_decrypted);
    }
}

our $VERSION = 0.01;

=head1 NAME

Git::Crypt - Encrypt/decrypt sensitive files saved on public repos

=head1 SYNOPSIS

#Usage#1: Provide the cipher instance

  my $gitcrypt = Git::Crypt->new(
      files => [
          qw|
            file1
            file2
            |
      ],
      cipher => Crypt::CBC->new(
          -key      => 'a very very very veeeeery very long key',
          -cipher   => 'Blowfish',
          -salt     => pack("H16", "very very very very loooong salt")
      )
  );

  $gitcrypt->crypt;     #save files encrypted
  $gitcrypt->decrypt;   #save files decrypted

#Usage#2: Provide key, salt and cipher name

  my $gitcrypt = Git::Crypt->new(
      files => [
          qw|
            file1
            file2
            |
      ],
      key         => 'a very very very veeeeery very long key',
      cipher_name => 'Blowfish',
      salt        => pack("H16", "very very very very loooong salt")
  );

  $gitcrypt->crypt;     #save files encrypted
  $gitcrypt->decrypt;   #save files decrypted

=head1 DESCRIPTION

Git::Crypt can be used to encrypt files before a git commit. That way its possible to upload encrypted files to public repositories.
Git::Crypt encrypts line by line to prevent too many unnecessary diffs between encrypted commits.

=head1 AUTHOR

    Hernan Lopes
    CPAN ID: HERNAN
    perldelux
    hernanlopes@gmail.com
    http://www.perldelux.com

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut

1;

# The preceding line will help the module return a true value

