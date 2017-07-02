%a0_matlab_setup
%a1_get_mat
%dt=d0.dt; g=d0.g1; plot(dt,g,'.');datetick
% run this to select times

dt=d0.dt; ix=find(dt<datenum(2017,5,28,00,30,00)); length(ix)
sw=d0.sol_d(ix) + d0.sol_n(ix) .* cos(d0.sze(ix)*pi/180); 
g=d0.g1(ix);
dt=dt(ix);
plot(dt,g,'.b');grid;hold on;datetick
set(gca,'fontname','arial','fontweight','bold','fontsize',12);
set(gca,'xlim',[dt(1),dt(end)]);
plot(dt,sw,'.m');
xlabel('UTC'); ylabel('counts / W/m2')
tx=title('Langley01 g1(b)  sw(m)');
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
d=sw-g;
plot(dt,d,'.g');
p=polyfit(sw,d,2);
df1=polyval(p,sw);
plot(dt,df1,'.c')
saveas(gcf,'/Volumes/hd17/frsr/20170528_frsr_lanl/images/sw_g_langley01.png','png')
pause; close

z=df1-d; ix=find(abs(z) < 20);
g=g(ix); dt=dt(ix); sw=sw(ix);
plot(dt,g,'.b');grid;hold on;datetick
set(gca,'fontname','arial','fontweight','bold','fontsize',12);
set(gca,'xlim',[dt(1),dt(end)]);
plot(dt,sw,'.m');
xlabel('UTC'); ylabel('counts / W/m2')
tx=title('Langley01 fit20 g1(b)  sw(m)');
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
d=sw-g;
plot(dt,d,'.g');
p=polyfit(sw,d,2);
df1=polyval(p,sw);
plot(dt,df1,'.c')
saveas(gcf,'/Volumes/hd17/frsr/20170528_frsr_lanl/images/sw_g_langley01_fit20.png','png')
pause; close

z=df1-d; ix=find(abs(z) < 5);
g=g(ix); dt=dt(ix); sw=sw(ix);
plot(dt,g,'.b');grid;hold on;datetick
set(gca,'fontname','arial','fontweight','bold','fontsize',12);
set(gca,'xlim',[dt(1),dt(end)]);
plot(dt,sw,'.m');
xlabel('UTC'); ylabel('counts / W/m2')
tx=title('Langley01 fit05 g1(b)  sw(m)');
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
d=sw-g;
plot(dt,d,'.g');
p=polyfit(sw,d,2);
df1=polyval(p,sw);
plot(dt,df1,'.c')
saveas(gcf,'/Volumes/hd17/frsr/20170528_frsr_lanl/images/sw_g_langley01_fit05.png','png')
pause; close

disp('Langlet01 times are vector dt');
