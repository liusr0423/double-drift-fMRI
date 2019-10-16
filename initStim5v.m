function initStim5v

global visual scr params design

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Screen  & Stimulus Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------
% Screen information
%--------------------
visual.black = BlackIndex(scr.main);
visual.white = WhiteIndex(scr.main);
% visual.grey = visual.white/2;
% visual.bgColor  = (visual.white+visual.black)./2;      % background color
visual.ppd       = va2pix(1,scr);   % pixel per degree
visual.scrCenter = [scr.centerX scr.centerY scr.centerX scr.centerY];

params.screen.cmx       = scr.width./10;
params.screen.cmy       = scr.height./10;
params.screen.degPerCm  = 57/scr.viewingDist; % vis deg per cm

%---------------------------
% Fixation point information
%---------------------------
params.fix.color = visual.black; % color
params.fix.size = 0.3;           % size (width of the dot) in vis deg
params.fix.offset = 3;

%--------------------
% Gabor information
%--------------------
params.stim.size = 3 ;            % stim size in vis deg
params.stim.duration = 1;     % stim duration in seconds (1/4 round)
params.stim.ISI = 0.25;         % duration between stims
params.stim.contrast = 1;      % stim contrast
params.stim.tf = 4;              % stim internal drift temporal freq in Hz(cycles/sec)
params.stim.numCycles = 1.5   ;   % num of cycles visible (One Cycle = Grey-Black-Grey-White-Grey
                                  % i.e. One Black and One White Lobe)
params.stim.angle = 0;           % stim orientation angle in degrees (vertical = 0)
params.stim.angle2 = 45;
params.stim.phase = 0;           % stim initial phase
params.stim.offset = 5;        % stim distance from screen center in dva
%params.stim.pathAngle = 0;     % stim initial physcial path angle btw two stimuli (in degrees)
%params.stim.anglesPerPress = 45; % amount of angle to move on each button press (in degrees)

% compute stim parameters
params.stim.pathlength = 5;                     % stim global drift path length   (vis deg)
params.stim.speed = params.stim.pathlength / params.stim.duration; % stim global drift freq (vis deg/s)
params.stim.nFrames = round(params.stim.duration * scr.fr);        % stim frames
params.stim.sizepx = round(params.stim.size * visual.ppd); % stim size in pixels
params.stim.sigma = params.stim.sizepx / 7;                        % gabor sigma
%params.stim.sigma = 0.1 * visual.ppd; % gabor sigma (standard deviation of envolope in pixels 
params.stim.sf = params.stim.numCycles / params.stim.sizepx;       % spatial freq in cycles/pixel
%params.stim.sf = 2 / visual.ppd; % spatial freq in cycles/pixel
params.stim.phasePerSec = 360 * params.stim.tf ;                   % internal phase drift per frame (deg/frame)
params.stim.phasePerFrame  = 360 * params.stim.tf / scr.fr;        % internal phase drift per frame (deg/frame)
params.stim.speedpx = visual.ppd * params.stim.speed * scr.fd;     % stim global drift (pixel/frame)
params.stim.pathAngle = 0;
params.stim.pathAngle2 = -45;
params.stim.repeats = 1;
params.randSeed = ClockRandSeed;  % use clock to set random number generator

%---------------------------
% Reference points information
%---------------------------
params.ref.color = visual.black;  % color
params.ref.size = 0.3;            % size (width of the dot) in vis deg
params.ref.offset = 3;            % ref points distance in dva
params.ref.width = .05;           % width of ref line
params.ref.height = 5;            % height of ref line
a = randperm(90,design.nTrials/2);
b = -randperm(90,design.nTrials/2);
indx =  [a,b];
params.ref.anglesAll = indx(randperm(length(indx)));
params.ref.anglesPerFrame =  30 * numel(design.nTrials) / (params.stim.nFrames) ; %deg/frame
if ~design.DEBUG
    params.ref.anglesPerFrame =  1 ;
end




