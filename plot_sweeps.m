%PLOTS SWEEPS FOR CHANNEL IC AND TIMES SPECIFIED
% SPECIFY CHANNEL AND SAMPLE NUMBER, E.G.
% ic=3; is0=500; plot_sweeps

global SETUPFILE DATAPATH TIMESERIESPATH IMAGEPATH SERIES SERIESPATH
global MISSING STARTTIME ENDTIME dtstart dtend
global Nlang DTlang

% CHANNEL
%ic=3;
% SAMPLE NUMBER
%is0=500; 
for ic=2:5
	fprintf('CHANNEL %d\n',ic);
	for is=is0:is0+5,
		% Based on Langley time window
		cmd=sprintf('dt=d%dr.dt;',ic); eval(cmd);
		t1=DTlang(1,1);   t2=DTlang(1,2);
		ix=find(dt>=t1 & dt<t2);
		fprintf('Time from %s  to  %s, Number sweeps = %d\n',dtstr(t1,'short'),dtstr(t2,'short'),length(ix));
		%=====================
		% PULL VARIABLES
		%=====================
		% time
		dt=dt(ix);
		% sweep
		cmd=sprintf('sw=d%dr.s01(ix);',ic); eval(cmd);
		for i=2:23,
			cmd=sprintf('sw=[sw, d%dr.s%02d(ix)];',ic,i);
			eval(cmd);
		end
		%=====================
		% Compute Edge values
		%=====================
		disp('EDGE VALUES');
		[edge,ed1,ed2,i1,i2] = SweepEdge(sw(is,:));
	
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
		str=sprintf('%s/ch%dsweep%d.png',IMAGEPATH,ic,is); disp(['Save plot: ',str]);
		saveas(gcf,str,'png')
		pause
		close
	end
end
disp('END OF THIS PROGRAM');
