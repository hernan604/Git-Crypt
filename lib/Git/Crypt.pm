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
        next if $_->{is_encrypted};
        my @lines_crypted =
          map { encode_base64 $self->cipher->encrypt($_); } io($_->{file})->getlines;
        io($_->{file})->print(@lines_crypted);
        $_->{is_encrypted} = 1;
    }
}

sub decrypt {
    my $self = shift;
    for ( @{ $self->files } ) {
        next if ! $_->{is_encrypted};
        my @lines_decrypted = map {
            my $line = decode_base64 $_;
            $self->cipher->decrypt($line);
        } io($_->{file})->getlines;
        io($_->{file})->print(@lines_decrypted);
        $_->{is_encrypted} = 0;
    }
}

sub add {
    my $self = shift;
    my $files = shift;
    my @current_files = map { $_->{ file } } @{ $self->files };
    map {
        print $_, "\n";
        my $file = $_;
        push @{ $self->files }, {file => $file, is_encrypted => 0 }
            if ! grep /^$file$/, @current_files;
    } @{$files};
}

sub del {
    my $self = shift;
    my $files = shift;
    map {
        my $file_to_del = $_;
        print $file_to_del, "\n";
        my $i = 0;
        for ( @{ $self->files } ) {
            if ( $_->{ file } eq $file_to_del ) {
                splice @{ $self->files }, $i, 1;
                last;
            }
            $i++;
        }
    } @{$files};
}

sub config {
    my $self = shift;
    return {
        files   => $self->files,
        cipher_name  => $self->cipher_name,
        key     => $self->key,
        salt    => $self->salt,
    };
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

