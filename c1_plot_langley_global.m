global SETUPFILE DATAPATH TIMESERIESPATH IMAGEPATH SERIES SERIESPATH
global MISSING STARTTIME ENDTIME dtstart dtend
global Nlang DTlang
global D IC IL SZE AM sw EDGE SHADOW

il=IL; 

% TIME TO ANALYZE, from setup file
t1=DTlang(il,1);  t2=DTlang(il,2);
% PLOT FOR EACH AOD CHANNEL, 2-6
for ic=2:6
	cmd=sprintf('dt=d%dr.dt;',ic); eval(cmd);
	ix=find(dt>=t1 & dt<t2);
	% PULL VARIABLES
	cmd=sprintf('dt=d%dr.dt(ix);',ic); eval(cmd);
	cmd=sprintf('g=.5*(d%dr.g1(ix)+d%dr.g2(ix));',ic,ic);  eval(cmd);
	%gdpcnt=100*(d2r.g1(ix)-d2r.g2(ix))./g;
	% PLOT GLOBAL
	[dtav,xav,xstd]=AvgSeries(dt,g,6,120,t1,t2);
	plot(dt,g,'-b');grid,datetick;hold on
	set(gca,'fontname','arial','fontweight','bold','fontsize',12);
	plot(dtav,xav,'.m','markersize',6);
	str=sprintf('Chan%d, Langley %d, Global mean raw-b, avg-m',ic,il);
	tx=title(str);
	set(tx,'fontname','arial','fontweight','bold','fontsize',14);
	xlabel('UTC');
	ylabel('ADC mv');
	fn=sprintf('%s/L%dglobal_chan%d.png',IMAGEPATH,il,ic);
	disp(['Save plot: ',fn]);
	saveas(gcf,fn,'png');
	pause;
	close;
end
return


