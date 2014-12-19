use Test::More;
use Git::Crypt;
use Crypt::CBC;
use Digest::SHA1 qw|sha1_hex|;
use IO::All;

my $files = {
    './t/file1' => undef,
    './t/file2' => undef,
};

for ( keys %$files ) {
    $files->{ $_ } = sha1_hex( io( $_ )->getlines );
}

my $gitcrypt = Git::Crypt->new(
    files => [
        keys %$files
    ],
    cipher => Crypt::CBC->new(
        -key      => 'a very very very veeeeery very long key',
        -cipher   => 'Blowfish',
        -salt     => pack("H16", "very very very very loooong salt")
    )
);

$gitcrypt->crypt;
$gitcrypt->decrypt;

for ( keys %$files ) {
    ok( sha1_hex(io($_)->getlines) eq $files->{ $_ }, 'same digest as the original' );
}

done_testing;
