%global SETUPFILE DATAPATH TIMESERIESPATH IMAGEPATH SERIES
%global MISSING STARTTIME ENDTIME dtstart dtend

arrayname='d0';
if exist(arrayname,'var')
	fprintf('Array %s is already loaded.\n',arrayname);
else
	fprintf('Call a1_get_da0mat first.\n');
	return
end

dt=d0.dt;
dt1=dtstart;  dt2=dtend;
[ttk,htk]=MakeHourTicks(dt1, dt2);
sw=d0.sol_n .* cos(d0.sze*pi/180) + d0.sol_d;

figure('position',[200,100,1000,600]);
plot(dt,d0.g1,'k.','markersize',6);
grid; datetick; hold on;
set(gca,'fontname','arial','fontweight','bold','fontsize',14);
set(gca,'xtick',ttk,'xticklabel',htk);
plot(dt,sw,'b.','markersize',6);

set(gca,'ylim',[-inf,inf],'xlim',[dt1,dt2]);
tx=title('g1(k), Iqbol(b)');
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
set(gca,'ylim',[-inf,inf],'xlim',[dt1,dt2]);
xlabel('UTC');ylabel('COUNTS / W/m2');
cmd=sprintf('saveas(gcf,''%s/d0_g1_Iqbol.png'',''png'');',IMAGEPATH);
disp(cmd); eval(cmd);
pause; close;

plottitle='globals';
figure('position',[200,100,1000,600]);
plot(dt,d0.g1,'k.','markersize',6);
grid; datetick; hold on;
set(gca,'fontname','arial','fontweight','bold','fontsize',14);
set(gca,'xtick',ttk,'xticklabel',htk);
plot(dt,d0.g2,'b.','markersize',6);
plot(dt,d0.g3,'c.','markersize',6);
plot(dt,d0.g4,'m.','markersize',6);
plot(dt,d0.g5,'r.','markersize',6);
plot(dt,d0.g6,'g.','markersize',6);
plot(dt,d0.g7,'y.','markersize',6);
set(gca,'ylim',[-inf,inf],'xlim',[dt1,dt2]);
tx=title('Globals: 1(k), 2(b), 3(c), 4(m), 5(r), 6(g), 7(y)');
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
set(gca,'ylim',[-inf,inf],'xlim',[dt1,dt2]);
xlabel('UTC');ylabel('ADC COUNTS');
cmd=sprintf('saveas(gcf,''%s/d0_globals.png'',''png'');',IMAGEPATH);
disp(cmd); eval(cmd);
pause; close;
