% lifted from langley_times_sgp14_mfrsr.m
am=mfr.am(ix);
% FOR EACH FILTER (CHAN2-6)
for ichan=2:6,%2:6,
fprintf('  CHANNEL %d\n',ichan);
wvc=deblank(wv(ichan,:));
eval(sprintf('lni=log(mfr.n%d(ix));',ichan));
p=polyfit(am,lni,1);
v=exp(p(2));
v0=[v0;v];
if plotflag, 
	plot(am,lni,'k.','markersize',8); grid; hold on
	set(gca,'fontname','arial','fontsize',14,'fontweight','bold');
	set(gca,'xlim',[0,6]);
	set(gca,'ylim',[min(lni)-0.5,p(2)+0.5]);
end
if plotflag, plot([0,am(end)],[p(2),lni(end)],'r-'); end

iy=find(am>=2);
am2=am(iy); lni2=lni(iy);
p2=polyfit(am2,lni2,1);
v2=exp(p2(2)); 
v20=[v20;v2];
if plotflag, 
	plot([0,am2(end)],[p2(2),lni2(end)],'g-');
	xlabel('ATM MASS');
	ylabel('Log Vn');
	eval(sprintf('tx=title(''CHAN%d %s nm'');',ichan, wvc ));
	set(tx,'fontsize',14');

	tx=text(0,0, sprintf('V0full=%.2f,  V0gt2=%.2f',v,v2));
	set(tx,'units','normalized','position',[.03,.1,0]);
	set(tx,'fontname','arial','fontsize',14,'fontweight','bold');

	tx=text(0,0, sprintf('%s  %s to %s',dtstr(t1,'date'),dtstr(t1,'time'),dtstr(t2,'time')));
	set(tx,'units','normalized','position',[.03,.2,0]);
	set(tx,'fontname','arial','fontsize',14,'fontweight','bold');
	
	[y,M,d,h]=datevec(t1);
	cmd=sprintf('saveas(gcf,''%s/images/mfrsrL%02d%02d%02d%02d_%s.png'',''png'');',DATAPATH,rem(y,100),M,d,h,wvc);
	disp(cmd); eval(cmd);
	pause(2); close;
end
