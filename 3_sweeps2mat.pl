#!/usr/bin/perl -X
#edge offset = +/- 6
# aerosol file

# v4=do not scale until the end
# v5= Langleys, see v5


		# LIBRARIES
print"PERL LIBRARY : $ENV{MYLIB}\n";
use lib $ENV{MYLIB};
use perltools::MRtime;
use perltools::MRutilities;
use perltools::MRradiation;
use perltools::MRstatistics;
use perltools::Prp;
use POSIX;
use File::Basename;





#a=[r3.s01 r3.s02 r3.s03 r3.s04 r3.s05 r3.s06 r3.s07 r3.s08 r3.s09 r3.s10  r3.s11 r3.s12 r3.s13 r3.s14 r3.s15 r3.s16 r3.s17 r3.s18 r3.s19 r3.s20 r3.s21 r3.s22 r3.s23];