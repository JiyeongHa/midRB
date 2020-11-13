% 20171123 Analyzer for pilot data from midRB.m
% Written by Jiyeong Ha
% main + confidence analyzing code
% Activate 'delete' code below if you're running this more than second time 
delete('trmRT3x2x3.csv');
delete('rawRT3x2x3.csv');
delete('trmRT3.csv');
delete('rawRT3.csv');

clear all;

prefix = 'midRB';
% prefix = 'v2midRB';


addpath(fullfile(pwd, sprintf('data_%s', prefix)));

% 
trmRTResults = fopen('trmRT3x2x3.csv', 'a');
rawRTResults = fopen('rawRT3x2x3.csv', 'a');

trmCondResults = fopen('trmRT3.csv', 'a');
rawCondResults = fopen('rawRT3.csv', 'a');

% c2RatResults = fopen('curvRating2.csv', 'a');
% cEachpicRat = fopen('EachpicRat.csv', 'a');
% 
% 
fprintf(trmRTResults, 'SN, OrixWitxSI, OrixWitxSC, OrixWitxDC, OrixBetxSI, OrixBetxSC, OrixBetxDC, TeXxWitxSI, TeXxWitxSC, TeXxWitxDC, TeXxBetxSI, TeXxBetxSC, TeXxBetxDC,PatxWitxSI, PatxWitxSC, PatxWitxDC, PatxBetxSI, PatxBetxSC, PatxBetxDC\n');
fprintf(rawRTResults, 'SN, OrixWitxSI, OrixWitxSC, OrixWitxDC, OrixBetxSI, OrixBetxSC, OrixBetxDC, TeXxWitxSI, TeXxWitxSC, TeXxWitxDC, TeXxBetxSI, TeXxBetxSC, TeXxBetxDC,PatxWitxSI, PatxWitxSC, PatxWitxDC, PatxBetxSI, PatxBetxSC, PatxBetxDC\n');

% fprintf(CondResults, 'SN, Same-Item, Same-category, Diff-category\n');
% fprintf(cEachpicRat, 'PicNum, MeanRat, Class\n');
% 


SN={};
SN{end+1} = {'01',''};   % put the subject number and initial of name
SN{end+1} = {'02',''};
SN{end+1} = {'03',''};
SN{end+1} = {'04',''};
SN{end+1} = {'05',''};
SN{end+1} = {'06',''};
SN{end+1} = {'07',''};
% SN{end+1} = {'08',''};
% SN{end+1} = {'09',''};
% SN{end+1} = {'10',''};
% SN{end+1} = {'11',''};
% SN{end+1} = {'12',''};
% SN{end+1} = {'13',''};
% SN{end+1} = {'14',''};
% SN{end+1} = {'15',''};
% SN{end+1} = {'16',''};
% SN{end+1} = {'17',''};
% SN{end+1} = {'18',''};
% SN{end+1} = {'19',''};
% SN{end+1} = {'20',''};
%% mean rating of each condition - per perticipant

%[SN1, trial2, PicFolder3, C1start(L/R)4, Stream5, Category6, BS17, AI18, ITM19, 10AI2, 11ITM2, 12RT, 13Resp, 14AW, 15Corr]

for xsn = 1:length(SN)

    TT = importdata(sprintf('datRaw_%ss%s.csv', prefix, SN{xsn}{1}));
    header = TT.colheaders;
    TT = TT.data;
    
    TT = TT(TT(:,13) ~= 7, :);
    TT = TT(TT(:,12) > .3, :);
    unAnswered = length(TT(TT(:,13) == 7, :));
    less300ms = length(TT( .3 >= TT(:,12), :))/(864);  %removed trials due to incorrect answers
    TT = TT(TT(:,15) == 1, :);

