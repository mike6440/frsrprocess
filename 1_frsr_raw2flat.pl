#!/usr/bin/perl -X



#call: ./1_frsr_raw2flat.pl rawfilename
# e.g. ./1_frsr_raw2flat.pl Icapture.txt

		# LIBRARIES
print"PERL LIBRARY : $ENV{MYLIB}\n";
use lib $ENV{MYLIB};
use perltools::MRtime;
use perltools::MRutilities;
use perltools::MRradiation;
use perltools::MRstatistics;
use perltools::Prp;
use File::stat
#use POSIX;
#use File::Basename;

printf"Program $0\n";
die;

# my $epoch_timestamp = (stat($fh))[9];
# my $timestamp       = localtime($epoch_timestamp);

my ($setupfile,$datapath,$timeseriespath,$imagepath,$home);
my ($str,$str1,$cmd,$dtstart,$dtend,$seccorrect,$fout,$rawfile,$nrec,$nread,$dt);
my ($i, $ic, $cmd, $strout, $nbadcheck);
my ($mode,$imin);
my ($strout1,$strout2,$strout3,$strout4,$strout5,$strout6,$strout7);
my (@w,@sw);
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
	# RAW FILE, COMMAND LINE
$rawfile=FindInfo($setupfile,'RAW FILE',':');
$rawfile="$datapath/$rawfile";
print "raw file = $rawfile\n";
if (! -f $rawfile) {
	print"DOES NOT EXIST - stop.\n";
	exit 1;
}
		# TIMESERIESPATH
$timeseriespath=$ENV{HOME}.'/'.FindInfo($setupfile,"TIMESERIESPATH",":");
if ( ! -d $timeseriespath ) { 
	system "mkdir $timeseriespath";
}
print"timeseriespath = $timeseriespath\n";
		# IMAGEPATH
$imagepath=$ENV{HOME}.'/'.FindInfo($setupfile,"IMAGEPATH",":");
if ( ! -d $imagepath ) { 
	system "mkdir $imagepath";
}
print"imagepath = $imagepath\n";

		# START AND END TIMES
$str = FindInfo($setupfile,'STARTTIME');
@w= split /[, :\/]/g,$str;
$cmd=sprintf "\$dtstart = datesec($w[0],$w[1],$w[2],$w[3],$w[4],$w[5]);";
eval $cmd;
printf"starttime = %s\n", dtstr($dtstart);
		# END
$str = FindInfo($setupfile,'ENDTIME');
@w= split /[, :\/]/g,$str;
$cmd=sprintf "\$dtend = datesec($w[0],$w[1],$w[2],$w[3],$w[4],$w[5]);";
eval $cmd;
printf"endtime = %s\n", dtstr($dtend);
		# TIME CORRECTION
$seccorrect=FindInfo($setupfile,'TIMECORRECTSECS');
print"seccorrect=$seccorrect\n";
	# SERIES NAME
$seriesname = FindInfo($setupfile,'SERIES NAME',':');
print"seriesname=$seriesname\n";
		# EDGE OFFSET
$edgeoffset = FindInfo($setupfile,"EDGE INDEX OFFSET",':');
print"EDGE INDEX OFFSET = $edgeoffset\n";


# @f=`ls -1d $datapath/$series/$series*myData*.dat`;
# $i=0; foreach(@f){chomp($str=$_); print"$i   $str\n"; $i++}

# OPEN INPUT FILE
print"INPUT: $rawfile\n";
open(FIN,$rawfile) or die;

		# OUT FLAT FILE
$fout = $timeseriespath."/da0raw.txt";
print"OUTPUT: $fout\n";
open Fout,">$fout" or die;
printf Fout "Program $0,      Run time:%s\n", dtstr(now(),'short');
print Fout
"nr m yyyy MM dd hh mm ss lat      lon        sog cog  mft   t1     t2     p1   p2  r1  r2   g11 g12 g21 g22 g31 g32 g41 g42 g51 g52 g61 g62 g71 g72  shadlim shad ed1 ed2 edge shadow\n";
#0 0  2017 05 26 22 56 46 35.84973 -106.27273 0.0 311.4 39.90 50.50 23.60 0.9 0.8 0.7 0.7  40 40 74 76 48 47 39 39 32 33 39 42 41 42   10.0 0.0
# print Fout 
# "- -   --  -- -- -- -- -- deg      deg        m/s  dgT  C     C     C      deg  deg deg deg  mv  mv  mv  mv  mv  mv  mv  mv  mv  mv  mv  mv  mv  mv    --    --\n";

	# OUT SWEEP CHANNELS
