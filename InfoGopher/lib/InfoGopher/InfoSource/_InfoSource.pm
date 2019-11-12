package InfoGopher::InfoSource::_InfoSource ;
# role to prevent instantiation of incomplete InfoSources ;

use Moose::Role ;
 
requires 'fetch' ;

1;

 