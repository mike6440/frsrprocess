chan='3';
% dt vector is the list of good times derived from d0 analysis.
[c,ia,ib]=intersect(d0.dt,dt); % ia indexes of good times in d0.
eval(['[c,ic,id]=intersect(d',chan,'.dt,dt);']); % ic indexes of same times in d1. ia != ic
nr0=d0.nrec(ia); % list of good record numbers in d0
eval(['nr=d',chan,'.nrec(ic);']); % list of good record numbers in d1. nr1 != nr0
[c,n0,nx]=intersect(nr0,nr); % c = list of common record numbers

% baseline array common record numbers
[x,ia,ib]=intersect(d0.nrec,c);
k0=[1:length(d0.dt)];
k0(ia)=[];
r0=TruncateRTimeSeries(d0,k0);

% chan1 array 
eval(['[x,ic,id]=intersect(d',chan,'.nrec,c);']);
eval(['kx=[1:length(d',chan,'.dt)];']);
kx(ic)=[];
eval(['r',chan,'=TruncateRTimeSeries(d',chan,',kx);']);

% r1 is an array of all d1 records with times in the dt set.
% r0 is the corresponding records from d0.

% Variables needed:
% d0: nrec shrat thead yyyy MM dd hh mm ss lat lon g1 
% d0: pitch roll saz sze
% edge shadow 
lx.dt = r0.dt;
lx.nrec = r0.nrec;
lx.shrat = r0.shrat;
lx.thead = r0.thead;
lx.yyyy = r0.yyyy;lx.MM = r0.MM;lx.dd = r0.dd;
lx.hh = r0.hh;lx.mm = r0.mm;lx.ss = r0.ss;
lx.global = r0.g1;
lx.pitch=r0.pitch;
lx.roll=r0.roll;
lx.saz=r0.saz;
lx.sze=r0.sze;
eval(['lx.edge=r',chan,'.edge;']);
eval(['lx.shadow=r',chan,'.shadow;']);
lx.vars=str2mat('nrec','yyyy','MM','dd','hh','mm','ss','shrat',...
	'thead','global','pitch','roll','saz','sze','edge','shadow');

return

%
%% SOLAR DISTANCE RATIO
%dta = mean(lx.dt);
%[Dratio, d, dmean] = SunDistance(dta);
%dt0=datenum(2001,10,5,0,0,0);
%[Dratio_ref, d, dmean] = SunDistance(dt0);
%fprintf('Dratio at time %s = %.6f\n',dtstr(dta,'csv'),Dratio);
%fprintf('Dratio_ref at time %s = %.6f\n',dtstr(dt0,'csv'),Dratio_ref);
%
%	% TOA RADIANCE
%	% Filter channels 2-7 , band passed irradiance
%chan=2;
%infofile='/Users/rmr/Dropbox/instruments/PRP_FRSR/PrpCal/PRP/201/1407/prprx_201_1407.txt';
%FILEID=fopen(infofile);
%[str,ia,ib] = FindTxtLine(FILEID, 'DETECTOR BAND CENTER WAVELENGTHS');
%str=fgetl(FILEID);
%x=strsplit(str,{' ',','});
%band=str2num(x{chan-1});
%nskp=3+(chan-1); %2,3,4,5,6,7
%for i=[1:nskp],
%	str=fgetl(FILEID);
%	disp(str);
%end
%x=strsplit(str,{' ',','});
%toa=str2num(x{4});
%toa=[toa str2num(x{5})];
%toa=[toa str2num(x{6})];
%fprintf('chan %d, toa=(%.3f, %.3f, %.3f)\n',chan,toa(1),toa(2),toa(3));
%
%%DETECTOR BAND CENTER WAVELENGTHS (nm)
%% 413.60, 501.56, 613.96, 671.44, 870.33, 937.83
%% PASS BAND AND TOA IRRADIANCE, TOA_simbios374_1408.dat
%%   WAVELENGTH (nm)         IRRADIANCE (W/m^2/nm)
%% LOWER  CENTER  UPPER     LOWER   MEAN    UPPER
%%390, 414, 435,          1.685, 1.719, 1.753
%%480, 502, 525,          1.903, 1.941, 1.980
%%590, 614, 635,          1.633, 1.666, 1.700
%%645, 671, 695,          1.476, 1.506, 1.536
%%830, 870, 900,          0.929, 0.948, 0.967
%%900, 938, 970,          0.811, 0.827, 0.844
%
%a=[d1.s01 d1.s02 d1.s03 d1.s04 d1.s05 d1.s06 d1.s07 d1.s08 d1.s09...
%d1.s10 d1.s11 d1.s12 d1.s13 d1.s14 d1.s15 d1.s16 d1.s17 d1.s18...
%d1.s19 d1.s20 d1.s21 d1.s22 d1.s23 ];

% REMOVE RECORDS WITH BAD SHADOW VALUES
ix=find(lx.shadow<10);
lx1=TruncateRTimeSeries(lx,ix);
% REMOVE RECORDS WITH SMALL DIP
dip=lx1.edge-lx1.shadow;
ix=find(dip < 0.5*lx1.edge);
lx=TruncateRTimeSeries(lx1,ix);

% FIT A LINE TO SHADOW
dip=(lx.edge-lx.shadow);
dt=lx.dt;
p=polyfit(dt,dip,2);
dp=polyval(p,dt);
% EXCURSIONS FROM THE LINE
dpx=dip-dp;
md=median(dpx);
sd=std(dpx);
ix=find(abs(dpx-md)>2*sd);
lx1=TruncateRTimeSeries(lx,ix);
dip=lx1.edge-lx1.shadow;
dt=lx1.dt;
% LANGLEY CURVE
m=AtmMass(lx1.sze);
n=dip ./ cos(lx1.sze*pi/180);
% FIT CURVE BETWEEN M=2-3
ix=find(m>=2 & m<=3);
mf=m(ix);  nf=n(ix);
p=polyfit(mf,nf,1);
nx=polyval(p,mf);
% PLOT THE RESULT
plot(m,n,'.','markersize',8);
grid; hold on
plot(mf,nx,'.r','markersize',8)
K=polyval(p,0);
plot(0,K,'ro','markersize',10);


