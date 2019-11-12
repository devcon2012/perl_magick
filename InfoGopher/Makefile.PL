use 5.026001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'InfoGopher',
    VERSION_FROM      => 'lib/InfoGopher.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
    PREREQ_PM         => { Moose => 1}, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/InfoGopher.pm', # retrieve abstract from module
    AUTHOR            => 'Klaus Ramstöck <klaus@ramstoeck.name>',
    LICENSE           => 'perl',
);
