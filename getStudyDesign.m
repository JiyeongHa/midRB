


function currentDesign = getStudyDesign

% Pictures 
PF = 3; % Pic folder: original, texforms, or patterns(nohighcorr)
itmNum = 30; % Item number in one categories 
% First item(C1)
DP = 2; % Left or Right
BS = 2; % big or small
AI = 2; % animacy or inanimacy 
%stream
ST = 2; % Stream: Within or Between
% condition
CG = 3; % Same items, Same categories, or different categories
%picture sources
% distractor
DAI = 2;
% cDPF
% cDBS
% cLDAI(1,5)
% cRDAI(1,5)
% cDIitm(1,5)

REP = 3;
BLOCK = 8;
currentDesign.nTRIAL = PF*DP*BS*AI*ST*CG*DAI*REP; % Total 864. DP, DAI should be excluded when counting real trials per cond
currentDesign.bTRIAL = currentDesign.nTRIAL/BLOCK;

currentDesign.dResp   = ones(1,currentDesign.nTRIAL)*7; % S-s-d-D
currentDesign.dSD     = ones(1,currentDesign.nTRIAL)*7; % Answer:Same 1 or Different 2
currentDesign.dRT     = ones(1,currentDesign.nTRIAL)*7; % response time
currentDesign.dCorr   = ones(1,currentDesign.nTRIAL)*7; % 1 for correct, 2 for incorrect.
currentDesign.xOrder  = Shuffle(1:currentDesign.nTRIAL);

%% First item(C1)
xIndex=0:(currentDesign.nTRIAL-1);
currentDesign.cPF = 0:(currentDesign.nTRIAL-1);
currentDesign.cPF(mod(xIndex,PF)==0)=1; % Originals
currentDesign.cPF(mod(xIndex,PF)==1)=2; % Texforms
currentDesign.cPF(mod(xIndex,PF)==2)=3; % Patterns

currentDesign.cDP = 0:(currentDesign.nTRIAL-1);
currentDesign.cDP(mod(fix(xIndex/PF),DP)==0)=1; % Left
currentDesign.cDP(mod(fix(xIndex/PF),DP)==1)=2; % Right

currentDesign.cBS = 0:(currentDesign.nTRIAL-1);
currentDesign.cBS(mod(fix(xIndex/(PF*DP)),BS)==0)=1; % Big
currentDesign.cBS(mod(fix(xIndex/(PF*DP)),BS)==1)=2; % Small

currentDesign.cAI = 0:(currentDesign.nTRIAL-1);
currentDesign.cAI(mod(fix(xIndex/(PF*DP*BS)),BS)==0)=1; % Big
currentDesign.cAI(mod(fix(xIndex/(PF*DP*BS)),BS)==1)=2; % Small

currentDesign.cItm = zeros(1, currentDesign.nTRIAL); %image number for C1
    Itmindex = 1:itmNum;           %item number (randomly shuffled in each category)
    for bs = 1:2
        for ani = 1:2
            RdS = repmat(Shuffle(Itmindex), 1, ceil(currentDesign.nTRIAL/itmNum)); %Shuffle the order or item presented in each category
            Inx = find(currentDesign.cBS == bs & currentDesign.cAI == ani);
            for e = 1:length(Inx)
                    currentDesign.cItm(Inx(e)) = RdS(e);
            end
        end
    end



%% Stream x Category

currentDesign.cST = 0:(currentDesign.nTRIAL-1);
currentDesign.cST(mod(fix(xIndex/(PF*DP*BS*AI)),ST)==0)=1; 
currentDesign.cST(mod(fix(xIndex/(PF*DP*BS*AI)),ST)==1)=2; 

currentDesign.cCG = 0:(currentDesign.nTRIAL-1);
currentDesign.cCG(mod(fix(xIndex/(PF*DP*BS*AI*ST)),CG)==0)=1; %Same item
currentDesign.cCG(mod(fix(xIndex/(PF*DP*BS*AI*ST)),CG)==1)=2; %Same category
currentDesign.cCG(mod(fix(xIndex/(PF*DP*BS*AI*ST)),CG)==2)=3; %Diff category 

