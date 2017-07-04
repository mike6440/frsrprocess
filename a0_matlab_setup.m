clear
disp('Clear');
global SETUPFILE DATAPATH TIMESERIESPATH IMAGEPATH SERIES
global MISSING STARTTIME ENDTIME dtstart dtend

[x,str]=system('echo $HOME');
HOME = strtrim(str);
disp(['Home path = ',HOME]);

SETUPFILE='0_initialize_frsr_process.txt';
fprintf('SETUPFILE = %s\n', SETUPFILE);

MISSING=-999;
disp(['MISSING ',sprintf('%d',MISSING)]);

SERIES = FindInfo(SETUPFILE,'SERIES NAME',':');
disp(['SERIES NAME = ',SERIES]);

STARTTIME = FindInfo(SETUPFILE,'STARTTIME',':');
fprintf('STARTTIME=%s\n', STARTTIME);
str=['dtstart=datenum(',STARTTIME,');'];
eval(str);

ENDTIME = FindInfo(SETUPFILE,'ENDTIME',':');
fprintf('ENDTIME=%s\n', ENDTIME);
str=['dtend=datenum(',ENDTIME,');'];
eval(str);

DATAPATH = FindInfo(SETUPFILE,'DATAPATH',':');
DATAPATH = fullfile(HOME,DATAPATH);
disp(['DATAPATH = ',DATAPATH]);

TIMESERIESPATH = FindInfo(SETUPFILE,'TIMESERIESPATH',':');
TIMESERIESPATH = fullfile(HOME,TIMESERIESPATH);
disp(['TIMESERIESPATH = ',TIMESERIESPATH]);

IMAGEPATH = FindInfo(SETUPFILE,'IMAGEPATH',':');
IMAGEPATH = fullfile(HOME,IMAGEPATH);
disp(['IMAGEPATH = ',IMAGEPATH]);
