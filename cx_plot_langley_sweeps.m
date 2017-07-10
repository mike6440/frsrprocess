%PLOTS SWEEPS FOR CHANNEL IC AND TIMES SPECIFIED
% SPECIFY CHANNEL AND SAMPLE NUMBER, E.G.
%INPUT
%   ic=3; pt=<dtnumber>; plot_sweeps
%OUTPUT
%   

global SETUPFILE DATAPATH TIMESERIESPATH IMAGEPATH SERIES SERIESPATH
global MISSING STARTTIME ENDTIME dtstart dtend
global Nlang DTlang 
% edgevector [edge ed1 ed2 i1 i2] for each sweep in langley IL
global D IC IL EDGE
il=IL;
t1=DTlang(il,1);t2=DTlang(il,2);
ic=IC;
	%================
	% FIND START RECORD
	%================
	i0=50;
	pdt=t1 + i0/100 * (t2-t1);
	ix=find(D.dt>=t1);
	iy=find(D.dt>=pdt);
	is0=iy(1)-ix(1)+1;
		
	%================
	% A SEQUENCE OF PLOTS
	%================
	for is=is0:is0+4,
		edgevec=EDGE(is,:);
		edge=edgevec(1);ed1=edgevec(2);ed2=edgevec(3);i1=edgevec(4);i2=edgevec(5);
		%=====================
		% PLOT THE SWEEP
		%=====================
		plot(sw(is,:),'.b','markersize',8);grid;hold on
		plot(sw(is,:),'-b');
		plot(i1,ed1,'om','markersize',8,'markerfacecolor','m');
		plot(i2,ed2,'om','markersize',8,'markerfacecolor','m');
		plot(12,sw(is,12),'om','markersize',8,'markerfacecolor','m');
		plot([i1,i2],[edge,edge],'-m','linewidth',4);
		str=sprintf('Chan %d, Sweep at %s',ic,dtstr(dt(is),'short'));
		tx=title(str);
		set(tx,'fontname','arial','fontweight','bold','fontsize',14);
		set(gca,'fontname','arial','fontweight','bold','fontsize',12);
		str=sprintf('%s/ch%dsw_%.0f_%d.png',IMAGEPATH,ic,i0,is-is0); disp(['Save plot: ',str]);
		saveas(gcf,str,'png')
		pause
		close
	end
disp('END OF THIS PROGRAM');
