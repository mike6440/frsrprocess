clear
disp('Clear');
global SETUPFILE DATAPATH TIMESERIESPATH IMAGEPATH SERIES SERIESPATH
global MISSING STARTTIME ENDTIME dtstart dtend

[x,str]=system('echo $HomePath');
HOME = strtrim(str);
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

