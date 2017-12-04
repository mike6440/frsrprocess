#!/usr/bin/perl -X

#call: ./1_frsr_raw2flat.pl rawfilename
# e.g. ./1_frsr_raw2flat.pl Icapture.txt

		# LIBRARIES
use lib $ENV{MYLIB};
use perltools::MRtime;
use perltools::MRutilities;
use perltools::MRradiation;
use perltools::MRstatistics;
use perltools::Prp;
use File::stat;

use Time::Zone;
my $offset_sec = tz_local_offset(); # or tz_offset($tz) if you have the TZ
                                    # in a variable and it is not local
	# VARIABLES
my ($sb, $hdr0);
my ($setupfile,$datapath,$timeseriespath,$imagepath,$home);
my ($str,$str1,$cmd,$dtstart,$dtend,$seccorrect,$fout,$rawfile,$nrec,$nread,$dt);
my ($i, $ic, $cmd, $strout, $nbadcheck);
my ($mode,$imin);
my ($strout1,$strout2,$strout3,$strout4,$strout5,$strout6,$strout7);
my (@w,@sw);
my $nbadcheck=0;
	# INITIALIZE 
$nread=0; # total number of $FSR03 records
$nrec=0; # record written to the output, da0, file. 
$nhigh=0;  #packets in high/transition mode
		# SETUPFILE
$setupfile='0_initialize_frsr_process.txt';
chomp($setupfile);
if(-f $setupfile){
	#print"EXISTS.\n";
} else {
	print"SETUP FILE = $setupfile   ";
	print"DOES NOT EXIST. STOP.\n";
}
	# DATAPATH 
my $datapath = FindInfo($setupfile,'DATAPATH',':');
if ( ! -d $datapath ) { 
	print "DATAPATH = $datapath   ";
	print"DOES NOT EXIST. STOP.\n"; exit 1}
#else {print "EXISTS.\n"}
	# TIMESERIESPATH
my $timeseriespath = FindInfo($setupfile,'TIMESERIESPATH',':');
if ( ! -d $timeseriespath ) { 
	print "TIMESERIESPATH = $timeseriespath  ";
	print"DOES NOT EXIST. CREATE.\n";
	system "mkdir $timeseriespath";
}
	# IMAGESPATH
my $imagespath = FindInfo($setupfile,'IMAGESPATH',':');
if ( ! -d $imagespath ) { 
	print "IMAGESPATH = $imagespath   ";
	print"DOES NOT EXIST. CREATE.\n";
	system "mkdir $imagespath";
}
	# TIME CORRECTION
$seccorrect=FindInfo($setupfile,'TIMECORRECTSECS');
# print"seccorrect=$seccorrect\n";
	# START TIME
$starttime = FindInfo($setupfile,'STARTTIME');
$cmd=sprintf "\$dtstart = datesec($starttime);";
eval $cmd;
printf"starttime = %s\n", dtstr($dtstart);
	# END TIME
$endtime = FindInfo($setupfile,'ENDTIME');
$cmd=sprintf "\$dtend = datesec($endtime);";
eval $cmd;
printf"endtime = %s\n", dtstr($dtend);
	# HEADER FILE, SETUPFILE FROM START TO END
$str= ">$timeseriespath/header.txt";
print"HEADER $str\n";
open F,$str  or die;
print F "$hdr0\n";
print F "SETUP FILE $setupfile\n";
open F1,$setupfile or die;
while(<F1>){if($_ =~ /START-SETUP/){last}}
while(<F1>){
	chomp($str=$_);
	if($str =~ /END-SETUP/){last}
	print F "$str\n";
}
AddHeader();
close F1; close F;

	# DA0 RAW INTERP FILE
$fout = $timeseriespath."/da0raw.txt";
print"OUTPUT: $fout\n";
open Fout,">$fout" or die;
printf Fout "Program $0,      Run time:%s\n", dtstr(now(),'short');
print Fout
"mode,yyyy,MM,dd,hh,mm,ss,lat,lon,sog,cog,thead,t1,t2,p1,p2,r1,r2,shad,shadlim,saz,sze,g11,g12,g21,g22,g31,g32,g41,g42,g51,g52,g61,g62,g71,g72\n";
	# DAn SWEEP CHANNELS --> da1raw.txt, da2raw.txt, ..., da7raw.txt
