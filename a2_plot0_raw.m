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
