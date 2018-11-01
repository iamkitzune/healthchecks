#Unix Health Check
#Jason Thomas
##########################################

use strict;
use warnings;
use diagnostics;
use Sys::Hostname;
use File::Find;

my $host = hostname;
