#!/usr/bin/perl -X


# solflux parameters
#($In,$Id) = solflux($ze, .05, 1013, .2, .2, .001);

		# LIBRARIES
use lib $ENV{MYLIB};
use perltools::MRtime;
use perltools::MRutilities;
use perltools::MRradiation;
use perltools::MRstatistics;
use perltools::Prp;
use File::stat;

my ($setupfile,$theadmin,$stationpressure,@solfluxparams,$FixedLocation,$FixedTilt);
my ($missing,$outfile,$series,$pitch,$roll,$saz,$ze,$ze0,$In,$Id);

$sb = stat($0);
# printf "mtime %s\n",scalar localtime $sb->mtime;
# printf "mtime %s\n",dtstr($sb->mtime,'short');
$hdr0=sprintf "PROGRAM $0, Edittime %s, Runtime %s",dtstr($sb->mtime,'short'),dtstr(now(),'short');
print "$hdr0\n";

$home = $ENV{HOME};
		# SETUPFILE
$setupfile='0_initialize_frsr_process.txt';
chomp($setupfile);
print"SETUP FILE = $setupfile   ";
if(-f $setupfile){
	print"EXISTS.\n";
} else {
	print"DOES NOT EXIST. STOP.\n";
}
		# DATAPATH 
$datapath = $ENV{HOME}.'/'.FindInfo($setupfile,'DATAPATH',':');
print "DATAPATH = $datapath   ";
if ( ! -d $datapath ) { print"DOES NOT EXIST. STOP.\n"; exit 1}
else {print "EXISTS.\n"}
		# RAWPATH 
$rawpath = $ENV{HOME}.'/'.FindInfo($setupfile,'RAWPATH',':');
print "RAWPATH = $rawpath   ";
if ( ! -d $rawpath ) { print"DOES NOT EXIST. STOP.\n"; exit 1}
else {print "EXISTS.\n"}
		# TIMESERIESPATH
$timeseriespath=$ENV{HOME}.'/'.FindInfo($setupfile,"TIMESERIESPATH",":");
if ( ! -d $timeseriespath ) { 
	system "mkdir $timeseriespath  EXISTS";
}
print"timeseriespath = $timeseriespath\n";
		# IMAGEPATH
$imagepath=$ENV{HOME}.'/'.FindInfo($setupfile,"IMAGEPATH",":");
if ( ! -d $imagepath ) { 
	system "mkdir $imagepath";
}
print"imagepath = $imagepath EXISTS\n";

		# HEAD TEMPERATURE LIMITS
$theadmin=FindInfo($setupfile,"THEADMIN");
printf"THEADMIN = %.1f\n", $theadmin;
$theadmax=FindInfo($setupfile,"THEADMAX");
printf"THEADMAX = %.1f\n", $theadmax;

$stationpressure=FindInfo($setupfile,"STATION PRESSURE");
printf"STATION PRESSURE = %.1f\n", $stationpressure;

		# SOLFLUX
$str = FindInfo($setupfile,"SOLFLUX PARAMETERS");
print"SOLFLUX PARAMETERS:";
@solfluxparams=split(/[, ]+/,$str);
$solfluxparams[1]=$stationpressure;
foreach(@solfluxparams){print"   $_"}
print"\n";

		# GPS location :  39.99109  -105.26070
$FixedLocation = FindInfo($setupfile,"GPS FIXED FLAG");
if($FixedLocation == 1){
	$latfix=FindInfo($setupfile,"GPS FIXED LATITUDE",':');
	$lonfix=FindInfo($setupfile,"GPS FIXED LONGITUDE",':');
	printf"USING FIXED LOCATION  %.6f   %.6f\n",$latfix,$lonfix;
}

	# FIXED TILT
$FixedTilt = FindInfo($setupfile,"TILT FIXED FLAG",':');
if($FixedTilt == 1){
	$pitchfix=FindInfo($setupfile,"TILT FIXED PITCH",':');
	$rollfix=FindInfo($setupfile,"TILT FIXED ROLL",':');
	$hdgfix=FindInfo($setupfile,"TILT FIXED HEADING",':');
	printf"USING FIXED TILT  pitch=%.1f   roll=%.1f\n",$pitchfix,$rollfix;
}

$missing=-999;