for($ic=1; $ic<=7; $ic++){
	$fout = $timeseriespath."/da".$ic."raw.txt";
	print"R$ic, $fout\n";
	$str=sprintf"open R%d,\">%s\" or die;",$ic, $fout;
	#print"$str\n";
	eval $str;
	$str=sprintf"printf R%d \"Program \$0,  Chan %d,    Run time:%s\\n\";",$ic,$ic,dtstr(now(),'short');
	#print"$str\n";
	eval $str;
	#                        0 2017 05 27 16 06 01 22.2 578.0 580.0 581.0 575.0 591.0 598.0 600.0 599.0 597.0 593.0 579.0 189.0 61.0 51.0 85.0 504.0 581.0 581.0 581.0 582.0 580.0 576.0 579.0 0.0 0.0
	$str=sprintf"print R%d \"nrec yyyy MM dd hh mm ss shad g1 g2 s01 s02 s03 s04 s05 s06 s07 s08 ".
		"s09 s10 s11 s12 s13 s14 s15 s16 s17 s18 s19 s20 s21 s22 s23 ed1 ed2 edge shadow\\n\";",$ic;
	#print"$str\n";
	eval $str;
}

$nrec=0;
$nread=0;

# FIND THE FIRST LINE WITH START TIME
while(<FIN>){
	chomp($str=$_);
	$nread++;
	if( $str=~/\$FSR03/ ){
		$dt=FrsrParse_dt($str);
		if($dt>=$dtstart){last}
	}
}
FrsrParse($str);
print Fout "$nrec $strout\n";

# READ ALL LINES TO DTEND
while(<FIN>) {
	chomp($str=$_);
	$nread++;
	if( $str =~ /\$FSR03/ ){
		$dt=FrsrParse($str);
		if($dt > $dtend){last}
		$nrec++;
		if($dt>$dtstart && $dt <= $dtend){
			print Fout "$nrec $strout\n";
			if($mode==2){
				for($ic=1;$ic<=7;$ic++){
					$str=sprintf"printf R%d \"\$nrec  \$strout%d\\n\";",$ic,$ic;
					#print"$str\n";
					eval $str;
				}
			}	
		}
	}
}
print"bad checksums=$nbadcheck, good records: $nrec\n";
exit 0;


#=========================================================
#$GPRMC,190824,A,4737.0000,S,12300.0000,W,002.1,202.0,210210,019.0,W*62
sub NmeaChecksum
# $cc = NmeaChecksum($str) where $str is the NMEA string that starts with '$' and ends with '*'.
{
    my ($line) = @_;
    my $csum = 0;
    $csum ^= unpack("C",(substr($line,$_,1))) for(1..length($line)-2);
    return (sprintf("%2.2X",$csum));
}
#==========================================================================
sub DecodePsuedoAscii2
# input = 2 p.a. chars   output = decimal number
{
	my ($strin,$c1,$c2,$b1,$b2,$x);
	$strin=shift();
	#printf"In string = $strin  ";
	$c1 = substr($strin,0,1);
	$c2 = substr($strin,1,1);
	$b1 = ord( $c1 ) - 48;
	$b2 = ord($c2) - 48;
	$x = $b2*64+$b1;
	#print"  decode = $x\n";
	return $x;
}

