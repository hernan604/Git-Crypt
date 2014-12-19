

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Git::Crypt',
    VERSION_FROM => 'lib/Git/Crypt.pm', # finds \$VERSION
    AUTHOR       => 'Hernan Lopes (hernanlopes@gmail.com)',
    ABSTRACT     => 'Encrypt/decrypt sensitive files before commit and save on public repos',
    PREREQ_PM    => {
                        'Test::Simple'  => 0.44,
                        'Moo'           => 0,
                        'IO::All'       => 0,
                        'Crypt::CBC'    => 0,
                        'Crypt::Blowfish'   => 0,
                        'MIME::Base64'  => 0,
                        'Digest::SHA1'  => 0,
                    },
);
