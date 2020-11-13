% PALAMEDES 
% Single alternative same-different analysis, 1AFC
% N(Stimuli per trial) = 2
% m(number of response options per trial) = 2
% reference to 6.2.5.2 d $ for 1AFC Same-Different
% "independent observation" or "differencing" strategy 
% PAL_SDT_1AFCsameDiff_IndMod_PHFtoDP
% PAL_SDT_1AFCsameDiff_IndMod_DPtoPHF
% m $ 2 matrix of pH s and pF s : d " and criterion C


clear all;


SN={};
SN{end+1} = {'01','01'};   % v2midRB(experiment1), v3midRB(experiment2)
SN{end+1} = {'02','02'};
SN{end+1} = {'03','03'};
SN{end+1} = {'04','04'};
SN{end+1} = {'05','05'};
SN{end+1} = {'06','06'};
SN{end+1} = {'07','07'};
SN{end+1} = {'08','08'};
SN{end+1} = {'09','09'};
SN{end+1} = {'10','10'};
SN{end+1} = {'11','11'};
SN{end+1} = {'12','12'};
SN{end+1} = {'13','13'};
SN{end+1} = {'14','14'};
SN{end+1} = {'15','15'};
SN{end+1} = {'16','16'};
SN{end+1} = {'17','17'};
SN{end+1} = {'18','18'};
SN{end+1} = {'19','19'};
SN{end+1} = {'21','20'};

%[SN1, trial2, PicFolder3, C1start(L/R)4, Stream5, Category6, BS17, AI18, ITM19, 10AI2, 11ITM2, 12RT, 13Resp, 14AW, 15Corr]
for exp = 1:2
    if exp == 1
    prefix = 'v2midRB';
    else
        prefix = 'v3midRB';
    end
addpath(fullfile(pwd, sprintf('data_%s', prefix)));

d_SCDC = fopen(sprintf('%s_dp_1AFC.csv', prefix), 'a');
c_SCDC = fopen(sprintf('%s_c_1AFC.csv', prefix), 'a');
% pH_SISCDC = fopen(sprintf('%s_pH.csv', prefix), 'a');


fprintf(d_SCDC, 'SN, OrixWitxSC, OrixWitxDC, OrixBetxSC, OrixBetxDC,');
fprintf(d_SCDC, 'TeXxWitxSC, TeXxWitxDC, TeXxBetxSC, TeXxBetxDC,');
fprintf(d_SCDC, 'PatxWitxSC, PatxWitxDC, PatxBetxSC, PatxBetxDC\n');

fprintf(c_SCDC, 'SN, OrixWitxSC, OrixWitxDC, OrixBetxSC, OrixBetxDC,');
fprintf(c_SCDC, 'TeXxWitxSC, TeXxWitxDC, TeXxBetxSC, TeXxBetxDC,');
fprintf(c_SCDC, 'PatxWitxSC, PatxWitxDC, PatxBetxSC, PatxBetxDC\n');

% fprintf(pH_SISCDC, 'SN, OrixWitxSI, OrixWitxSC, OrixWitxDC, OrixBetxSI, OrixBetxSC, OrixBetxDC,');
% fprintf(pH_SISCDC, 'TeXxWitxSI, TeXxWitxSC, TeXxWitxDC, TeXxBetxSI, TeXxBetxSC, TeXxBetxDC,');
% fprintf(pH_SISCDC, 'PatxWitxSI, PatxWitxSC, PatxWitxDC, PatxBetxSI, PatxBetxSC, PatxBetxDC\n');
    
for xsn = 1:length(SN)

