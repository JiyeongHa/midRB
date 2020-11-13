% 20171123 Analyzer for pilot data from midRB.m
% Written by Jiyeong Ha
% main analyzer code - this code doesn't involve confidence responses.
% Activate below 'delete' code if you're running this more than second time 
delete('v2Acc3x2x3.csv');


clear all;

prefix = 'v2midRB';


addpath(fullfile(pwd, sprintf('data_%s', prefix)));

% 
ACCResults = fopen('v2Acc3x2x3.csv', 'a');

% c2RatResults = fopen('curvRating2.csv', 'a');
% cEachpicRat = fopen('EachpicRat.csv', 'a');
% 
% 
fprintf(ACCResults, 'SN, OrixWitxSI, OrixWitxSC, OrixWitxDC, OrixBetxSI, OrixBetxSC, OrixBetxDC, TeXxWitxSI, TeXxWitxSC, TeXxWitxDC, TeXxBetxSI, TeXxBetxSC, TeXxBetxDC,PatxWitxSI, PatxWitxSC, PatxWitxDC, PatxBetxSI, PatxBetxSC, PatxBetxDC\n');
fprintf(ACCResults, 'SN, oriC1BAC2BA, oriC1BIC2BA, oriC1BAC2BI, oriC1BIC2BI, oriC1SAC2SA, oriC1SIC2SA, oriC1SAC2SI, oriC1SIC2SI,');
fprintf(ACCResults, 'SN, texC1BAC2BA, texC1BIC2BA, texC1BAC2BI, texC1BIC2BI, texC1SAC2SA, texC1SIC2SA, texC1SAC2SI, texC1SIC2SI,');
fprintf(ACCResults, 'SN, patC1BAC2BA, patC1BIC2BA, patC1BAC2BI, patC1BIC2BI, patC1SAC2SA, patC1SIC2SA, patC1SAC2SI, patC1SIC2SI\n');




SN={};
SN{end+1} = {'01',''};   % put the subject number and initial of names
SN{end+1} = {'02',''};
SN{end+1} = {'03',''};
SN{end+1} = {'04',''};
SN{end+1} = {'05',''};
SN{end+1} = {'06',''};
SN{end+1} = {'07',''};
SN{end+1} = {'08',''};
SN{end+1} = {'09',''};
SN{end+1} = {'10',''};
SN{end+1} = {'11',''};
SN{end+1} = {'12',''};
SN{end+1} = {'13',''};
SN{end+1} = {'14',''};
SN{end+1} = {'15',''};
SN{end+1} = {'16',''};
SN{end+1} = {'17',''};
SN{end+1} = {'18',''};
SN{end+1} = {'19',''};
SN{end+1} = {'21',''};
%% mean rating of each condition - per perticipant

%[SN1, trial2, PicFolder3, C1start(L/R)4, Stream5, Category6, BS17, AI18, ITM19, 10AI2, 11ITM2, 12RT, 13Resp, 14AW, 15Corr]

