


ic=2;
cmd=sprintf('dx=d%dr;',ic); disp(cmd); eval(cmd);
	% Pull data in time window
t1=datenum(2017,7,5,13,10,0);   t2=datenum(2017,7,5,17,33,0);
ix=find(dx.dt>=t1 & dx.dt<=t2);
dt=dx.dt(ix);
saz=dx.saz(ix); sze=dx.sze(ix); 
iy=[1:length(ix)]';

	% 
	% SWEEP ARRAY
sw=dx.s01(ix);
for i=2:23,
	cmd=sprintf('sw=[sw, dx.s%02d(ix)];',i);
	eval(cmd);
end

ed1=[]; ed2=[]; edge=[]; ied1=[]; ied2=[]; shadow=[];
	% EDGE VALUES
disp('EDGE VALUES');
for is=1:length(sw(:,1)),
	shadow=[shadow; sw(is,12)];
	for i1=5:10,
		swmn=Meanseries(sw(is,1:i1)); swstd=100*Stdseries(sw(is,1:i1))/swmn;
		df=100*(swmn-sw(is,i1+1))/swmn;
		%fprintf('i1 %d, mean %.1f, std %.1f, dif %.1f\n',i1,swmn,swstd,df);
		if df > 15, 
			ied1=[ied1; i1];
			break;
		end
	end
	for i2=19:-1:14,
		swmn=Meanseries(sw(is,i2:23)); swstd=100*Stdseries(sw(is,i2:23))/swmn;
		df=100*(swmn-sw(is,i2-1))/swmn;
		%fprintf('i2 %d, mean %.1f, std %.1f, dif %.1f\n',i2,swmn,swstd,df);
		if df > 15,
			ied2=[ied2; i2];
			break;
		end
	end
	ed1=[ed1; sw(is,i1)]; ed2=[ed2; sw(is,i2)];
	edge=[edge; 0.5*(ed1(end)+ed2(end))];
	%fprintf('Edge 1 at index %d, value %.1f\n',ied1(end),ed1(end));
	%fprintf('Edge 2 at index %d, value %.1f\n',ied2(end),ed2(end));
	%fprintf('Edge = %.1f\n',edge(end));
end

% DIRECT NORMAL
dn = (edge - shadow) ./ cos(sze*pi/180);
%average dn and sze to 2 min
AvgSeries
lgdn=log(dn);
m=AtmMass(sze);