TT = importdata(sprintf('datRaw_%ss%s.csv', prefix, SN{xsn}{exp}));
    TT = TT.data;
    
    
    %pic & stream & cond print for JASP (3x2x3=18)
    
    
    fRes = cell(length(SN), 3,2,3); pH = zeros(length(SN),3,2,3); pF = zeros(length(SN),3,2,3);
    dp = zeros(length(SN),3,2,3); c = zeros(length(SN),3,2,3);
    for pic = 1:3
        for st = 1:2
            for cond = 1:3
                fRes{xsn, pic,st,cond} = TT(TT(:,3) == pic & TT(:,5) == st &  TT(:,6) == cond, :);
            end 
            %same Item
            K = fRes{xsn,pic,st,1};
            pH(xsn,pic,st,1) = length(K(K(:,14) == 1 & K(:,15) == 1, 15)) / length(K(K(:,14) == 1, 15));  %ans-same & res-same / ans-same
            %SC
            V = fRes{xsn,pic,st,2}; 
            pH(xsn,pic,st,2) = length(V(V(:,14) == 2 & V(:,15) == 1, 15)) / length(V(V(:,14) == 2, 15));  %ans-diff & res-diff / ans-diff
            %DC 
            X = fRes{xsn,pic,st,3};
            pH(xsn,pic,st,3) = length(X(X(:,14) == 2 & X(:,15) == 1, 15)) / length(X(X(:,14) == 2, 15));  %ans-diff & res-diff / ans-diff
            
            %reference to same item
            %same item + same category 
            W = [K; V];
            pF(xsn,pic,st,2) = length(W(W(:,14) == 1 & W(:,15) == 0, 15)) / length(W(W(:,14) == 1, 15));
            %same item + diff category 
            D = [K; X];
            pF(xsn,pic,st,3) = length(D(D(:,14) == 1 & D(:,15) == 0, 15)) / length(D(D(:,14) == 1, 15));  
            
            if pF(xsn,pic,st,2) == 0
                pF(xsn,pic,st,2) = 1/48;
            end
            
            if pF(xsn,pic,st,3) == 0
                pF(xsn,pic,st,3) = 1/48;
            end
            
            if pF(xsn,pic,st,2) == 1
                pF(xsn,pic,st,2) = 1-(1/48);
            end
            
            if pF(xsn,pic,st,3) == 1
                pF(xsn,pic,st,3) = 1-(1/48);
            end
            
            if pH(xsn,pic,st,2) == 1
                pH(xsn,pic,st,2) = 1-(1/48);
            end
            
            if pH(xsn,pic,st,3) == 1
                pH(xsn,pic,st,3) = 1-(1/48);
            end
            
            
            if pH(xsn,pic,st,2) == 0
                pH(xsn,pic,st,2) = 1/48;
            end
            
            if pH(xsn,pic,st,3) == 0
                pH(xsn,pic,st,3) = 1/48;
            end
            
            
            % d' and c for each condition (pic, st)
            [dp(xsn,pic,st,2), c(xsn,pic,st,2)] = PAL_SDT_1AFC_PHFtoDP([pH(xsn,pic,st,2), pF(xsn,pic,st,2)]); %[dp(xsn,pic,st,2), c(xsn,pic,st,2)]
            [dp(xsn,pic,st,3), c(xsn,pic,st,3)] = PAL_SDT_1AFC_PHFtoDP([pH(xsn,pic,st,3), pF(xsn,pic,st,3)]); %[dp(xsn,pic,st,3), c(xsn,pic,st,3)]
        end
        
    end    
clear K V X;




fprintf(d_SCDC,    '%d, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f\n',...
        xsn, dp(xsn, 1,1,2), dp(xsn, 1,1,3),  dp(xsn, 1,2,2), dp(xsn, 1,2,3),...
        dp(xsn, 2,1,2), dp(xsn, 2,1,3), dp(xsn, 2,2,2), dp(xsn, 2,2,3),...
        dp(xsn, 3,1,2), dp(xsn, 3,1,3), dp(xsn, 3,2,2), dp(xsn, 3,2,3));
fprintf(c_SCDC,    '%d, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f\n',...
        xsn, c(xsn, 1,1,2), c(xsn, 1,1,3),  c(xsn, 1,2,2), c(xsn, 1,2,3),...
        c(xsn, 2,1,2), c(xsn, 2,1,3), c(xsn, 2,2,2), c(xsn, 2,2,3),...
        c(xsn, 3,1,2), c(xsn, 3,1,3), c(xsn, 3,2,2), c(xsn, 3,2,3));
    
% fprintf(pH_SISCDC,    '%d, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f\n',...
%         xsn, pH(xsn, 1,1,1), pH(xsn, 1,1,2), pH(xsn, 1,1,3), pH(xsn, 1,2,1), pH(xsn, 1,2,2), pH(xsn, 1,2,3),...
%         pH(xsn, 2,1,1), pH(xsn, 2,1,2), pH(xsn, 2,1,3), pH(xsn, 2,2,1), pH(xsn, 2,2,2), pH(xsn, 2,2,3),...
%         pH(xsn, 3,1,1), pH(xsn, 3,1,2), pH(xsn, 3,1,3), pH(xsn, 3,2,1), pH(xsn, 3,2,2), pH(xsn, 3,2,3));



end
rmpath(fullfile(pwd, sprintf('data_%s', prefix)));

end

% IndModpH = []; IndModpF = [];
% for xsn = 1:length(SN)
%     for pic = 1:3
%         for st = 1:2
%             if pH(xsn,pic,st,2) > pF(xsn,pic,st,2) && pH(xsn,pic,st,3) > pF(xsn,pic,st,3)
%                 IndModpH(end+1,pic,st,2) = pH(xsn,pic,st,2);
%                 IndModpF(end+1,pic,st,2) = pF(xsn,pic,st,2);
%             end
%         end
%     end
% end
