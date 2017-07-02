clear
disp('Clear');
global SETUPFILE DATAPATH TIMESERIESPATH IMAGEPATH SERIES
global MISSING STARTTIME ENDTIME dtstart dtend

SETUPFILE='0_initialize_frsr_process.txt';
fprintf('SETUPFILE = %s\n', SETUPFILE);

MISSING=-999;
fprintf('MISSING %d\n',MISSING);

SERIES = FindInfo(SETUPFILE,'SERIES NAME',':');
fprintf('SERIES NAME = %s\n',SERIES);

STARTTIME = FindInfo(SETUPFILE,'STARTTIME',':');
fprintf('STARTTIME=%s\n', STARTTIME);
str=['dtstart=datenum(',STARTTIME,');'];
eval(str);

ENDTIME = FindInfo(SETUPFILE,'ENDTIME',':');
fprintf('ENDTIME=%s\n', ENDTIME);
str=['dtend=datenum(',ENDTIME,');'];
eval(str);

DATAPATH = FindInfo(SETUPFILE,'DATAPATH',':');

TIMESERIESPATH = FindInfo(SETUPFILE,'TIMESERIESPATH',':');
fprintf('TIMESERIESPATH=%s\n', TIMESERIESPATH);

IMAGEPATH = FindInfo(SETUPFILE,'IMAGEPATH',':');
fprintf('IMAGEPATH=%s\n', IMAGEPATH);
