clear
disp('Clear');
global SETUPFILE DATAPATH TIMESERIESPATH IMAGEPATH SERIES SERIESPATH
global MISSING STARTTIME ENDTIME dtstart dtend
global Nlang DTlang
% edgevector [edge ed1 ed2 i1 i2] for each sweep in langley IL
global D IC IL SZE AM sw EDGE SHADOW

[x,str]=system('echo $HOME');
HOME = fullfile(strtrim(str),'/Dropbox');
disp(['HOME = ',HOME]);

SETUPFILE='0_initialize_frsr_process.txt';
fprintf('SETUPFILE = %s\n', SETUPFILE);

DATAPATH = FindInfo(SETUPFILE,'DATAPATH',':');
disp(['DATAPATH = ',DATAPATH]);

SERIES = FindInfo(SETUPFILE,'SERIES NAME',':');
disp(['SERIES NAME = ',SERIES]);

%SERIESPATH = fullfile(DATAPATH,SERIES);
%disp(['SERIESPATH = ',SERIESPATH]);

TIMESERIESPATH = fullfile(DATAPATH,'timeseries');
disp(['TIMESERIESPATH = ',TIMESERIESPATH]);

IMAGEPATH = fullfile(DATAPATH,'images');
disp(['IMAGEPATH = ',IMAGEPATH]);

MISSING=-999;
disp(['MISSING ',sprintf('%d',MISSING)]);
%===============
% LANGLEY TIMES
%===============
str=FindInfo(SETUPFILE,'NUMBER LANGLEY');
if strcmpi(str,'MISSING'), disp('NUMBER LANGLEY is missing, set to 0'), Nland=0; end 
disp(['NUMBER LANGLEY = ',str]);
Nlang=str2num(str);
if Nlang>0,
	% Read each time and make array dtlang n x 
	DTlang=[];
	for i=1:Nlang,
		s=sprintf('L%d',i);
		str=FindInfo(SETUPFILE,s);
		if strcmpi(str,'MISSING'), error([s,' line is missing']), end 
		% splits on commas
		c=strsplit(str,',');
		if length(c) ~= 12, error([s,' line is in error.']), end
		cmd=sprintf('a=datenum(%s,%s,%s,%s,%s,%s);',c{1},c{2},c{3},c{4},c{5},c{6});
		eval(cmd); 
		cmd=sprintf('b=datenum(%s,%s,%s,%s,%s,%s);',c{7},c{8},c{9},c{10},c{11},c{12});
		eval(cmd); 
		DTlang=[DTlang; [a b] ];
		fprintf('%d  %s  to  %s\n',i,dtstr(a,'short'),dtstr(b,'short'));
	end	
end

IL=1; IC=3; EDGE=[];

%========================
% GET THE DATA 
%=======================
% DA0 
arrayname='d0r';
if exist(arrayname,'var')
	%fprintf('Array %s is already loaded.\n',arrayname);
else
	filename=sprintf('%s/da0raw.txt',TIMESERIESPATH);
	fprintf('INPUT: %s\n',filename);
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
return
%====== DAX ==============================================================
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


disp('END OF A0');