#===========================================================================
sub FrsrParse_dt {
	my ($strin);
	my ($pktlen,$cc,$packetid,$shadow,$shadowthreshold,$ix);
	my (@g1,@g2,@sw);

	$strin=shift();
	## CHKSUM TEST
	$cc = NmeaChecksum( substr($strin,0,-2) );
	#printf"chksum=%s\n",substr($strin,-2);
	#printf"computed chksum=%s\n", $cc;
	if ($cc ne substr($strin,-2)) {
		#print"Checksum fails, skip\n";
		return 0;
	} else {
		$ix1=index($strin,'<<');
		$ix2=index($strin,'>>');
		#print"ix1=$ix1, ix2=$ix2\n";
		$strgps=substr $strin,$ix1+2,$ix2-$ix1-3;
		#print"strgps=$strgps\n";
		@w=split /[,]+/g,$strgps;
		#print"@w\n";
		# $GPRMC,000002,A,4736.2069,N,12217.2884,W,000.0,000.0,090517
		#  0      1     2  3        4  5         6  7    8      9
		#  HDR   hhmmss A lldd.dddd H llldd.dddd H sog   cog   ddMMyy
		# $GPRMC 000002 A 4736.2069 N 12217.2884 W 000.0 000.0 090517
		# TIME
		$dt=datesec(substr(@w[9],4,2)+2000,substr($w[9],2,2),substr($w[9],0,2),
		substr($w[1],0,2),substr($w[1],2,2),substr($w[1],4));
		#printf"time=%s\n",dtstr($dt);
		return $dt;
	}
}
#==============================================================================
#===========================================================================
# Subroutine to fully parse the FRSR string.
# Uses a global variable $strout.
# Returns the packet GPStime.
sub FrsrParse {
	my ($strin,$pktlen,$cc,$packetid,$shadow,$shadowthreshold,$ix);
	my ($ichar,$p,$i,$MfrTemp,$ix1,$ix2,$strgps,$dt,$lat,$lon,$sogmps,$cog,$T1,$T2);
	my ($pitch1,$pitch2,$roll1,$roll2,$ia,$ib,$ic,$is);
	my (@w,@g1,@g2,@s,$edge,$imin,$shadow,$swshadow,$ied1,$ied2,$x,$ed1,$ed2);

	$strin=shift();
	#print"strin = $strin\n";

	$pktlen=length($strin);
	#print"packet length = $pktlen\n";
	## CHKSUM TEST
	$cc = NmeaChecksum( substr($strin,0,-2) );
	#printf"chksum=%s\n",substr($strin,-2);
	#printf"computed chksum=%s\n", $cc;
	# FAIL CHECKSUM
	if ($cc ne substr($strin,-2)) {
		#print"Checksum fails, skip\n";
		$nbadcheck++;
		$dt=0;
	# PASS CHECKSUM
	} else {
		$ichar=1;
		# Header
		$packetid = substr($strin,$ichar,5);
		#print"ID = $packetid\n";
		$ichar+=6;
		# Mode
		$mode=substr($strin,$ichar,1);
		if($mode=~/H/){$mode=1}
		else{$mode=0}
		#print"Mode = $mode\n";
		$ichar+=2;
		# MFR temp
		$MfrTemp = substr($strin,$ichar,4);
		#print"MfrTemp = $MfrTemp\n";
		$ichar+=7;
		# GPS
		$ix1=index($strin,'<<');
		$ix2=index($strin,'>>');
		#print"ix1=$ix1, ix2=$ix2\n";
		$strgps=substr $strin,$ix1+2,$ix2-$ix1-3;
		#print"strgps=$strgps\n";
		@w=split /[,]+/g,$strgps;
		#print"@w\n";
		# $GPRMC,000002,A,4736.2069,N,12217.2884,W,000.0,000.0,090517
		#  0      1     2  3        4  5         6  7    8      9
		#  HDR   hhmmss A lldd.dddd H llldd.dddd H sog   cog   ddMMyy
		# $GPRMC 000002 A 4736.2069 N 12217.2884 W 000.0 000.0 090517
		# TIME
		$dt=datesec(substr(@w[9],4,2)+2000,substr($w[9],2,2),substr($w[9],0,2),
		substr($w[1],0,2),substr($w[1],2,2),substr($w[1],4));
		#printf"time=%s\n",dtstr($dt);
		# LAT
		$lat=substr($w[3],0,2)+substr($w[3],2)/60;
		if( @w[4] =~ /s/i) {$lat=-$lat}
		# LON
		$ix1=index($w[5],'.');
		#print"ix1=$ix1\n";
		$lon=substr($w[5],0,$ix1-2)+substr($w[5],$ix1-2)/60;
		if( @w[6] =~ /w/i) {$lon=-$lon}	
		#print"lat=$lat   lon=$lon\n";
		# SOG m/s
		$sogmps = @w[7]*.51444;
		# COG degT
		$cog = @w[8];
		$ichar = $ix2+3;	
		# T1,T2
		$T1 = DecodePsuedoAscii2( substr($strin,$ichar,2) )/10-20;
		$ichar+=2;
		$T2 = DecodePsuedoAscii2( substr($strin,$ichar,2) )/10-20;
		$ichar+=3;
		#printf"T1 = %.1f   T2 = %.1f\n",$T1,$T2;
		# pitch1, pitch2
		$pitch1 = DecodePsuedoAscii2( substr($strin,$ichar,2) )/100-20;
		$ichar+=2;
		$pitch2 = DecodePsuedoAscii2( substr($strin,$ichar,2) )/100-20;
		$ichar+=3;
		#printf"pitch1 = %.2f   pitch2 = %.2f\n",$pitch1,$pitch2;
		# roll1, roll2
		$roll1 = DecodePsuedoAscii2( substr($strin,$ichar,2) )/100-20;
		$ichar+=2;
		$roll2 = DecodePsuedoAscii2( substr($strin,$ichar,2) )/100-20;
		$ichar+=3;
		#printf"roll1 = %.2f   roll2 = %.2f\n",$roll1,$roll2;
		# global 1
		$ix=$ichar;
		for($i=0; $i<7; $i++){
			push(@g1,DecodePsuedoAscii2( substr($strin,$ix,2) ) );
			$ix+=2;
		}
		for($i=0; $i<7; $i++){
			#print"$g1[$i]  ";
		}
		#print"\n";
		# global 2
		$ichar+=15;
		$ix=$ichar;
		for($i=0; $i<7; $i++){
			push(@g2,DecodePsuedoAscii2( substr($strin,$ix,2) ) );
			$ix+=2;
		}
		for($i=0; $i<7; $i++){
			#print"$g2[$i]  ";
		}
		#print"\n";
		# shadow, limit
		$ichar+=15;
		$shadow = DecodePsuedoAscii2( substr($strin,$ichar,2) )/10;
		$ichar+=2;
		$shadowthreshold = DecodePsuedoAscii2( substr($strin,$ichar,2) )/10;
		$ichar+=3;
		#printf"shadow = %.1f   shadowthreshold = %.1f\n",$shadow,$shadowthreshold;
		# WRITE D0 FILE
		$strout=sprintf"%s  %s %.5f %.5f %.1f %.1f %.2f %.2f %.2f %.1f %.1f %.1f %.1f  ",
			$mode, dtstr($dt,'ssv'),$lat,$lon,$sogmps,$cog,$MfrTemp,$T1,$T2,$pitch1,$pitch2,$roll1,$roll2;
			
		for($i=0; $i<7; $i++){
			$strout=$strout.sprintf"$g1[$i] $g2[$i] ";
		}
		$strout=$strout.sprintf"  %.1f %.1f",$shadowthreshold, $shadow;
		
		# HIGH MODE
		if($pktlen>300){
			$mode=2;
			# FILL THE SW ARRAY
			$ix=$ichar; # first character
			for($ia=0; $ia<7; $ia++){
				for($ib=0; $ib<23; $ib++){
					$ic = $ia*23 + $ib; # array index
					$sw[$ic] = DecodePsuedoAscii2( substr($strin,$ix,2) );
					#print"$ia $ib $sw[$ic]\n";
					$ix+=2;
				}
				$ix++; # skip the comma
			}
			# PRINT OUT SWEEPS
			# CHANNELS ia = 0...6
			for($ia=0; $ia<7; $ia++){
				$str=sprintf("\$strout%d=sprintf\"%%s %%.1f %%.1f %%.1f \",dtstr(\$dt,\'ssv\'),\$shadow,\$g1[%d],\$g2[%d];",
					$ia+1,$ia,$ia);
				eval $str;
				@s=();
				# BINS ib = 0...22, FILL s ARRAY
				for($ib=0; $ib<23; $ib++){
					$ic = $ia*23 + $ib; # array index
					#print"$ia $ib $ic $sw[$ic]\n";
					push(@s,$sw[$ic]);
					$str=sprintf("\$strout%d=\$strout%d.sprintf(\"%%.1f \",\$sw[\$ic]);",$ia+1,$ia+1);
					eval($str);
				}
				#for($ib=0; $ib<23; $ib++){print"$s[$ib]\n"}
					# MINIMUM
				$x=1e6;
				for($ib=0; $ib<23; $ib++){if($s[$ib]>0 && $s[$ib] < $x){$x=$s[$ib]; $imin=$ib} }
				#print"--> MINIMUM: INDEX=$imin, MIN=$x\n";
				$swshadow=$x;
					# EDGE VALUES
				$ied1=$imin-$edgeoffset;   $ied2=$imin+$edgeoffset;
				if($ied1<1){ $ed1=-999; } else { $ed1=$s[$ied1]; }
				if($ied2>23) {$ed2=-999; } else { $ed2=$s[$ied2];}
				$x=$is=0; if($ed1>0){$x+=$ed1; $is++;}  if($ed2>0){$x+=$ed2; $is++;} 
				if($is<=0){
					print"($nrec) no edge: $strout\n";
					$str1=sprintf "0  0  0  0 %.1f",$shadow;
				}else{
					$edge = $x / $is;
					#print"--> EDGE: ied=($ied1,$ied2),  ed1=$ed1, ed2=$ed2, edge=$edge\n";
					$str1=sprintf "%.1f %.1f %.1f %.1f",$ed1,$ed2,$edge,$swshadow;
				}
				$cmd=sprintf"\$strout%d=\$strout%d.\$str1;",$ia+1,$ia+1; 
				eval($cmd);

			}
# 			print"(0) $strout\n\n";
# 			print"(1) $strout1\n\n";
# 			print"(2) $strout2\n\n";
# 			print"(3) $strout3\n\n";
# 			print"(4) $strout4\n\n";
# 			print"(5) $strout5\n\n";
# 			print"(6) $strout6\n\n";
# 			print"(7) $strout7\n";
# 			die;
		}
	}
	return $dt;
}

