function initScreen
%lab room screen setting
global scr design

%scr.viewingDist = 101.6;   % viewing distance (cm)
scr.viewingDist = 57;
% scr.colDept     = 24;
% scr.width       = 475;
% scr.height      = 475;
scr.width       = 376;
scr.height      = 302;
scr.xres = 1024;
scr.yres = 768;
% scr.width       = 400;
% scr.height      = 300;
% scr.xres = 1280 ;
% scr.yres = 960;

% If there are multiple displays guess that one without the menu bar is the
% best choice.  Dislay 0 has the menu bar.
scr.allScreens = Screen('Screens');
scr.expScreen  = max(scr.allScreens);
scr.colDept = Screen('PixelSize',scr.expScreen);
Screen('Preference', 'VisualDebugLevel',3);% get rid of PsychtoolBox Welcome screen

% Open a window.  Note the new argument to OpenWindow with value 2,
% specifying the number of buffers to the onscreen window.
% [scr.main,scr.rect] = Screen('OpenWindow',scr.expScreen, WhiteIndex(scr.expScreen)/2,[],scr.colDept,2,0,4);
if design.DEBUG
    [scrx, scry] = Screen('WindowSize', 0);
    [scr.main,scr.rect] = PsychImaging('OpenWindow',0, WhiteIndex(scr.expScreen)/2, [scrx-scr.xres,scry-scr.yres,scrx,scry], scr.colDept,2,...
        [], [],  kPsychNeed32BPCFloat);
else
    Screen('Resolution', scr.expScreen,scr.xres, scr.yres);
    [scr.main,scr.rect] = PsychImaging('OpenWindow',scr.expScreen, WhiteIndex(scr.expScreen)/2, [], scr.colDept,2,...
        [], [],  kPsychNeed32BPCFloat);
end

% Flip to clear
Screen('Flip', scr.main);
% [scr.main2,scr.rect2] = Screen(0,'OpenWindow',[0 0 0],[],[],2);

% % % load calibration file
% load('0001_james_ProP220f_1280x960_100Hz_57cm_Oct2014_110412.mat');
% % load('0001_titchener_130226.mat');
% Screen('LoadNormalizedGammaTable',scr.main,repmat(calib.table,1,3));


% Screen('BlendFunction', scr.main, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % this is needed for the transparency of the gabor envelope ...
% Screen('FillRect',scr.main, background.color);
% Screen('FillRect',scr.main2, [0 0 0]);

% get information about screen
%[scr.xres, scr.yres] = Screen('WindowSize', scr.main); % heigth and width of screen [pix]

scr.fd = Screen('GetFlipInterval',scr.main);           % frame duration [s]
scr.fr = 1/scr.fd;                                     % frame rate
% [width, height] = Screen('DisplaySize', scr.main);     % screen size in mm

% scr.width   = width;
% scr.height  = height;
scr.xpxpcm  = scr.xres/(scr.width./10);
scr.ypxpcm  = scr.yres/(scr.height./10);
scr.xpxpdeg = ceil(tan(2*pi/360)*scr.viewingDist*scr.xpxpcm);
scr.ypxpdeg = ceil(tan(2*pi/360)*scr.viewingDist*scr.ypxpcm);

fprintf(1,'\n\nScreen runs at %.1f Hz.\n\n',scr.fr);

% determine th main window's center
[scr.centerX, scr.centerY] = WindowCenter(scr.main);

% Give the display a moment to recover from the change of display mode when
% opening a window. It takes some monitors and LCD scan converters a few seconds to resync.
WaitSecs(2);

