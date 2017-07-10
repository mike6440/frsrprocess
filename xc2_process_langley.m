% Langley_edge
%BEFORE CALL
%  IL=1 % specify the langly number
% IC=2 % specify the channel
global SETUPFILE DATAPATH TIMESERIESPATH IMAGEPATH SERIES SERIESPATH
global MISSING STARTTIME ENDTIME dtstart dtend
global Nlang DTlang 
% edgevector [edge ed1 ed2 i1 i2] for each sweep in langley IL
global D IC IL SZE AM sw EDGE SHADOW

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
	fprintf('Chan %d, Time from %s  to  %s, Number sweeps = %d\n',ic,dtstr(t1,'short'),dtstr(t2,'short'),length(ix));
	dt=D.dt(ix);
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
v0


disp('END OF C2');
