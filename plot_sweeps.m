%PLOTS SWEEPS FOR CHANNEL IC AND TIMES SPECIFIED
% SPECIFY CHANNEL AND SAMPLE NUMBER, E.G.
% ic=3; is0=500; plot_sweeps

global IMAGEPATH

% CHANNEL
%ic=3;
% SAMPLE NUMBER
%is0=500; 

for is=is0:is0+5,
	% TIME TO ANALYZE
	cmd=sprintf('dt=d%dr.dt;',ic); eval(cmd);
	t1=datenum(2017,7,3,13,0,0);
	t2=datenum(2017,7,3,18,0,0);
	ix=find(dt>=t1 & dt<t2);
		% PULL VARIABLES
	dt=dt(ix);
		% SWEEP ARRAY
	cmd=sprintf('sw=d%dr.s01(ix);',ic); eval(cmd);
	for i=2:23,
		cmd=sprintf('sw=[sw, d%dr.s%02d(ix)];',ic,i);
		eval(cmd);
	end
		% EDGE VALUES
	disp('EDGE VALUES');
	for i1=5:10,
		swmn=Meanseries(sw(is,1:i1)); swstd=100*Stdseries(sw(is,1:i1))/swmn;
		df=100*(swmn-sw(is,i1+1))/swmn;
		fprintf('i1 %d, mean %.1f, std %.1f, dif %.1f\n',i1,swmn,swstd,df);
		if df > 15, break; end
	end
	for i2=19:-1:14,
		swmn=Meanseries(sw(is,i2:23)); swstd=100*Stdseries(sw(is,i2:23))/swmn;
		df=100*(swmn-sw(is,i2-1))/swmn;
		fprintf('i2 %d, mean %.1f, std %.1f, dif %.1f\n',i2,swmn,swstd,df);
		if df > 15, break; end
	end
	ed1=sw(is,i1); ed2=sw(is,i2);
	edge=0.5*(ed1+ed2);
	fprintf('Edge 1 at index %d, value %.1f\n',i1,ed1);
	fprintf('Edge 2 at index %d, value %.1f\n',i2,ed2);
	fprintf('Edge = %.1f\n',edge);

	% PLOT A SWEEP
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
