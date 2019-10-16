function DoubleDrift_preScan
% DoubleDrift pre-scan behavioral expeirment
% adjustment task - adjust line until matching perceived stimulus path angle
% one vertical stimulus at right hemifield

close all; sca;
Beeper(400,.1,.05);Beeper(600,.1,.05);Beeper(800,.1,.05);
AssertOpenGL;  %Break if installed Psychtoolbox is not based on OpenGL or Screen() is not working properly.
rand('state',sum(100*clock))
home;
tic;

global visual scr params keys design

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

%%%% EXPERIMENT
try
    % get subject info
    participant.identifier = input('>>>> Participant initials (e.g.: AB):  ','s');
    design.experiment = input ('>>>> Experiment (e.g.: 1 for static control; 2 for counterphase flicker control):  ');
    design.record = input('>>>> Video? (yes: 1; no: 0):  ');
    design.DEBUG = input('>>>> Debug? (yes:1; no:0): ');
    exptName='DoubleDrift5v';
    if design.DEBUG
        Screen('Preference', 'SkipSyncTests', 1);
    end
    
    % response keys
    getKeyAssignment;
    
    % disable keyboard
    ListenChar(2);
    
    % prepare screens
    initScreen %lab

    % number of trials
    design.nTrials = 30;
    
    % prepare stimuli
    initStim5v
    
    % set priority of window activities to maximum
    priorityLevel=MaxPriority(scr.main);
    Priority(priorityLevel);
    
    % Build a procedural gabor texture (Note: to get a "standard" Gabor patch
    % we set a grey background offset, disable normalisation, and set a
    % pre-contrast multiplier of 0.5.
    backgroundOffset = [0.5 0.5 0.5 0.0];
    disableNorm = 1;
    preContrastMultiplier = 0.5;
    [gaborid, gaborrect] = CreateProceduralGabor(scr.main, ...
        params.stim.sizepx, params.stim.sizepx,[],...
        backgroundOffset, disableNorm, preContrastMultiplier);
    
    % param [phase+180, freq, sc,contrast, aspectratio, 0, 0, 0]
    propertiesMat = [params.stim.phase, params.stim.sf,...
        params.stim.sigma, params.stim.contrast,1.0, 0, 0, 0];
    % 'contrast' is the amplitude of your gabor in intensity units - A factor
    % that is multiplied to the evaluated gabor equation before converting the
    % value into a color value. 'contrast' may be a bit of a misleading term
    % here...
    
    % Numer of frames to wait before re-drawing
    waitframes = 1;
    
    % trialMatrix
    td = struct('trialIndex',[],'stimCond',[],'Resp',[]);
    td.trialIndex(:,1) = 1: design.nTrials;
    td.stimCond = nan(design.nTrials,2);
    td.stimCond(:,1) = [ones(design.nTrials*2/3,1);zeros(design.nTrials/3,1)]; % 1 = internal motion; 0 = no internal motion
    td.stimCond(:,2) = [ones(design.nTrials/3,1);repmat(2,design.nTrials/3,1);zeros(design.nTrials/3,1)]; % internal motion direction: left = 1, right = 2
    td.stimCond  = td.stimCond(randperm(size(td.stimCond,1)),:);               % randomize stim location over trials
    
    td.Resp = nan(design.nTrials,2);
    
    % time before reversing contrast of the checkerboard
    freq = params.stim.tf; % Hz
    checkFlipTimeSecs = 1/freq/2;
    checkFlipTimeFrames = round(checkFlipTimeSecs / scr.fd);
    
    if design.DEBUG
        % prep for text
        text1 = 'Path Angle = ';
        textRect1 = Screen('TextBounds',scr.main,text1);
        Screen('TextSize',scr.main,20);
        Screen('TextFont',scr.main,'Times');
    end
    
    %     % This is the cue which determines whether we exit the demo
    %     exitDemo = false;
    
    if design.record
        vidObj = VideoWriter('DriftR.avi');
        open(vidObj);
    end
    
    %% PREP FOR READY SCREEN
    % Add ready text here
    waitingtext = ['Ready','\n Please fixate at the dot','\n Press space when ready'];

    % Change the blend function to draw an antialiased fixation point
    % in the centre of the array
    Screen('BlendFunction', scr.main, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % Draw the fixation point
    drawFixationPoints(params.fix.offset);
    
    % Draw ready text
    Screen('TextSize', scr.main,25);
    DrawFormattedText(scr.main, waitingtext, 'center', scr.centerY - 130 );
    
    % Flip fixation and ready text to the screen
    Screen('Flip',scr.main);
    
    % wait for space to start trials
    while 1
        [keyIsDown,secs,keyCode] = KbCheck;
        
        if keyCode(keys.space) % If space is pressed on the keyboard
            break;
        end
    end

    %% start experiment
    % Run design.nTrials trials
    for i = 1:design.nTrials
        
        % This is the cue which determines whether we go to the next trial
        nextTrial = false;
        
        % set initial phase randomly
        propertiesMat(1) = 360 * rand;
        
        % initial ref dots angle
        params.ref.pathAngle  =  params.ref.anglesAll (i);
        
        % Change the blend function to draw an antialiased fixation point
        % in the centre of the array
        Screen('BlendFunction', scr.main, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
        
        % Draw the fixation and reference points
        drawFixationPoints(params.fix.offset);
        
        % Perform initial flip to gray background:
        Screen('Flip', scr.main);
        
        if design.record
            currFrame = Screen('GetImage', scr.main);
            writeVideo(vidObj,currFrame);
        end
        
        % wait a sec before showing stimulus
        WaitSecs (1);
        
        % sync us to the retrace:
        vbl  = GetSecs;
        
        % Loop the animation for this trial
        for m = 1 : params.stim.repeats
            
            % set counter flag to 0
            frameCounter = 0;
            
            % gabor initial locations
            dstRect = [scr.centerX - gaborrect(3)/2 + params.stim.offset * visual.ppd , ...
                scr.centerY - gaborrect(4)/2 + params.stim.pathlength/2 * visual.ppd ,...
                scr.centerX + gaborrect(3)/2 + params.stim.offset * visual.ppd ,...
                scr.centerY + gaborrect(4)/2 + params.stim.pathlength/2 * visual.ppd ] ;
            
            
            for n = 1 : 2 * params.stim.nFrames
                
                if n <= params.stim.nFrames % global and location motion direction change
                    k = -1; % gabor global direction: up= -1,down = 1
                    if td.stimCond(i,2) == 1; % internal motion left
                        d = -1;
                    else % internal motion right
                        d = 1;
                    end
                else
                    k = 1;
                    if td.stimCond(i,2) == 1; % internal motion left
                        d = 1;
                    else % internal motion right
                        d = -1;
                    end
                end
                
                % increment the counter
                frameCounter = frameCounter + 1;
                
                % Set the right blend function for drawing the gabors
                Screen('BlendFunction', scr.main, 'GL_ONE', 'GL_ZERO');
                
                % Draw the Gabor
                Screen('DrawTextures', scr.main, gaborid, [],dstRect, params.stim.angle, [], [], [], [],...
                    kPsychDontDoRotation, propertiesMat');
                
                % Change the blend function to draw an antialiased fixation point
                % in the centre of the array
                Screen('BlendFunction', scr.main, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
                
                % Draw the fixation and reference points
                drawFixationPoints(params.fix.offset);

                    
                % Flip drawings to the screen
                vbl = Screen('Flip', scr.main, vbl + (waitframes - 0.5) * scr.fd);
                
                if design.record
                    currFrame = Screen('GetImage', scr.main);
                    writeVideo(vidObj,currFrame);
                end
                
                % Increment the phase and location of the Gabors
                % Reverse the texture cue to show the other polarity if the time is up
                if td.stimCond(i,1) == 0
                    if design.experiment == 2 % flicker control
                        if frameCounter == checkFlipTimeFrames
                            propertiesMat(1)  = propertiesMat(1) + 180;
                            frameCounter = 0;
                        end
                    else % static Gabor control
                        propertiesMat(1) = propertiesMat(1);
                    end
                else
                    propertiesMat(1) = propertiesMat(1) - d * params.stim.phasePerFrame  ;
                end
                dstRect(2) = dstRect(2) +  k *  params.stim.speedpx;
                dstRect(4) = dstRect(4) +  k *  params.stim.speedpx;
                
            end
            
            if m < params.stim.repeats
                start_break = GetSecs;
                
                while 1
                    
                    % Change the blend function to draw an antialiased fixation point
                    % in the centre of the array
                    Screen('BlendFunction', scr.main, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
                    
                    % Draw the fixation and reference points
                    drawFixationPoints(params.fix.offset);
                    
                    % Perform initial flip to gray background:
                    vbl = Screen('Flip', scr.main, vbl + (waitframes - 0.5) * scr.fd);
                    
                    if design.record
                        currFrame = Screen('GetImage', scr.main);
                        writeVideo(vidObj,currFrame);
                    end

                    if vbl - start_break >  params.stim.ISI
                        break;
                    end
                end
            end
        end
        %% Response period
        Beeper(800,.1,.05);
        
        start_resp = GetSecs; % record start time of response
        
        while nextTrial == false;
            
            newtrial = 0;
            
            % set bounds to angle adjustment
            if  params.ref.pathAngle > 90
                params.ref.pathAngle = -(180 - params.ref.pathAngle );
            elseif     params.ref.pathAngle <-90
                params.ref.pathAngle = 180 + params.ref.pathAngle;
            end
            
            % Change the blend function to draw an antialiased fixation point
            % in the centre of the array
            Screen('BlendFunction', scr.main, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
            
            % Draw the fixation and reference points
            drawFixationPoints(params.fix.offset);
            drawRefLine(params.ref.pathAngle, params.ref.color);

            if design.DEBUG && ~design.record
                % show path angle
                text1 = ['Path Angle = ',num2str(params.ref.pathAngle)];
                Screen('DrawText',scr.main,text1,0,textRect1(4),[255,255,255]);
            end
            
            % Perform initial flip to gray background:
            vbl = Screen('Flip', scr.main, vbl + (waitframes - 0.5) * scr.fd);
            
            % Check the keyboard to see if a button has been pressed
            % and record the number of presses
            [keyIsDown,~, keyCode] = KbCheck;
            if keyIsDown
                if keyCode(keys.upKey)
                    params.ref.pathAngle = params.ref.pathAngle - params.ref.anglesPerFrame ;
                elseif keyCode(keys.downKey)
                    params.ref.pathAngle = params.ref.pathAngle + params.ref.anglesPerFrame ;
                elseif keyCode(keys.space) % press space with a new random initial angle
                    newtrial = 1;
                    td.Resp(i,2) = GetSecs - start_resp;
                end
            end
            
            if newtrial
                td.Resp(i,1) = params.ref.pathAngle;
                nextTrial = true;
            end
            
        end
    end
    
    if design.record
        close(vidObj);
    end
    
    % analysis
    
    % find outlier
    threshold = 20;
    motIdx = find(td.stimCond(:,1) == 1);
    
    for ii = 1:length(motIdx)
        idx = motIdx(ii);
        if td.stimCond(idx,2) == 1 && td.Resp(idx,1) > threshold
            td.Resp(idx,1) = NaN;
        elseif td.stimCond(idx,2) == 2 && td.Resp(idx,1) < -threshold
            td.Resp(idx,1) = NaN;
        end
    end
    
    if any(abs(td.Resp(td.stimCond(:,1) == 0,1)) > threshold)
        phyIdx = find( td.stimCond(:,1) == 0);
        phyConds = td.Resp(phyIdx,1);
        phyOutIdx = find(phyConds(abs(phyConds) > threshold));
        fprintf('\n\nfind %d physical outlier = %.0f .\n\n', numel(phyIdx), phyConds(phyOutIdx));
        td.Resp(phyIdx(phyOutIdx),1) = NaN;
    end
    
    td.pAgl = nanmean(abs(td.Resp(td.stimCond(:,1) == 1,1)));
    td.phAgl = nanmean(td.Resp(td.stimCond(:,1)== 0,1));
    td.mean_illusionSize = td.pAgl - td.phAgl;
    
    % Clear screen
    ListenChar(1);
    ShowCursor;
    Screen('CloseAll');
    clear mex;
    clear fun;
    %home;
    
    
    fprintf(1,'\n\nThis part of the experiment took %.0f min.',(toc)/60);
    fprintf(1,'\n\nOK!\n');
    fprintf(1,'\n\nAveraged illusion Size = %s\n',num2str(td.mean_illusionSize));
    
    
    %save data (dropbox and local dir)
    dataDir_db= ([pathToExpt,'retinotopy4/DDA/vertical/data/', participant.identifier]);
    dataDir_lc = (['../../Data/retinotopy4/DDA/data/',participant.identifier]);
    
    if ~exist(dataDir_db,'dir')
        mkdir(dataDir_db);
    end
    
    if ~exist(dataDir_lc,'dir')
        mkdir(dataDir_lc);
    end
    
    save([dataDir_db,'/',participant.identifier,'_', datestr(now,'yyyymmdd-HHMM'),'_', exptName,'.mat']);
    save([dataDir_lc,'/',participant.identifier,'_', datestr(now,'yyyymmdd-HHMM'),'_', exptName,'.mat']);
    
catch
    Screen('CloseAll')
    rethrow(lasterror)
end


end