for($ic=1; $ic<=7; $ic++){
	$fout = $timeseriespath."/da".$ic."raw.txt";
	$str=sprintf"open R%d,\">%s\" or die;",$ic, $fout;
	#print"$str\n";
	eval $str;
	$str=sprintf"printf R%d \"Program \$0,  Chan %d,    Run time:%s\\n\";",$ic,$ic,dtstr(now(),'short');
	#print"$str\n";
	eval $str;
	$str=sprintf"print R%d \"yyyy,MM,dd,hh,mm,ss,lat,lon,saz,sze,shad,g1,g2,  s01,s02,s03,s04,s05,s06,s07,s08,s09,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s20,s21,s22,s23\\n\";",$ic;
	#print"$str\n";
	eval $str;
}

	# PROCESS ALL FILES
	# After download from Fetch the tar files are opened and have names such as "marfrsrM1.00.20171029.001001.raw.txt Folder"
	# find ~/data/20171028_marcus_v1/frsr/*.raw*Folder -iname marfrsr*_interp_* -print
@f = `find $datapath/*.raw*Folder -iname marfrsr*_interp_* -print`;
foreach(@f){print"$_\n"} die;
foreach $f (@f) {
	chomp $f;
# 	$sb=stat($f);
# 	$ftime=$sb->mtime-$offset_sec;
# 	printf"File %s, mtimeZ %s\n",$f, dtstr($ftime,'short');
		#  Find starting folder
		#/Users/rmr/data/frsr/171024_vtrials/archive/data/data_20171020T232831Z/frsr_interp_1710202328.txt
		# PROPER FILE NAMES
	if ( $f =~ /20......T......Z/ ){  # pull folder time
		$ix=index($f,"201");
		$fdt=dtstr2dt(substr($f,$ix,16));
		#printf"index = $ix, %s, %s\n", substr($f,$ix,16), dtstr($fdt);
			# FILE TIME > STARTTIME 
		if($dtstart > $fdt) {
			#print"Skip $f\n";
		}else{
				# OPEN AND SCAN THE FILE
			print "OPEN: $f\n";
			open FIN, $f or die("trying\n");
			#================
			# FIND THE FIRST LINE MODE
			#H, 2017,05,27,17,20,15,  35.84968, -106.27295, 0.0, 0.0, 0.0, 1.0, 0.18, 0.18, -0.03, -0.02, 21.6,  10.0
			#L, 2017,05,26,22,56,46,  35.84973, -106.27273, 0.0, 311.4, 50.5, 23.6, 0.85, 0.83, 0.70, 0.68, 0.0,  10.0
			#H, 2017,10,20,23,28,30,  -42.88256, 147.33966, 0.0, 0.0, 0.0, 1.0, -0.62, -0.91, -0.82, -0.90, 409.4,  20.0
			#================
			while(<FIN>){
				chomp($str=$_);
				$nread++;
				if( $str=~/^H/ || $str=~/^L/ || $str=~/^T/){
						# RECORD TIME > STARTTIME
					$recorddt = dtstr2dt(substr($str,3,19));
					if($recorddt >= $dtstart) {
							#=====================
							# PROCESS DA0 DATA -- occurs on each cycle
							#=====================
						$nrec++;
							# EPHEM
						@w=split /[ ,]+/g,$str;  # parse original head record
						($saz,$ze,$ze0) = Ephem($w[7], $w[8], $recorddt);
						$str=$str.sprintf", %.1f, %.1f",$saz,$ze;
							# READ GLOBALS
						$str1=<FIN>; chomp($str1); 
						$str1 =~ s/^\s+//; $str1 =~ s/\s+$//;
						@f1=split /[ ,]+/g,$str1;
						$str1=<FIN>; chomp($str1); 
						$str1 =~ s/^\s+//; $str1 =~ s/\s+$//;
						@f2=split /[ ,]+/g,$str1;
						for(0..6){
							$str=$str.','.$f1[$_].','.$f2[$_];
						}
						$str =~ s/[, ]+/,/g;
						print Fout "$str\n";
							# INCREMENT COUNTERS
						if( $str=~/^H/ || $str=~/^T/){
							$nhigh++;
						}
							# RECORD TIME > END TIME
						if($recorddt > $dtend){
							last;
						}
							#=====================
							# PROCESS DA0 DATA -- occurs on each cycle
							#=====================
						if($w[17] >= $w[18]){
							for($ic=1;$ic<=7;$ic++){
									# OPEN SWEEP FILE
								$fout = $timeseriespath."/da".$ic."raw.txt";
								eval sprintf"\$R=R%d",$ic;
									# WRITE BASE INFO
								printf $R "%s, $w[7], $w[8], %.1f, %.1f, $w[17], $f1[$ic-1], $f2[$ic-1]",dtstr($recorddt,'csv'),$saz,$ze;
									# BINS
								$str=<FIN>; chomp($str);
								$str=~s/[ ,]+/, /g;
								print $R ",   $str";
								print $R "\n";
	#$str=sprintf"print R%d \"nrec yyyy MM dd hh mm ss lat lon saz sze shad g1 g2 s01 s02 s03 s04 s05 s06 s07 s08 ".
		#"s09 s10 s11 s12 s13 s14 s15 s16 s17 s18 s19 s20 s21 s22 s23\\n\";",$ic;
							}
						}
					}
				}
			}
		}
	}
	if($recorddt > $dtend){
		last;
	}
}
print"nread: $nread,  good records: $nrec,  high mode: $nhigh\n";

	#=====================
	# PROCESS SWEEPS
	#=====================
	
