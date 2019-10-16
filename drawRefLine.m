function drawRefLine(th,refColor) 
% Draw the reference line at the fixation point
% th = angle clockwise from vertical (in degrees)
global scr params visual

if nargin<2
    refColor = params.ref.color;
end

width = ceil(params.ref.width  * visual.ppd); % in pixels
height = ceil(params.ref.height  * visual.ppd);

% make texture
rect = ones(height,width) .* refColor;
rectTexture = Screen('MakeTexture', scr.main, rect);

% defining a destination rectangle
 dstRect = [0 0 width height] ;
 
% locating the destination rectangle
centeredRect = CenterRectOnPointd(dstRect, scr.centerX - params.fix.offset * visual.ppd, scr.centerY);
 
% Draw the ref line to the screen
Screen('DrawTextures', scr.main, rectTexture,[],centeredRect,th);
 