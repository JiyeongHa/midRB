function midRB
% Nov 20, 2017 written by JYH
% Felix monitor size : 52 x 29
% monitors in experiment settings size: 32 x 24 
% consists of 3 sessions with different image sets: Ori/tex/Pat
% inter-mixed design 
% response keys: odd num S-s-d-D / even num D-d-s-S (6-7-8-9)
% 2x3 factors
% 2: between stream vs. within stream
% 3: Same stimuli, Same category, Diff category
% practice: trials each
% Main experiment: 
% SN, ses, trial, BS, C1AI, CD, C2AI, C1itm, C2itm, M1h, M2h, ANS, Resp, Cor, RT

try
    main
catch me % error handling
    clearEnvironment;
    fprintf(2, '\n\n???:: %s\n\n', me.message); % main error message
    for k = 1:(length(me.stack) - 1)
        Current = me.stack(k);
        fprintf('Error in ==> ');
        fprintf('<a href="matlab: opentoline(''%s'',%d,0)">%s at %d</a>\n\n',...
            Current.file, Current.line, Current.name, Current.line);
    end
    fclose('all');
end
return

%% Experiment 
function main
testMode = [0, 0, 0]; % set all 0 at real game.

fastMode = testMode(1); %1 fast
skipSync = testMode(2);
winSize  = testMode(3); % 0 for full size, 1 for 800x600 size

Screen('Preference', 'SkipSyncTests', skipSync);  % When you use CRT monitor, set 0.
Screen('Preference', 'TextRenderer', 0);   % When you use high quality Korean font, set 1.
Screen('Preference', 'TextAntiAliasing', 1);
Screen('Preference', 'TextAlphaBlending', 0);
Screen('Preference', 'DefaultTextYPositionIsBaseline', 0); % should be set 0 for drawtexture on center line
% -------------------------------------------------- SETUPS

S = getParticipantInfo;
D = getStudyDesign;
W = openWindow(fastMode, winSize);
V = setVariables(S, W);
CF = getConfiguration(V, W);

prepareEnvironment; % random seed, hide cursor, etc.
K = KeyboardSetup(S, 'external'); % external or internal

expName = 'midRB';
F = openFiles(expName, S); % open log files

data_dir = fullfile(pwd, sprintf('data_%s', expName));
if exist(data_dir,'dir')~=7
    mkdir(data_dir);
end

clear expName;
% -------------------------------------------------- PREPARE STIMULI
logStart(F, S); % open log files
% -------------------------------------------------- GET STARTED
showInstruction('inst_start.txt', K, S, V, W);

Screen('FillRect', W.on, V.bColor);
Screen('Flip', W.on);
WaitSecs(W.dur1000);

