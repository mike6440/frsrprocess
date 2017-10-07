% Langley_edge
%BEFORE CALL
%  IL=1 % specify the langly number
% IC=2 % specify the channel
global SETUPFILE DATAPATH TIMESERIESPATH IMAGEPATH SERIES SERIESPATH
global MISSING STARTTIME ENDTIME dtstart dtend
global Nlang DTlang 
% edgevector [edge ed1 ed2 i1 i2] for each sweep in langley IL
global D IC IL DT SZE AM sw EDGE SHADOW

%================
% FOR EACH AOD CHANNEL
%================
il=IL;
ic=IC;
	fprintf('CHANNEL %d\n',ic);
	%================
	% ASSIGN THE DESIRED CHANNEL
	%================
	cmd=sprintf('D = d%dr;',ic);
	disp(cmd); eval(cmd);
	%================
	% TIME BASE
	%================
	t1=DTlang(il,1);   t2=DTlang(il,2);
	ix=find(D.dt>=t1 & D.dt<t2);
	t1=D.dt(ix(1)); t2=D.dt(ix(end));
	fprintf('Chan %d, Time from %s  to  %s, Number sweeps = %d\n',...
	  ic,dtstr(t1,'short'),dtstr(t2,'short'),length(ix));
	DT=D.dt(ix);
	%================
	% SOLAR ANGLES
	%================
	SZE = D.sze(ix);
	AM = AtmMass(SZE);
	%=====================
	% PULL SWEEP
	%=====================
	% time
	% sweep
	sw=D.s01(ix);
	for i=2:23,
		cmd=sprintf('sw=[sw, D.s%02d(ix)];',i);
		eval(cmd);
	end

	%=====================
	% Compute Edge values
	%=====================
	disp('Compute Edge Values');
	edgevec=[];  SHADOW=[];
	for i=1:length(ix),
		edgevec=[edgevec; SweepEdge(sw(i,:))];
	end
	EDGE=edgevec;
	SHADOW=sw(:,12);
	ND = (EDGE(:,1)-SHADOW) ./ cos(SZE*pi/180);
	lgnd=log(ND);
	p=polyfit(AM,lgnd,1);
	v0=exp(p(2));
	v0str=sprintf('Langly %d Raw: ze [%.1f %.1f], amass [%.1f %.1f], v0=%.1f',...
		IL,SZE(1),SZE(end),AM(1),AM(end),v0);
	disp(v0str);
%=====================
% AVERAGE 
%=====================
disp('AVERAGES');
[dtav, edgeav,edgeavstd] = AvgSeries(DT,EDGE(:,1),6,120,t1,t2);
[dtav, shadav,shadavstd] = AvgSeries(DT,SHADOW,6,120,t1,t2);
[dtav, amav,amavstd] = AvgSeries(DT,AM,6,120,t1,t2);
[dtav, szeav,szeavstd] = AvgSeries(DT,SZE,6,120,t1,t2);
ndav = (edgeav-shadav) ./ cos(szeav*pi/180);
lgndav=log(ndav);
%  remove nans
ix=find(isnan(lgndav));
amav(ix)=[];  lgndav(ix)=[];
% Only take atmmass > 1.8
ix=find(amav<1.8);
amav(ix)=[];  lgndav(ix)=[];


p=polyfit(amav,lgndav,1);
v0av=exp(p(2));
v0avstr=sprintf('Langly %d Avg: ze [%.1f %.1f], amass [%.1f %.1f], v0=%.1f',...
	IL,szeav(1),szeav(end),amav(1),amav(end),v0av);
disp(v0avstr);

%==============================================================
plot(AM,lgnd,'.b','markersize',8);grid;hold on
set(gca,'xlim',[0,6]);
plot(amav,lgndav,'om','markersize',4,'markerfacecolor','m');

amavx=sort([0; sort(amav)]);
xav = polyval(p,amavx);
plot(amavx,xav,'-k','linewidth',2);

set(gca,'fontname','arial','fontweight','bold','fontsize',12);
str=sprintf('%s, %d, CH-%d: raw(b)  avg(m)  fit(k)',SERIES,IL,IC);
tx=title(str);
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
xlabel('Atm Mass')
ylabel('LOG(Normal Direct Radiance)');

str=sprintf('L%d_Ch%d_LangleyPlot.png',IL,IC);
cmd=sprintf('saveas(gcf,''%s'',''png'');',fullfile(IMAGEPATH,str));
disp(cmd); eval(cmd);
pause; close;


disp('END OF C2');
return






