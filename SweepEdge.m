function [edgearray]=SweepEdge(sw),
% call: [edge,ed1,ed2]=SweepEdge(sw);
%INPUT
% sw : 1x23 array of all  sweep bins
%OUTPUT
% edge : best choice, either ed1, ed2, or their average
% ed1  : left hand edge
% ed2  : right hand edge

for i1=5:10,
	swmn=Meanseries(sw(1:i1)); swstd=100*Stdseries(sw(1:i1))/swmn;
	df=100*(swmn-sw(i1+1))/swmn;
	%fprintf('i1 %d, mean %.1f, std %.1f, dif %.1f\n',i1,swmn,swstd,df);
	if df > 15, break; end
end

for i2=19:-1:14,
	swmn=Meanseries(sw(i2:23)); swstd=100*Stdseries(sw(i2:23))/swmn;
	df=100*(swmn-sw(i2-1))/swmn;
	%fprintf('i2 %d, mean %.1f, std %.1f, dif %.1f\n',i2,swmn,swstd,df);
	if df > 15, break; end
end
ed1=sw(i1); ed2=sw(i2);
edge=0.5*(ed1+ed2);
%fprintf('Edge 1 at index %d, value %.1f\n',i1,ed1);
%fprintf('Edge 2 at index %d, value %.1f\n',i2,ed2);
%fprintf('Edge = %.1f\n',edge);
%fprintf('Shadow = %.1f\n',sw(12));
%fprintf('Edge-shadow = %.1f\n',edge-sw(12));
edgearray=[edge ed1 ed2 i1 i2];
return
