%global SETUPFILE DATAPATH TIMESERIESPATH IMAGEPATH SERIES
%global MISSING STARTTIME ENDTIME dtstart dtend


chan=1;
chana=sprintf('%d',chan);
arrayname=['d',chana];
if exist(arrayname,'var')
	fprintf('Array %s is already loaded.\n',arrayname);
else
	fprintf('Call a1_get_mat first.\n');
	return
end

eval(['dt=d',chana,'.dt;'])
dt1=dtstart;  dt2=dtend;
[ttk,htk]=MakeHourTicks(dt1, dt2);
%sw=d0.sol_n .* cos(d0.sze*pi/180) + d0.sol_d;

str=sprintf('a=d%d.s01; for i=2:23, cmd=sprintf(''a = [a d%d.s%%02d];'',i); eval(cmd); end;',chan,chan);
disp(str); eval(str);

figure('position',[200,100,1000,600]);
eval(sprintf('plot(dt,d%d.ed1,''k.'',''markersize'',6);',chan));
grid; datetick; hold on;
set(gca,'fontname','arial','fontweight','bold','fontsize',14);
set(gca,'xtick',ttk,'xticklabel',htk);
eval(sprintf('plot(dt,d%d.ed2,''b.'',''markersize'',6);',chan));
eval(sprintf('plot(dt,d%d.shadow,''r.'',''markersize'',6);',chan));
set(gca,'ylim',[-inf,inf],'xlim',[dt1,dt2]);
tx=title(['Chan',chana,' Edge1(k) Edge2(b)  Minimum(r)']);
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
set(gca,'ylim',[-inf,inf],'xlim',[dt1,dt2]);
xlabel('UTC');ylabel('counts');
cmd=sprintf('saveas(gcf,''%s/Chan%d_edge.png'',''png'');',IMAGEPATH,chan);
disp(cmd); return
eval(cmd);
pause; close;