%% RAW
    %pic RT
    
    OriRT(xsn) = mean(TT(TT(:,3) == 1, 12));
    TexRT(xsn) = mean(TT(TT(:,3) == 2, 12)); 
    PatRT(xsn) = mean(TT(TT(:,3) == 3, 12));
    
    %stream RT
    
    WitRT(xsn) = mean(TT(TT(:,5) == 1, 12));
    BetRT(xsn) = mean(TT(TT(:,5) == 2, 12)); 

 

    %cond RT
    
    SameitRT(xsn) = mean(TT(TT(:,6) == 1, 12));
    SamecatRT(xsn) = mean(TT(TT(:,6) == 2, 12));
    DiffcatRT(xsn) = mean(TT(TT(:,6) == 3, 12));

    fprintf(rawCondResults, '%d, %2.4f, %2.4f, %2.4f\n', xsn, SameitRT(xsn), SamecatRT(xsn), DiffcatRT(xsn));
    
  
    %pic & stream & cond RT print for JASP (3x2x3=18)
    
    
    fRes = zeros(length(SN), 3,2,3);
    xRTcond = {};
    for pic = 1:3
        for st = 1:2
            for cond = 1:3   
    fRes(xsn, pic,st,cond) = mean(TT(TT(:,3) == pic & TT(:,5) == st &  TT(:,6) == cond, 12));
    xRTcond{xsn, end+1} = fRes(xsn, pic,st,cond);
            end
        end
    end
    
    fprintf(rawRTResults,    '%d, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f\n',...
        xsn, fRes(xsn, 1,1,1), fRes(xsn, 1,1,2), fRes(xsn, 1,1,3), fRes(xsn, 1,2,1), fRes(xsn, 1,2,2), fRes(xsn, 1,2,3),...
        fRes(xsn, 2,1,1), fRes(xsn, 2,1,2), fRes(xsn, 2,1,3), fRes(xsn, 2,2,1), fRes(xsn, 2,2,2), fRes(xsn, 2,2,3),...
        fRes(xsn, 3,1,1), fRes(xsn, 3,1,2), fRes(xsn, 3,1,3), fRes(xsn, 3,2,1), fRes(xsn, 3,2,2), fRes(xsn, 3,2,3));

 %% 2.5MAD trimming - for each condition 
 
 % cond RT    
    trmPicRT = {};
    trmPicRT{xsn,1} = OriRT(xsn);
    trmPicRT{xsn,2} = TexRT(xsn);
    trmPicRT{xsn,3} = PatRT(xsn);


        for cond = 1:size(trmPicRT,2)
            cutoff.lower(xsn,cond) = median(trmPicRT{xsn,cond}) - 2.5*1.4826*mad(trmPicRT{xsn,cond}, 1);
            cutoff.upper(xsn,cond) = median(trmPicRT{xsn,cond}) + 2.5*1.4826*mad(trmPicRT{xsn,cond}, 1);
            trmPicRT{xsn,cond} = trmPicRT{xsn,cond}(trmPicRT{xsn,cond} > cutoff.lower(xsn,cond) & trmPicRT{xsn,cond} < cutoff.upper(xsn,cond));
            trmPicRTmean(xsn,cond) = mean(trmPicRT{xsn,cond});
        end
        
        
        fprintf(trmCondResults, '%d, %2.4f, %2.4f, %2.4f\n', xsn, trmPicRTmean(xsn,1), trmPicRTmean(xsn,2), trmPicRTmean(xsn,3));


        
        
        trmRT = cell(length(xsn), cond);

        for cond = 1:size(xRTcond,2)
            cutoff.lower(xsn,cond) = median(xRTcond{xsn,cond}) - 2.5*1.4826*mad(xRTcond{xsn,cond}, 1);
            cutoff.upper(xsn,cond) = median(xRTcond{xsn,cond}) + 2.5*1.4826*mad(xRTcond{xsn,cond}, 1);
            trmRT{xsn,cond} = xRTcond{xsn,cond}(xRTcond{xsn,cond} > cutoff.lower(xsn,cond) & xRTcond{xsn,cond} < cutoff.upper(xsn,cond));
            trmRTmean(xsn,cond) = mean(trmRT{xsn,cond});
        end
  fprintf(trmRTResults,    '%d, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f\n',...
        xsn, trmRTmean(xsn,1), trmRTmean(xsn,2), trmRTmean(xsn,3), trmRTmean(xsn,4), trmRTmean(xsn,5), trmRTmean(xsn,6),...
        trmRTmean(xsn,7), trmRTmean(xsn,8), trmRTmean(xsn,9), trmRTmean(xsn,10), trmRTmean(xsn,11), trmRTmean(xsn,12),...
        trmRTmean(xsn,13), trmRTmean(xsn,14), trmRTmean(xsn,15), trmRTmean(xsn,16), trmRTmean(xsn,17), trmRTmean(xsn,18));
        
    
    %Lets see first...
    
    fprintf(    'Participant %d: Original pic RT with high confidence is %2.4f\n', xsn, OriRT(xsn));
    fprintf(    'Participant %d: Texform pic RT with high confidence is %2.4f\n', xsn, TexRT(xsn));
    fprintf(    'Participant %d: Pattern pic RT with high confidence is %2.4f\n', xsn, PatRT(xsn));
    fprintf(    'Participant %d: Within stream RT with high confidence is %2.4f\n', xsn, WitRT(xsn));
    fprintf(    'Participant %d: Between stream RT with high confidence is %2.4f\n', xsn, BetRT(xsn));
    fprintf(    'Participant %d: Same item RT with high confidence is %2.4f\n', xsn, SameitRT(xsn));
    fprintf(    'Participant %d: Same category RT with high confidence is %2.4f\n',  xsn, SamecatRT(xsn));
    fprintf(    'Participant %d: Different category RT with high confidence is %2.4f\n', xsn, DiffcatRT(xsn));
      
    
    
    
    
    clear fRes;

        
end

 
fprintf(    'Averaged Original pic RT with high confidence is %2.4f(%2.4f)\n', mean(OriRT), std(OriRT));
fprintf(    'Averaged Texform pic RT with high confidence is %2.4f(%2.4f)\n', mean(TexRT), std(TexRT));
fprintf(    'Averaged Pattern pic RT with high confidence is %2.4f(%2.4f)\n', mean(PatRT), std(PatRT));
fprintf(    'Averaged Within stream RT with high confidence is %2.4f(%2.4f)\n', mean(WitRT), std(WitRT));
fprintf(    'Averaged Between stream RT with high confidence is %2.4f(%2.4f)\n', mean(BetRT), std(BetRT));
fprintf(    'Averaged Same item RT with high confidence is %2.4f(%2.4f)\n', mean(SameitRT), std(SameitRT));
fprintf(    'Averaged Same category RT with high confidence is %2.4f(%2.4f)\n',  mean(SamecatRT), std(SamecatRT));
fprintf(    'Averaged Different category RT with high confidence is %2.4f(%2.4f)\n', mean(DiffcatRT), std(DiffcatRT));