currentDesign.cAW = 0:(currentDesign.nTRIAL-1);
currentDesign.cAW(mod(fix(xIndex/(PF*DP*BS*AI*ST)),CG)==0)=1; % Answer:Same 1
currentDesign.cAW(mod(fix(xIndex/(PF*DP*BS*AI*ST)),CG)==1)=2; % Diff 2
currentDesign.cAW(mod(fix(xIndex/(PF*DP*BS*AI*ST)),CG)==2)=2; % Diff 2

%% Second item(C2)

DPindex = [2 1]; AIindex = DPindex;
for e = 1:currentDesign.nTRIAL
    
    % Location(left or right):
    % depending on cDP(1,:) and cST
    if currentDesign.cST(e) == 1
        currentDesign.cDP(2,e) = currentDesign.cDP(1,e);
    elseif currentDesign.cST(e) == 2
        currentDesign.cDP(2,e) = DPindex(currentDesign.cDP(1,e));
    end
    
    % Real-world size:
    % depending on cBS(1,:) only
    currentDesign.cBS(2, e)=currentDesign.cBS(1, e);
    
    % Animacy-Inanimacy:
    % depending on cAI(1,:) and cGG
    if currentDesign.cCG(e) == 1
        currentDesign.cAI(2,e) = currentDesign.cAI(1,e);
    elseif currentDesign.cCG(e) == 2
        currentDesign.cAI(2,e) = currentDesign.cAI(1,e);
    elseif currentDesign.cCG(e) == 3
        currentDesign.cAI(2,e) = AIindex(currentDesign.cAI(1,e));
    end
    
    % Item number:
    % depending on cItm(1,:) and cCG
    if currentDesign.cCG(e) == 1
        currentDesign.cItm(2,e) = currentDesign.cItm(1,e);
    elseif currentDesign.cCG(e) == 2
        currentDesign.cItm(2,e) = randsample(Itmindex(~ismember(Itmindex, currentDesign.cItm(1,e))), 1);
    elseif currentDesign.cCG(e) == 3
        currentDesign.cItm(2,e) = randsample(Itmindex, 1);
    end
    
end

%% Nohighcorr Distractors(Left and Right each D1,D2,D3,D4,D5)

% using nocorr in order to insist the results are due to curvature
currentDesign.cDPF = 0:(currentDesign.nTRIAL-1);
currentDesign.cDPF(:) = 3;

% % using each folders in order to adjust difficulty 
% currentDesign.cDPF(:) = currentDesign.cPF(:);

% counter-size category(i.e. BS-1, DBS-2)
currentDesign.cDBS = 0:(currentDesign.nTRIAL-1);
currentDesign.cDBS(mod(fix(xIndex/(PF*DP)),BS)==0)=2; % Big
currentDesign.cDBS(mod(fix(xIndex/(PF*DP)),BS)==1)=1; % Small


DAIvector = {[1 2 1 2 1 2], [2 1 2 1 2 1]}; 
currentDesign.cLDAI = 0:(currentDesign.nTRIAL-1);
currentDesign.cRDAI = 0:(currentDesign.nTRIAL-1);
currentDesign.cDItm = 0:(currentDesign.nTRIAL-1);
for e=1:currentDesign.nTRIAL
    
    ADitm = Shuffle(randsample(Itmindex, 6));
    IDitm = Shuffle(randsample(Itmindex, 6));
    DItmvector = {[ADitm(1), IDitm(1), ADitm(2), IDitm(2), ADitm(3), IDitm(3)],...
        [IDitm(4), ADitm(4), IDitm(5), ADitm(5), IDitm(6), ADitm(6)]};
    

    for k=1:6
        
        % Animacy-Inanimacy:
        % counterbalanced
        if mod(fix(xIndex(e)/(PF*DP*BS*AI*ST*CG)),DAI)==0
            currentDesign.cLDAI(k,e) = DAIvector{1}(k);
            currentDesign.cRDAI(k,e) = DAIvector{2}(k);
            currentDesign.cLDItm(k,e) = DItmvector{1}(k);
            currentDesign.cRDItm(k,e) = DItmvector{2}(k);
        else
            currentDesign.cLDAI(k,e) = DAIvector{2}(k);
            currentDesign.cRDAI(k,e) = DAIvector{1}(k);
            currentDesign.cLDItm(k,e) = DItmvector{2}(k);
            currentDesign.cRDItm(k,e) = DItmvector{1}(k);
        end
        
    end
    
end



return