exit 0;

#=======================================================================
sub AddHeader{
print F '

da0raw flat file
mode	: H,T or L
yyyy	: year
MM	: month
dd	: day of month
hh	: hour (0-23)
mm	: minute (0-59)
ss	: second (0-59)
lat	: latitude. float point, (-90 to 90), N plus
lon	: longitude, float point, (-180 to 180), E plus
sog	: speed over ground, kts
cog	: course over ground, degT
thead	: Head temperature, degC
t1	: Inner temperature, degCC
t2	: Outside the cube temperature, degC
p1	: pitch at horizon 1, deg, bow up plus
p2	: pitch at horizon 2, deg, bow up plus
r1	: roll at horizon 1, deg, port up plus
r2	: roll at horizon 2, deg, port up plus
shad	: shadow ratio, no units
shadlim	: shadow-no shadow limit, no units
saz	: solar azimuth, degT
sze	: solar zenith, deg from vertical
g11	: global for channel 1, horizon 1, millivolts
g12	: global for channel 1, horizon 2, millivolts
g21	: global for channel 2, horizon 1, millivolts
g22	: global for channel 2, horizon 2, millivolts
g31	: global for channel 3, horizon 1, millivolts
g32	: global for channel 3, horizon 2, millivolts
g41	: global for channel 4, horizon 1, millivolts
g42	: global for channel 4, horizon 2, millivolts
g51	: global for channel 5, horizon 1, millivolts
g52	: global for channel 5, horizon 2, millivolts
g61	: global for channel 6, horizon 1, millivolts
g62	: global for channel 6, horizon 2, millivolts
g71	: global for channel 7, horizon 1, millivolts
g72	: global for channel 7, horizon 2, millivolts


dairaw flat file where i=1-7
yyyy	: year
MM	: month
dd	: day of month
hh	: hour (0-23)
mm	: minute (0-59)
ss	: second (0-59)
lat	: latitude. float point, (-90 to 90), N plus
lon	: longitude, float point, (-180 to 180), E plus
saz	: solar azimuth, degT
sze	: solar zenith, deg from vertical
shad	: shadow ratio, no units
g11	: global for channel, horizon 1, millivolts
g12	: global for channel, horizon 2, millivolts
s01	: sweep bin 01, avg 30 points, millivolts
s02	: sweep bin 02, avg 20 points, millivolts
s03	: sweep bin 03, avg 20 points, millivolts
s04	: sweep bin 04, avg 10 points, millivolts
s05	: sweep bin 05, avg 10 points, millivolts
s06	: sweep bin 06, avg 10 points, millivolts
s07	: sweep bin 07, avg 5 points, millivolts
s08	: sweep bin 08, avg 5 points, millivolts
s09	: sweep bin 09, avg 5 points, millivolts
s10	: sweep bin 10, avg 5 points, millivolts
s11	: sweep bin 11, avg 5 points, millivolts
s12	: sweep bin 12, avg 1 points, millivolts (minimum)
s13	: sweep bin 13, avg 5 points, millivolts
s14	: sweep bin 14, avg 5 points, millivolts
s15	: sweep bin 15, avg 5 points, millivolts
s16	: sweep bin 16, avg 5 points, millivolts
s17	: sweep bin 17, avg 5 points, millivolts
s18	: sweep bin 18, avg 10 points, millivolts
s19	: sweep bin 19, avg 10 points, millivolts
s20	: sweep bin 20, avg 10 points, millivolts
s21	: sweep bin 21, avg 20 points, millivolts
s22	: sweep bin 22, avg 20 points, millivolts
s23	: sweep bin 23, avg 30 points, millivolts
';
}