clear
disp('Clear');
global SETUPFILE DATAPATH TIMESERIESPATH IMAGEPATH SERIES SERIESPATH
global MISSING STARTTIME ENDTIME dtstart dtend
global Nlang DTlang

[x,str]=system('echo $HOME');
HOME = fullfile(strtrim(str),'/Dropbox');
disp(['HOME = ',HOME]);

SETUPFILE='0_initialize_frsr_process.txt';
fprintf('SETUPFILE = %s\n', SETUPFILE);

DATAPATH = FindInfo(SETUPFILE,'DATAPATH',':');
DATAPATH = fullfile(HOME,DATAPATH);
disp(['DATAPATH = ',DATAPATH]);

SERIES = FindInfo(SETUPFILE,'SERIES NAME',':');
disp(['SERIES NAME = ',SERIES]);

SERIESPATH = fullfile(DATAPATH,SERIES);
disp(['SERIESPATH = ',SERIESPATH]);

TIMESERIESPATH = fullfile(SERIESPATH,'timeseries');
disp(['TIMESERIESPATH = ',TIMESERIESPATH]);

IMAGEPATH = fullfile(SERIESPATH,'images');
disp(['IMAGEPATH = ',IMAGEPATH]);

MISSING=-999;
disp(['MISSING ',sprintf('%d',MISSING)]);

STARTTIME = FindInfo(SETUPFILE,'STARTTIME',':');
fprintf('STARTTIME=%s\n', STARTTIME);
str=['dtstart=datenum(',STARTTIME,');'];
eval(str);

ENDTIME = FindInfo(SETUPFILE,'ENDTIME',':');
fprintf('ENDTIME=%s\n', ENDTIME);
str=['dtend=datenum(',ENDTIME,');'];
eval(str);

%===============
% LANGLEY TIMES
%===============
str=FindInfo(SETUPFILE,'NUMBER LANGLEY');
if length(str)==0,
	disp('No Langlet plots in this series.');
	Nlang=0;
else
	%===============
	% Pull Langley times
	%===============
	Nlang=str2num(str);
	fprintf('%d Langley plots.\n',Nlang);
	F=fopen(SETUPFILE);
	% Move pointer to Langley times
	while(1),
		str=fgetl(F);
		%disp(str);
		if length(strfind(str,'NUMBER LANGLEY')) > 0,
			break;
		end
		if feof(F), break, end
	end
	% Read each time and make array dtlang n x 
	DTlang=[];
	for i=1:Nlang,
		str=fgetl(F);
		c=strsplit(str);
		cmd=sprintf('a=datenum(%s);',c{1}(1:end-1));
		eval(cmd); 
		cmd=sprintf('b=datenum(%s);',c{2}(1:end));
		eval(cmd); 
		DTlang=[DTlang; [a b] ];
		fprintf('%d  %s  to %s\n',i,dtstr(a,'short'),dtstr(b,'short'));
	end	
end

