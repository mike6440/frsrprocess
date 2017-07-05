global SETUPFILE DATAPATH TIMESERIESPATH IMAGEPATH SERIES
global MISSING STARTTIME ENDTIME dtstart dtend


arrayname='d0r';
if exist(arrayname,'var')
	fprintf('Array %s is already loaded.\n',arrayname);
else
	disp('Call a1_get_mat first.');
	return
end

dt=d0r.dt;
dt1=dtstart;  dt2=dtend;
[ttk,htk]=MakeHourTicks(dt1, dt2);

%===================
%  plot globals
%===================
for ic=1:7,
	figure('position',[200,100,1000,600]);
	str1=sprintf('g%d1',ic);
	str2=sprintf('g%d2',ic);
	cmd=sprintf('plot(dt,d0r.g%d1,''b.'',''markersize'',6);',ic);
	eval(cmd);
	grid; datetick; hold on;
	set(gca,'fontname','arial','fontweight','bold','fontsize',14);
	set(gca,'xtick',ttk,'xticklabel',htk);
	cmd=sprintf('plot(dt,d0r.g%d2,''m.'',''markersize'',6);',ic);
	eval(cmd);
	set(gca,'ylim',[-inf,inf],'xlim',[dt1,dt2]);
	str=sprintf('Raw chan %d global1(b)  2(m)',ic);
	tx=title(str);
	set(tx,'fontname','arial','fontweight','bold','fontsize',14);
	set(gca,'ylim',[-inf,inf],'xlim',[dt1,dt2]);
	xlabel('UTC');ylabel('COUNTS / W/m2');
	cmd=sprintf('saveas(gcf,''%s/chan%dglobals.png'',''png'');',IMAGEPATH,ic);
	disp(cmd); eval(cmd);
	pause; close;
end
return

plottitle='globals';
figure('position',[200,100,1000,600]);
plot(dt,d0r.g1,'k.','markersize',6);
grid; datetick; hold on;
set(gca,'fontname','arial','fontweight','bold','fontsize',14);
set(gca,'xtick',ttk,'xticklabel',htk);
plot(dt,d0r.g2,'b.','markersize',6);
plot(dt,d0r.g3,'c.','markersize',6);
plot(dt,d0r.g4,'m.','markersize',6);
plot(dt,d0r.g5,'r.','markersize',6);
plot(dt,d0r.g6,'g.','markersize',6);
plot(dt,d0r.g7,'y.','markersize',6);
set(gca,'ylim',[-inf,inf],'xlim',[dt1,dt2]);
tx=title('Globals: 1(k), 2(b), 3(c), 4(m), 5(r), 6(g), 7(y)');
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
set(gca,'ylim',[-inf,inf],'xlim',[dt1,dt2]);
xlabel('UTC');ylabel('ADC COUNTS');
cmd=sprintf('saveas(gcf,''%s/d0_globals.png'',''png'');',IMAGEPATH);
disp(cmd); eval(cmd);
pause; close;