# OUTPUT da0
# nrec shrat yyyy MM dd hh mm ss lat lon saz sze pitch roll sog cog sol_n sol_d g1 g2 g3 g4 g5 g6 g7
#                                deg deg deg deg  deg  deg  m/s degT w/m2 w/m2  v  v  v  v  v  v  v
my $outfile = "$timeseriespath/da0raw.txt";
open F, ">$outfile" or die"da0raw.txt";
print"OUTPUT: $outfile\n";
printf F "Program $0,  Runtime %s\n", dtstr(now);
print F "units:     --gprmc time------- deg deg deg deg  deg  deg  m/s degT w/m2 w/m2  v  v  v  v  v  v  v\n";
print F "nrec shrat thead yyyy MM dd hh mm ss lat lon saz sze pitch roll sog cog sol_n sol_d g1 g2 g3 g4 g5 g6 g7\n";

#  OPEN THE DA0RAW FILE 
$da0file = "$timeseriespath/frsr_".$series."_flat.txt";
print"INPUT: $da0file\n";
if (! -f $da0file){
	print"DA0 RAW FILE $da0file DOES NOT EXIST. STOP\n"; 
	exit 1;
}
open D, $da0file or die("FAILS TO OPEN");
chomp($str=<D>);  #print"$str\n";
chomp($str=<D>);  #print"$str\n";
chomp($str=<D>);  #print"$str\n";

while(<D>) {
	chomp($str=$_);
	@w=split(/[ ]+/,$str);
	#$i=0; foreach(@w){print"$i $w[$i]\n";$i++}
	$dt=datesec($w[2],$w[3],$w[4],$w[5],$w[6],$w[7]);
	if($dt >= $dtstart){
		$nrec=$w[0];
		$shrat=$w[34];
		$thead = $w[12];
		if($thead >= $theadmin && $thead <= $theadmax){
			#printf"%s  thead = %.1f\n",dtstr($dt),$thead;
			#===================
			# GPS OR FIXED LOCATION
			#===================
			if($FixedLocation == 1){
				$lat=$latfix;  $lon=$lonfix;
				$sog=0;  $cog=0;
			} else {
				$lat=$w[8];  $lon=$w[9];  $sog=$w[10];  $cog=$w[11]; 
			}
			#printf"lat=%.6f,  lon=%.6f, sog=%.1f, cog=%.1f\n",$lat,$lon,$sog,$cog;
			#===================
			# TILT
			#===================
			if($FixedTilt == 1){
				$pitch=$pitchfix;
				$roll=$rollfix;
			} else {
				$pitch=0.5*($w[13]+$w[14]); 
				$roll=0.5*($w[15]+$w[16]);
			}
			#printf "pitch=%.1f,  roll=%.1f\n",$pitch, $roll;

			#============
			#  DERIVED VARIABLES
			#  saz sze hdg sol_n sol_d
			# CALL: (az, ze, ze0) = Ephem(lat, lon, dt); 
			#   [In, Id, Tr, To, Tg, Tw, Ta] = solflux(zdeg, w, p, k1, k2, l)
			# 		w=5, p=1013, k1=k2=.1, l=.3
			#============
				# DERIVED
			($saz,$ze,$ze0) = Ephem($lat, $lon, $dt);
			($In,$Id) = solflux($ze,@solfluxparams);
			#printf"solar az=%.1f, zenith=%.1f, Corrected zenith=%.1f\n",$saz,$ze,$ze0;
			#printf"Theoretical sw direct=%.1f, diffuse=%.1f\n",$In, $Id;
			#==============
			# OUTPUT FILE
			#print F "nrec shrat thead yyyy MM dd hh mm ss  lat lon saz sze pitch roll sog cog sol_n sol_d g1 g2 g3 g4 g5 g6 g7\n";
			#
			#==============                lat lon    saz  sze   pitch rol  sog cog    sol_n sol_d 
			$str = sprintf "%d %.1f %.1f %s  %.6f %.6f  %.1f %.1f  %.1f %.1f  %.1f %.1f  %.1f %.1f  %.1f %.1f %.1f %.1f %.1f %.1f %.1f",
				$nrec, $shrat, $thead, dtstr($dt,'ssv'),$lat,$lon,$saz,$ze,$pitch,$roll,$sog,$cog,$In,$Id,
				0.5*($w[19]+$w[20]),0.5*($w[21]+$w[22]),0.5*($w[23]+$w[24]),0.5*($w[25]+$w[26]),0.5*($w[27]+$w[28]),
				0.5*($w[29]+$w[30]),0.5*($w[31]+$w[32]);
			print F "$str\n";
		}
	}
	if($dt > $dtend){last}
}

close F; close D;  close S; close T;  close R;

exit 0;