for trial = 1:D.nTRIAL
    
    C = setConditions(trial, D);
    CI = getTrialTargets(C, V, W);
    MI = getTrialDistractors(C, V, W);
    SS = setStream(C, CI, MI); %streams
    st1 = SS.frames(SS.sInx,:); st2 = SS.frames(SS.inv,:);
    
    % ----
    Screen('DrawTexture', W.on, CF.texFix);
    tflip = Screen('Flip', W.on);
    Screen('DrawTexture', W.on, CF.texFix);
    tflip = Screen('Flip', W.on, tflip+W.dur380);

    % show objects
    % present each frame for .12 sec with dark-gray outer borders
    for i = 1:V.frmNum
        Screen('DrawTexture', W.on, CF.texFix);
        Screen('DrawTexture', W.on, st1(i), [], CF.stimLo(SS.sInx,:));
        Screen('DrawTexture', W.on, st2(i), [], CF.stimLo(SS.inv,:));
        Screen('FrameRect', W.on, V.frColor, CF.frmLo', V.frThick);
        tflip = Screen('Flip', W.on, tflip + W.dur120);
    end
    Screen('Flip', W.on, tflip + W.dur120);
    promptResponse(V, W);
    StimOnSet = Screen('Flip', W.on, tflip);
    % --------------- Collect response
    % Response for a main task & confidence rating 
[D.dResp(C.it), D.dRT(C.it), D.dCorr(C.it)] = getResponse(C, K, S, W, StimOnSet);


    % log data [SN, trial, PF, DP, ST, CG, BS1, AI1, ITM1, AI2, ITM2, RT, Resp, AW, Corr]
    fprintf(    'SN:%02d, trial:%d, PF:%d, DP:%d, ST:%d, CG:%d, BS1:%d, AI1:%d, ITM1:%02d, AI2:%d, ITM2:%02d, RT:%2.4f, Resp:%d, AW:%d, Corr:%d\n',...
        S.SN, trial, C.xPF, C.xDP(1,1), C.xST, C.xCG, C.xBS(1,1), C.xAI(1,1), C.xItm(1,1), C.xAI(2,1), C.xItm(2,1), D.dRT(C.it), D.dResp(C.it), C.xAW, D.dCorr(C.it));
    fprintf(F.stmFile, '%02d, %d, %d, %d, %d, %d, %d, %d, %02d, %d, %02d, %2.4f, %d, %d, %d\n',...
        S.SN, trial, C.xPF, C.xDP(1,1), C.xST, C.xCG, C.xBS(1,1), C.xAI(1,1), C.xItm(1,1), C.xAI(2,1), C.xItm(2,1), D.dRT(C.it), D.dResp(C.it), C.xAW, D.dCorr(C.it));
    fprintf(F.datFile, '%02d, %d, %d, %d, %d, %d, %d, %d, %02d, %d, %02d, %2.4f, %d, %d, %d\n',...
        S.SN, trial, C.xPF, C.xDP(1,1), C.xST, C.xCG, C.xBS(1,1), C.xAI(1,1), C.xItm(1,1), C.xAI(2,1), C.xItm(2,1), D.dRT(C.it), D.dResp(C.it), C.xAW, D.dCorr(C.it));
   
    tflip = Screen('Flip', W.on);
    WaitSecs(W.dur500);
    % break
    checkBreak(D, K, trial, V, W, fastMode);
    
    
end
% -------------------------------------------------- LETS WRAP UP...
showInstruction('inst_ending.txt', K, S, V, W);
fprintf(           '\n***** Experiment ended at %s\n', datestr(now, 0));
fprintf(F.stmFile, '\n***** Experiment ended at %s\n', datestr(now, 0));
save(F.prmFile);

clearEnvironment;

return




%% SubFunctions 
function participantInfo = getParticipantInfo

prompt = {'Enter subject number: ', 'DirectIN button box? (0-no, 1-yes)'};
defaults = {'99', '0'};
answer = inputdlg(prompt, 'Experimental setup information', 1, defaults);
[participantInfo.SN, BBox] = deal(answer{:});

participantInfo.SN = str2double(participantInfo.SN);
participantInfo.BBox = str2double(BBox);

% Response key counterbalance index
if mod(participantInfo.SN,2)==1
    participantInfo.CountRes = 1;
elseif mod(participantInfo.SN,2)==0
    participantInfo.CountRes = 2;
end

return

function window = openWindow(fastMode, winSize)

window.screenNumber = min(Screen('Screens')); % determining a dual monitor setup.
if ~winSize
    [window.on, window.screenRect] = Screen('OpenWindow', window.screenNumber);
else
    [window.on, window.screenRect] = Screen('OpenWindow', window.screenNumber, [],[0 0 1024 768]);
end
[window.cx, window.cy] = RectCenter(window.screenRect);
window.screenX = RectWidth(window.screenRect);
window.screenY = RectHeight(window.screenRect);

% for using PNG's transparency
Screen('BlendFunction', window.on, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Basic drawing and screen variables.
window.black    = BlackIndex(window.on);
window.white    = WhiteIndex(window.on);
window.gray     = GrayIndex(window.on);
% window.fontsize = 10;

blanking = Screen('GetFlipInterval', window.on);
if ~fastMode
    window.dur120	= (round(0.12/blanking)-0.5)*blanking;
    window.dur380	= (round(0.38/blanking)-0.5)*blanking;
    window.dur500	= (round(0.5/blanking)-0.5)*blanking;
    window.dur1000	= (round(1.0/blanking)-0.5)*blanking;
    window.dur5000	= (round(5.0/blanking)-0.5)*blanking;
else
    window.dur120	= (round(0.01/blanking)-0.5)*blanking;
    window.dur380	= (round(0.01/blanking)-0.5)*blanking;
    window.dur500	= (round(0.01/blanking)-0.5)*blanking;
    window.dur1000	= (round(0.01/blanking)-0.5)*blanking;
    window.dur5000	= (round(0.01/blanking)-0.5)*blanking;
end
return

function fileNames = openFiles(ExpName, participantInfo)

baseName = sprintf('%ss%02d', ExpName, participantInfo.SN);
fileNames.datFile = fopen(sprintf('datRaw_%s.csv', baseName), 'a');
fileNames.stmFile = fopen(sprintf('datStm_%s.csv', baseName), 'a'); % exp duration, time, etc
fileNames.prmFile = sprintf('prmVar_%s.mat', baseName); % save matlab Variables
clear baseName;
return

function logStart(fileNames, participantInfo)

            fprintf(                  '\n***** Participant s%02d, experiment begins at %s\n',participantInfo.SN,datestr(now, 0));
            fprintf(fileNames.stmFile,'\n***** Participant s%02d, experiment begins at %s\n',participantInfo.SN,datestr(now, 0));
            fprintf(fileNames.stmFile,'SN, trial, PF, DP, ST, CG, BS1, AI1, ITM1, AI2, ITM2, RT, Resp, AW, Corr\n');
            fprintf(fileNames.datFile,'SN, trial, PF, DP, ST, CG, BS1, AI1, ITM1, AI2, ITM2, RT, Resp, AW, Corr\n');
return

function variables = setVariables(participantInfo, window)

variables.bColor = window.gray;	% background color
variables.fixationColor	= 255;


if participantInfo.CountRes == 1
    variables.textPromptMessage = 'S - s - d - D';
elseif participantInfo.CountRes == 2
    variables.textPromptMessage = 'D - d - s - S';
end

variables.imgdir = {'ori', 'tex', 'nocrosscorr'};

vWidth = 32; % horizontal dimension of viewable screen (cm) %31 52
vDist	= 64; % viewing distance (cm)
variables.ppd = pi * RectWidth(window.screenRect) / atan(vWidth/vDist/2) / 360; % pixels per degree

variables.imgSize  = [0 0 1 1]*round(variables.ppd * 5); % img size 

variables.geccent	= round(variables.ppd * 8.2);  % eccentricity of stimuli (degree x ppd)
variables.gNumLoc = 2;
variables.gXY = round(zeros(variables.gNumLoc, 2));

for mm=1:variables.gNumLoc
    deg=360/variables.gNumLoc/2 + (360/variables.gNumLoc)*(mm-1);
    variables.gXY(mm,1) = window.cx + variables.geccent * sin(deg*pi/180); %x
    variables.gXY(mm,2) = window.cy - variables.geccent * cos(deg*pi/180); %y
end


variables.frmNum = 7;
variables.maskNum = variables.frmNum - 2;

variables.frThick = 3;
variables.frColor = 0;
variables.frmSize = variables.imgSize*1.03;

variables.instFontSize = 25;    % Korean font size
variables.instFontColor = 255;  % Korean font color

variables.tSize = 500;
variables.tColor = 0;
variables.textPromptSize = 24;		% english text
variables.textPromptColor = 255;
variables.textPromptOffsetX = 0;
variables.textPromptOffsetY = 0;

variables.textHanSize = 28;		% hangul text
variables.textHanColor = 255;

variables.txtdir = 'txtdir';

fid = fopen(fullfile(pwd, variables.txtdir, 'inst_feed_slow.txt'), 'r', 'n','UTF-8');
txtSlow = fread(fid, '*char');
fclose(fid);
variables.txtSlow = double(transpose(txtSlow));

%randblock related
variables.imgDimentions = [440, 100, 192];
variables.blockSizes = [16, 8, 1]; %8 12 16 24 32 48 64  %v1midRB: 16, 8, 1
variables.gridScrambled = cell(1,3);
for e=1:length(variables.blockSizes)
variables.gridScrambled{1,e} = 1:variables.blockSizes(e):variables.imgDimentions(3);
variables.gridScrambled{1,e}(end+1) = variables.imgDimentions(e);
end
return

function configuration = getConfiguration(variables, window)

% fixation texture
fixation = zeros(15,15); % fixation size 7 pixel to meet 0.209 deg
fixation(8,:) = variables.fixationColor;
fixation(:,8) = variables.fixationColor;
idx = (fixation < 1); % match the background colour 130
fixation(idx) = variables.bColor;
configuration.texFix = Screen('Maketexture', window.on, fixation);
clear fixation idx;

%image locations
configuration.stimLo = zeros(2,4); 
configuration.stimLo(1,:) = CenterRectOnPoint(variables.imgSize, variables.gXY(2,1), variables.gXY(2,2)); % Left
configuration.stimLo(2,:) = CenterRectOnPoint(variables.imgSize, variables.gXY(1,1), variables.gXY(1,2)); % Right

%frame locations 
configuration.frmLo = zeros(2,4); 
configuration.frmLo(1,:) = CenterRectOnPoint(variables.frmSize, variables.gXY(2,1), variables.gXY(2,2)); % Left
configuration.frmLo(2,:) = CenterRectOnPoint(variables.frmSize, variables.gXY(1,1), variables.gXY(1,2)); % Right


return

function currentCond = setConditions(trial, currentDesign)

% conditions
currentCond.it  = currentDesign.xOrder(trial); % randomized order
currentCond.xPF = currentDesign.cPF(currentCond.it);
currentCond.xST = currentDesign.cST(currentCond.it);
currentCond.xCG = currentDesign.cCG(currentCond.it);
currentCond.xAW = currentDesign.cAW(currentCond.it);
%C1-C2
currentCond.xDP(:,:) = currentDesign.cDP(:, currentCond.it);
currentCond.xBS(:,:) = currentDesign.cBS(:, currentCond.it); 
currentCond.xAI(:,:) = currentDesign.cAI(:, currentCond.it); 
currentCond.xItm(:,:) = currentDesign.cItm(:, currentCond.it); 
%distractors
currentCond.xDPF = currentDesign.cDPF(currentCond.it);
currentCond.xDBS = currentDesign.cDBS(currentCond.it);
currentCond.xLDAI(:,:) = currentDesign.cLDAI(:,currentCond.it);
currentCond.xRDAI(:,:) = currentDesign.cRDAI(:,currentCond.it);
currentCond.xLDItm(:,:) = currentDesign.cLDItm(1:5,currentCond.it);
currentCond.xRDItm(:,:) = currentDesign.cRDItm(1:5,currentCond.it);
currentCond.xMAI = [currentCond.xLDAI, currentCond.xRDAI];
currentCond.xMItm = [currentCond.xLDItm, currentCond.xRDItm];
currentCond.xSItm = [currentDesign.cLDItm(6,currentCond.it), currentDesign.cRDItm(6,currentCond.it)]; %spare 
return

function criticalItems = getTrialTargets(currentCond, variables, window)

criticalItems.Imgdir = fullfile(pwd, variables.imgdir{currentCond.xPF});
for e=1:2
    CrItm = sprintf('%d%d%02d.jpg', currentCond.xBS(e,1), currentCond.xAI(e,1), currentCond.xItm(e,1));
    imgpix = imread(fullfile(criticalItems.Imgdir, CrItm));
    criticalItems.Crpix(e) = Screen('MakeTexture', window.on, imgpix);
end

return

function maskItems = getTrialDistractors(currentCond, variables, window)

maskItems.DImgdir = fullfile(pwd, variables.imgdir{currentCond.xDPF});
for k=1:2 %left and right
    for e=1:variables.maskNum
        DItm = sprintf('%d%d%02d.jpg', currentCond.xDBS, currentCond.xMAI(e,k), currentCond.xMItm(e,k));
        pix = imread(fullfile(maskItems.DImgdir, DItm));
        pixRblocked = randblock(pix, variables.blockSizes(currentCond.xPF));
        
%         pixRblocked(variables.gridScrambled{currentCond.xPF}, :) = variables.frColor;
%         pixRblocked(:, variables.gridScrambled{currentCond.xPF}) = variables.frColor;
        maskItems.Dpix(e,k) = Screen('MakeTexture', window.on, pixRblocked);
    end
    %spares
        DItm = sprintf('%d%d%02d.jpg', currentCond.xDBS, currentCond.xMAI(6,k), currentCond.xSItm(1,k));
        pix = imread(fullfile(maskItems.DImgdir, DItm));
        pixRblocked = randblock(pix, variables.blockSizes(currentCond.xPF));
%         pixRblocked(variables.gridScrambled{currentCond.xPF}, :) = variables.frColor;
%         pixRblocked(:, variables.gridScrambled{currentCond.xPF}) = variables.frColor;
        maskItems.Spix(1,k) = Screen('MakeTexture', window.on, pixRblocked);
    
end


return

function imageStream = setStream(currentCond, criticalItems, maskItems)

imageStream.frames = zeros(2,7); 
twoIndex = [2 1];
sInx = currentCond.xDP(1,1);
inv = twoIndex(currentCond.xDP(1,1));
if currentCond.xDP(1,1) == currentCond.xDP(2,1) %within
    imageStream.frames(sInx,:) = [maskItems.Dpix(1,sInx), maskItems.Dpix(2,sInx),...
        criticalItems.Crpix(1,1), maskItems.Dpix(3,sInx), criticalItems.Crpix(1,2), maskItems.Dpix(4,sInx), maskItems.Dpix(5,sInx)]; 
    imageStream.frames(inv,:) = [maskItems.Dpix(1,inv), maskItems.Dpix(2,inv),...
        maskItems.Dpix(3,inv), maskItems.Dpix(4,inv), maskItems.Dpix(5,inv), maskItems.Spix(1,1), maskItems.Spix(1,2)]; 
elseif currentCond.xDP(1,1) ~= currentCond.xDP(2,1) %between
        imageStream.frames(sInx,:) = [maskItems.Dpix(1,sInx), maskItems.Dpix(2,sInx),...
        criticalItems.Crpix(1,1), maskItems.Dpix(3,sInx), maskItems.Dpix(4,sInx), maskItems.Dpix(5,sInx), maskItems.Spix(1,1)]; 
    imageStream.frames(inv,:) = [maskItems.Dpix(1,inv), maskItems.Dpix(2,inv),...
        maskItems.Dpix(3,inv), maskItems.Dpix(4,inv), criticalItems.Crpix(1,2), maskItems.Dpix(5,inv), maskItems.Spix(1,2)]; 
end

imageStream.sInx = sInx; imageStream.inv = inv;

return


function deviceIndex = IDKeyboards(kbStruct)
        devices	= PsychHID('Devices');
        kbs		= find([devices(:).usageValue]==6); % value of keyboard

        deviceIndex = [];
        for mm=1:length(kbs)
            if strcmp(devices(kbs(mm)).product,kbStruct.product) && ...
                    ismember(devices(kbs(mm)).vendorID, kbStruct.vendorID)
                deviceIndex = kbs(mm);
            end
        end

        if isempty(deviceIndex)
            error('No %s detected on the system',kbStruct.product);
        end
return

function keyboard = KeyboardSetup(participantInfo, type)
%Type and print out deviceName. See what input devices you are connected.
%[keyboardIndex, deviceName, allInfo] = GetKeyboardIndices

% ===== Experimenter
if strcmp(type,'external')
    device(1).product = 'Apple Keyboard'; 	% MacPro, external
elseif strcmp(type,'internal')
    device(1).product = 'Apple Internal Keyboard / Trackpad';	% MacBook Air, internal
end
device(1).vendorID= 1452;	% Apple Inc.

        % ===== Participant
        % Empirisoft Research Software DirectIN
        device(2).product = 'DirectIN Hardware';
        device(2).vendorID= 6017;

        keyboard.Experimenter = IDKeyboards(device(1));  % See below.
        keyboard.Participant  = keyboard.Experimenter;

        % If you are using a button box, declare a variable below.
        if participantInfo.BBox, keyboard.Participant = IDKeyboards(device(2)); end
        
        keyboard.main = KbName({'2@', '3#', '7&', '8*'}); % S-s-d-D
        keyboard.GO = KbName('1!');
return

function showInstruction(txtfile, keyboard, participantInfo, variables, window)
txtdir = fullfile(pwd, variables.txtdir);

        % below see DrawHighQualityUnicodeTextDemo.m
        allFonts = FontInfo('Fonts');
        foundfont = 0;
        for idx = 1:length(allFonts)
                if strcmpi(allFonts(idx).name, '08SeoulNamsan EB')
                        foundfont = 1;
                        break;
                end
        end
 
        if ~foundfont
                error('Could not find wanted korean font on OS/X !');
        end
       
        % Text files edited with a text editor such as vi or nano.
        if strcmp(txtfile, 'inst_start.txt') && participantInfo.CountRes==1
            txtfile = 'inst_start1.txt';
        elseif strcmp(txtfile, 'inst_start.txt') && participantInfo.CountRes==2
            txtfile = 'inst_start2.txt';
        end
        fid = fopen(fullfile(txtdir, txtfile), 'r', 'n','UTF-8');
        xtext = fread(fid, '*char');
        fclose(fid);
        xtext = double(transpose(xtext));
       
        Screen('TextFont', window.on, allFonts(idx).name);
        Screen('TextColor', window.on, variables.instFontColor);
        Screen('TextSize', window.on, variables.instFontSize);
        Screen('TextStyle',window.on, 1);
       
        Screen('FillRect', window.on, variables.bColor);
        DrawFormattedText(window.on, xtext, 'center', 'center');
        Screen('Flip', window.on);
        while 1
                [keyIsDown, ~, keyCode] = KbCheck(keyboard.Participant);
                if keyIsDown
                        if keyCode(keyboard.GO)
                                break;
                        end
                end
        end
        Screen('FillRect', window.on, variables.bColor);
        Screen('Flip', window.on); 
return

function promptResponse(variables, window)

	[oldFontName,~,oldTextStyle] = Screen('TextFont', window.on, 'Arial', 0);
	oldTextSize = Screen('TextSize', window.on, variables.textPromptSize);

	xoffset = variables.textPromptOffsetX;
	yoffset = variables.textPromptOffsetY;	
	color = variables.textPromptColor;	
	message = variables.textPromptMessage;
    
	bounds = Screen('TextBounds', window.on, message);
	Screen('DrawText', window.on, message, window.cx-bounds(3)/2+xoffset, ...
			window.cy-bounds(4)/2+yoffset, color);
		
	Screen('TextFont', window.on, oldFontName, oldTextStyle);	
	Screen('TextSize', window.on, oldTextSize);
return

function [dResp, dRT, dCorr] = getResponse(currentCond, keyboard, participantInfo, window, timeFlip)

dResp=7; dRT=7; dCorr=7;
% create response queue
keysOfInterest = zeros(1,256);
duration = window.dur5000;
keysOfInterest(keyboard.main) = 1;
KbQueueCreate(keyboard.Participant, keysOfInterest);
KbQueueStart(keyboard.Participant); % start collecting response
KbQueueFlush(keyboard.Participant);

rGO = 1;
while (rGO==1) && (GetSecs-timeFlip < duration)
    [pressed, firstPress] = KbQueueCheck(keyboard.Participant);
    
    if pressed
        sT = min(firstPress(firstPress ~= 0));	% shortest time
        xKey = find(firstPress == sT);	% key with the shortest time
        if length(xKey) > 1
            dCorr = 6;
        else
            if participantInfo.CountRes == 1
                dResp = find(keyboard.main == xKey); % S s d D 6 7 8 9
            elseif participantInfo.CountRes == 2
                dResp = 5-(find(keyboard.main == xKey));   %[6 7 8 9] to [9 8 7 6];
            end
            dCorr = (ceil(rdivide(dResp,2)) == currentCond.xAW);
            dRT   = sT - timeFlip;
        end
        rGO=0; % stop collecting response
    end
end

Screen('Flip', window.on);
KbQueueRelease(keyboard.Participant);

return

function checkBreak(currentDesign, keyboard, trial, variables, window, fastMode)

        
        if mod(trial, currentDesign.bTRIAL)==0 && (trial < currentDesign.nTRIAL)
            cntBlk = (currentDesign.nTRIAL-trial)/currentDesign.bTRIAL;
            
            Screen('TextFont',  window.on, '08SeoulNamsan EB');
            Screen('TextColor', window.on, variables.instFontColor);
            Screen('TextSize',  window.on, variables.instFontSize);
            Screen('TextStyle', window.on, 1);
            
            rText = sprintf('Take a rest. Press start button to continue...');
            if cntBlk==1
                bText = sprintf('%d block remains.', cntBlk);
            else
                bText = sprintf('%d blocks remain.', cntBlk);
            end
            rBound = Screen('TextBounds', window.on, rText)/2;
            bBound = Screen('TextBounds', window.on, bText)/2;
            Screen('DrawText', window.on, rText, window.cx-rBound(3), window.cy-rBound(4)    , variables.instFontColor);
            Screen('DrawText', window.on, bText, window.cx-bBound(3), window.cy-bBound(4)-200, variables.instFontColor);
            Screen('Flip', window.on);
            bGO = 1;
            
            if fastMode
                bGO = 0;
            end
            
            while bGO
                [keyIsDown, ~, keyCode] = KbCheck(keyboard.Participant);
                if keyIsDown
                    if keyCode(keyboard.GO)
                        bGO = 0;
                    end
                end
            end
            Screen('Flip', window.on);
            WaitSecs(window.dur1000);
            
        end
return



