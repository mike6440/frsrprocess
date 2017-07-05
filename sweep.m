% CHANNEL
ic=1;
% TIME TO ANALYZE
t1=datenum(2017,7,3,13,0,0);
t2=datenum(2017,7,3,18,0,0);
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
str=sprintf('Chan%d, Global mean raw-b, avg-m',ic);
tx=title(str);
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
xlabel('UTC');
ylabel('ADC mv');
fn=sprintf('/Users/rmr/Dropbox/data/frsr/images/ch%dglobal.png',ic);
disp(['Save plot: ',fn]);
saveas(gcf,fn,'png');
pause;
close;
return


for i=2:23,
	cmd=sprintf('sw=[sw, d2r.s%02d(ix)];',i);
	disp(cmd); eval(cmd);
end

is=1; plot(sw(is,:),'.b','markersize',8);grid;hold on
plot(sw(is,:),'-b');
d2r
ed1=d2r.ed1(ix); ed2=d2r.ed2(ix); edge=d2r.edge(ix);
ed1(1)
ed2(1)
close
is=500; plot(sw(is,:),'.b','markersize',8);grid;hold on
plot(sw(is,:),'-b');
ed1(is)
ed2(is)
plot(8,ed1(is),'om');
plot(8,ed1(is),'om','markersize',4);
plot(8,ed1(is),'om','markersize',8);
plot(8,ed1(is),'om','markersize',8,'markerfacecolor','m');
plot(16,ed2(is),'om','markersize',8,'markerfacecolor','m');
plot(12,sw(is,12),'om','markersize',8,'markerfacecolor','m');
plot([8,16],[edge(is),edge(is)],'-m','linewidth',4);
str=sprintf('Chan %d, Sweep at %s',ic,dtstr(dt(is),'short'));
str
tx=title(str);
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
set(gca,'fontname','arial','fontweight','bold','fontsize',12);
saveas(gcf,'/Users/rmr/Dropbox/data/frsr/images/ch2sweep500.png','png')