%a0_matlab_setup
%a1_get_mat
%dt=d0.dt; g=d0.g1; ViewSeries(dt,g);
% run this to select times

lglynum=3;
lglynumber=sprintf('%02d',lglynum);

dt=d0.dt; ix=find(dt>datenum(2017,5,30,13,33,00)); length(ix)
sw=d0.sol_d(ix) + d0.sol_n(ix) .* cos(d0.sze(ix)*pi/180); 
g=d0.g1(ix);
dt=dt(ix);
ixf=ix;
plot(dt,g,'.b');grid;hold on;datetick
set(gca,'fontname','arial','fontweight','bold','fontsize',12);
set(gca,'xlim',[dt(1),dt(end)]);
plot(dt,sw,'.m');
xlabel('UTC'); ylabel('counts / W/m2')
tx=title(['Langley',lglynumber,' g1(b)  sw(m)']);
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
d=sw-g;
plot(dt,d,'.g');
p=polyfit(sw,d,2);
df1=polyval(p,sw);
plot(dt,df1,'.c')
str=[IMAGEPATH,'/sw_g_langley',lglynumber,'.png'];
disp(str);
saveas(gcf,str,'png')
pause; close

z=df1-d; ix=find(abs(z) < 20);
g=g(ix); dt=dt(ix); sw=sw(ix); ixf=ixf(ix);
plot(dt,g,'.b');grid;hold on;datetick
set(gca,'fontname','arial','fontweight','bold','fontsize',12);
set(gca,'xlim',[dt(1),dt(end)]);
plot(dt,sw,'.m');
xlabel('UTC'); ylabel('counts / W/m2')
tx=title(['Langley',lglynumber,' fit20 g1(b)  sw(m)']);
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
d=sw-g;
plot(dt,d,'.g');
p=polyfit(sw,d,2);
df1=polyval(p,sw);
plot(dt,df1,'.c')
saveas(gcf,[IMAGEPATH,'/sw_g_langley',lglynumber,'_fit20.png'],'png')
pause; close

z=df1-d; ix=find(abs(z) < 5);
g=g(ix); dt=dt(ix); sw=sw(ix); ixf=ixf(ix);
plot(dt,g,'.b');grid;hold on;datetick
set(gca,'fontname','arial','fontweight','bold','fontsize',12);
set(gca,'xlim',[dt(1),dt(end)]);
plot(dt,sw,'.m');
xlabel('UTC'); ylabel('counts / W/m2')
tx=title(['Langley',lglynumber,' fit05 g1(b)  sw(m)']);
set(tx,'fontname','arial','fontweight','bold','fontsize',14);
d=sw-g;
plot(dt,d,'.g');
p=polyfit(sw,d,2);
df1=polyval(p,sw);
plot(dt,df1,'.c')
saveas(gcf,[IMAGEPATH,'/sw_g_langley',lglynumber,'_fit05.png'],'png')
pause; close

disp(['Langley',lglynumber,' times are vector dt']);
return

[c,ia,ib]=intersect(d0.dt,dt);

% CULL D0
k0=[1:length(d0.dt)]';
k0(ixf)=[];
r0=TruncateRTimeSeries(d0,k0);

% CULL Dx
[c,ia,ib]=intersect(d3.dt,dt);
k3=[1:length(d3.dt)];
disp(cmd); eval(cmd);
kx(ixf)=[];
cmd=['rx=TruncateRSeries(d',lglynumber,',kx);'];
disp(cmd);