for xsn = 1:length(SN)

    TT = importdata(sprintf('datRaw_%ss%s.csv', prefix, SN{xsn}{1}));
    header = TT.colheaders;
    TT = TT.data;
    
    TT = TT(TT(:,13) ~= 7, :);
    unAnswered = length(TT(TT(:,13) == 7, :));
    
    %total Accuracy
    TotalAcc(xsn) = length(TT(TT(:,15) == 1, 15)) / length(TT(:, 15)); 
    
    %pic accuracy
    
    OriAcc(xsn) = length(TT(TT(:,3) == 1 & TT(:,15) == 1, 15)) / length(TT(TT(:,3) == 1, 15));
    TexAcc(xsn) = length(TT(TT(:,3) == 2 & TT(:,15) == 1, 15)) / length(TT(TT(:,3) == 2, 15));
    PatAcc(xsn) = length(TT(TT(:,3) == 3 & TT(:,15) == 1, 15)) / length(TT(TT(:,3) == 3, 15));

  
    
    %stream accuracy
    
    WitAcc(xsn) = length(TT(TT(:,5) == 1 & TT(:,15) == 1, 15)) / length(TT(TT(:,5) == 1, 15));
    BetAcc(xsn) = length(TT(TT(:,5) == 2 & TT(:,15) == 1, 15)) / length(TT(TT(:,5) == 2, 15));

 

    %cond accuracy
    
    SameitAcc(xsn) = length(TT(TT(:,6) == 1 & TT(:,15) == 1, 15)) / length(TT(TT(:,6) == 1, 15));
    SamecatAcc(xsn) = length(TT(TT(:,6) == 2 & TT(:,15) == 1, 15)) / length(TT(TT(:,6) == 2, 15));
    DiffcatAcc(xsn) = length(TT(TT(:,6) == 3 & TT(:,15) == 1, 15)) / length(TT(TT(:,6) == 3, 15));

    

    %pic & stream & cond accuracy print for JASP (3x2x3=18)
    
    
    fRes = zeros(length(SN), 3,2,3);
    for pic = 1:3
        for st = 1:2
            for cond = 1:3   
    fRes(xsn, pic,st,cond) = length(TT(TT(:,3) == pic & TT(:,5) == st &  TT(:,6) == cond & TT(:,15) == 1, 15)) / length(TT(TT(:,3) == pic & TT(:,5) == st &  TT(:,6) == cond, 15));
            end
        end
    end
    
    fprintf(ACCResults,    '%d, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f, %2.4f\n',...
        xsn, fRes(xsn, 1,1,1), fRes(xsn, 1,1,2), fRes(xsn, 1,1,3), fRes(xsn, 1,2,1), fRes(xsn, 1,2,2), fRes(xsn, 1,2,3),...
        fRes(xsn, 2,1,1), fRes(xsn, 2,1,2), fRes(xsn, 2,1,3), fRes(xsn, 2,2,1), fRes(xsn, 2,2,2), fRes(xsn, 2,2,3),...
        fRes(xsn, 3,1,1), fRes(xsn, 3,1,2), fRes(xsn, 3,1,3), fRes(xsn, 3,2,1), fRes(xsn, 3,2,2), fRes(xsn, 3,2,3));
    clear fRes;

    
    %Lets see first...
    
    fprintf(    'Participant %d: Total Accuracy is %2.4f\n', xsn, TotalAcc(xsn));
    fprintf(    'Participant %d: Original pic accuracy is %2.4f\n', xsn, OriAcc(xsn));
    fprintf(    'Participant %d: Texform pic accuracy is %2.4f\n', xsn, TexAcc(xsn));
    fprintf(    'Participant %d: Pattern pic accuracy is %2.4f\n', xsn, PatAcc(xsn));
    fprintf(    'Participant %d: Within stream accuracy is %2.4f\n', xsn, WitAcc(xsn));
    fprintf(    'Participant %d: Between stream accuracy is %2.4f\n', xsn, BetAcc(xsn));
    fprintf(    'Participant %d: Same item accuracy is %2.4f\n', xsn, SameitAcc(xsn));
    fprintf(    'Participant %d: Same category accuracy is %2.4f\n',  xsn, SamecatAcc(xsn));
    fprintf(    'Participant %d: Different category accuracy is %2.4f\n', xsn, DiffcatAcc(xsn));
end

 
fprintf(    'Averaged total accuracy is %2.4f(%2.4f)\n', mean(TotalAcc), std(TotalAcc));
fprintf(    'Averaged Original pic accuracy is %2.4f(%2.4f)\n', mean(OriAcc), std(OriAcc));
fprintf(    'Averaged Texform pic accuracy is %2.4f(%2.4f)\n', mean(TexAcc), std(TexAcc));
fprintf(    'Averaged Pattern pic accuracy is %2.4f(%2.4f)\n', mean(PatAcc), std(PatAcc));
fprintf(    'Averaged Within stream accuracy is %2.4f(%2.4f)\n', mean(WitAcc), std(WitAcc));
fprintf(    'Averaged Between stream accuracy is %2.4f(%2.4f)\n', mean(BetAcc), std(BetAcc));
fprintf(    'Averaged Same item accuracy is %2.4f(%2.4f)\n', mean(SameitAcc), std(SameitAcc));
fprintf(    'Averaged Same category accuracy is %2.4f(%2.4f)\n',  mean(SamecatAcc), std(SamecatAcc));
fprintf(    'Averaged Different category accuracy is %2.4f(%2.4f)\n', mean(DiffcatAcc), std(DiffcatAcc));











