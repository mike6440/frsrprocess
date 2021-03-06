% MAKE MAT FILES FROM THE RAW FLAT FILES
clear

global SETUPFILE DATAPATH TIMESERIESPATH IMAGEPATH SERIES
global MISSING STARTTIME ENDTIME dtstart dtend

% DA0 
arrayname='d0r';
if exist(arrayname,'var')
	%fprintf('Array %s is already loaded.\n',arrayname);
else
	filename=sprintf('%s/da0raw.txt',TIMESERIESPATH);
	%fprintf('INPUT: %s\n',filename);
	matname=strcat(filename(1:end-3),'mat');
	%fprintf('MAT: %s\n',matname);
	if exist(matname,'file')
		cmd=sprintf('load %s',matname);
		disp(cmd); eval(cmd);
	else
		ReadRTimeSeries;
		cmd=sprintf('save %s %s',matname,arrayname);
		disp(cmd); eval(cmd);
	end
end

npts=length(d0r.dt);
fprintf('Series %s, %d points  from %s to %s\n',arrayname,npts,dtstr(d0r.dt(1)),dtstr(d0r.dt(end)))

%====================================================================
% DAx
for i=1:7, 
	cmd=sprintf('arrayname=''d%dr'';',i);
	eval(cmd);
	if exist(arrayname,'var')
		%fprintf('Array %s is already loaded.\n',arrayname);
	else
		filename=sprintf('%s/da%draw.txt',TIMESERIESPATH,i);
		%fprintf('INPUT: %s\n',filename);
		matname=strcat(filename(1:end-3),'mat');
		%fprintf('MAT: %s\n',matname);
		if exist(matname,'file')
			cmd=sprintf('load %s',matname);
			disp(cmd); eval(cmd);
		else
			ReadRTimeSeries;
			cmd=sprintf('save %s %s',matname,arrayname);
			disp(cmd); eval(cmd);
		end
	end
end

return

%a=[d1.s01 d1.s02 d1.s03 d1.s04 d1.s05 d1.s06 d1.s07 d1.s08 d1.s09...
% 	d1.s10 d1.s11 d1.s12 d1.s13 d1.s14 d1.s15 d1.s16 d1.s17 d1.s18...
%	d1.s19 d1.s20 d1.s21 d1.s22 d1.s23 ];