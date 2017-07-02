#! /usr/bin/perl -X
#use strict; use warnings;

use lib $ENV{MYLIB};
use perltools::MRutilities;
use perltools::MRtime;


#========== FRSR V3 ===============================================================
#Call: ./InterpFrsrPacket.pl 

#$strin= 
	# HIGH PACKET NO SHADOW
#'$FSR03,H,45.0,<<$GPRMC,000002,A,4736.2069,N,12217.2884,W,000.0,000.0,090517,>>,o6k6,8J:J,^O^O,`1<2R1O1E1<2^1,_152\1N1D1A2[1,]0\4,*55';
	# HIGH PACKET WITH SHADOW
#'$FSR03,H,49.8,<<$GPRMC,002910,A,4736.2036,N,12217.2877,W,000.0,000.0,090517,>>,o6k6,8J8J,]O\O,`1k1X1Y1P1b1]1,a1n1W1[1P1>2R1,>5\4,_1[1R1L1N1N1L1K1L1O1R181[1Z1^1^1`1a1`100000000,n1m152n1?2i122n1m122m100l1o1i1c1e1a1\1a1R1Q1d1,0000000000X1Y142Z1Y1Y100\1Z1Y1Y1X1^1W1X1a1T1L1,0000Y1a1X1Y1Y1W1Y1X1Y100Z1Y1X1Z1E1Z1X1X1P1K1E1,R1Q1T1P1P1N1M1\1G1E1D100A1=1=1=1D1?181=1F1M1P1,125272:2;2l1o1;2o1k1520032V1P1i1N1f1i1i1f1n1<2,U1Y1Q1P1[1I1G1D1D1?1K100E1D1D1E1A1B1R1K1O1R100,*6C';
	# LOW PACKET
#'$FSR03,L,32.4,<<$GPRMC,200612,A,4736.1941,N,12217.3006,W,000.0,196.3,080517,>>,83B3,8O6O,ePeP,21m0a0`0Z0M1j0,0121d0a0[0M1n0,00\4,*5D';

# 0  $
# 1-2		FS		identifies the instrument FRSR
# 3			R		identifies the software version
# 4-5		03		packet format
# 6			,		sep 1
# 7			H		mode H, T, L
# 8			,		sep 2
# 9-12		40.4	temperature
# 13		,		sep 3
# 14-...	<<...>> GPS string or <<-999>>
# 		,		sep 4
# 		l5no	T1 and T2
# 		,		sep 5
# 		5N1N	pitch1 pitch2
# 		,		sep 6
# 		e0j0	roll1 roll2
# 		,		sep 7
# 		R=O000`0;0_0k3	G11-G17 globals
# 		,		sep 8
# 		S=O000`0;0^0k3  G21-G27 globals
# 		,		sep 9
# 		@HT1	shadow and threshold
# 		,		sep 10
# 		00000000000000000000S=R=S=S=S=S=S=S=S=S=S=S=S=	chan 1
# 		'		sep 11
# 		R0Q0S0U0R0R0^0S0O0E0;0004090C0M0R0S0S0S0Q0Q0O0	chan 2
# 		,		sep 12
# 		0000000000000000000000001000101010101010101020	chan 3
# 		,		sep 13
# 		a0a0a0a0a0a0c0a0\0J0;00020B0P0_0`0a0a0b0a0`0a0	chan 4
# 		,		sep 14
# 		0000000000000000;0<0;000?0;0;0;0;0;0;0;0;0;0:0	chan 5
# 		,		sep 15
# 		_0_0_0^0_0_0_0_0V0F0700040D0S0^0_0_0_0_0_0^0^0	chan 6
# 		,		sep 16
# 		m3k3m3n3n3o3o3k343a1X0<0\0o173k3o3m3m3m3l3l3l3	chan 7
# 		,		sep 17
# 		*		sep 18
# 		28		checksum		


#$strin='$FSR03,H,40.1,<<$GPRMC,190913,A,3551.0198,N,10616.3607,W,000.0,239.4,290517,>>,noK9,^P^P,4Q4Q,i1O2e1c1Y1<2;1,g1^2`1c1V1:2Q1,o0T1,*27';
$strin = $ARGV[0];
print"strin = $strin\n";
# TEST LENGTH
my ($pktlen,$cc,$packetid,$mode,$shadow,$shadowthreshold,$ix);
my (@g1,@g2,@sw);
$pktlen=length($strin);
print"packet length = $pktlen\n";
die;
## CHKSUM TEST
$cc = NmeaChecksum( substr($strin,0,-2) );
# printf"chksum=%s\n",substr($strin,-2);
# printf"computed chksum=%s\n", $cc;
if ($cc ne substr($strin,-2)) {
	print"Checksum fails, skip\n";
} else {
	$ichar=1;
	# Header
	$packetid = substr($strin,$ichar,5);
	#print"ID = $packetid\n";
	$ichar+=6;
	# Mode
	$mode=substr($strin,$ichar,1);
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
# 	for($i=0; $i<7; $i++){
# 		print"$g1[$i]  ";
# 	}
# 	print"\n";
	# global 2
	$ichar+=15;
	$ix=$ichar;
	for($i=0; $i<7; $i++){
		push(@g2,DecodePsuedoAscii2( substr($strin,$ix,2) ) );
		$ix+=2;
	}
# 	for($i=0; $i<7; $i++){
# 		print"$g2[$i]  ";
# 	}
# 	print"\n";
	# shadow, limit
	$ichar+=15;
	$shadow = DecodePsuedoAscii2( substr($strin,$ichar,2) )/10;
	$ichar+=2;
	$shadowthreshold = DecodePsuedoAscii2( substr($strin,$ichar,2) )/10;
	$ichar+=3;
	#printf"shadow = %.1f   shadowthreshold = %.1f\n",$shadow,$shadowthreshold;
	# HIGH - SHADOW
	if($pktlen>300){
		# Sweep chan 0
		$ix=$ichar; # first character
		for($ia=0; $ia<7; $ia++){
			for($ib=0; $ib<23; $ib++){
				$ic = $ia*23 + $ib; # array index
				$sw[$ic] = DecodePsuedoAscii2( substr($strin,$ix,2) );
				$ix+=2;
			}
			$ix++; # skip the comma
		}
		# print out sweeps
# 		for($ia=0; $ia<7; $ia++){
# 			for($ib=0; $ib<23; $ib++){
# 				$ic = $ia*23 + $ib; # array index
# 				print"$sw[$ic] ";
# 			}
# 			print"\n";
# 		}
	}
}
#      time lat lon sog  cog mode temp 
printf"%s %.5f %.5f %.1f %.1f $mode %.2f %.2f %.2f %.1f %.1f %.1f %.1f  ",dtstr($dt,'ssv'),
$lat,$lon,$sogmps,$cog,$MfrTemp,$T1,$T2,$pitch1,$pitch2,$roll1,$roll2;
for($i=0; $i<7; $i++){
	print"$g1[$i] $g2[$i] ";
}
printf"  %.1f %.1f",$shadowthreshold, $shadow;
# 
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

