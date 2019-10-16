function drawFixationPoints(fixoffset,fixcolor)

% Draw the fixation points
% offset =  distance to the screen center (in vis deg)

global scr params visual

if nargin < 2
    fixcolor = params.fix.color;
end

Screen('DrawDots', scr.main, [scr.centerX - ...
    fixoffset * visual.ppd; scr.centerY],params.fix.size * ...
    visual.ppd, fixcolor, [], 2);


end
