function [] = Fig2_Manuscript2020(rootFolder,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpose:
%________________________________________________________________________________________________________________________

animalIDs = {'T99','T101','T102','T103','T105','T108','T109','T110','T111','T119','T120','T121','T122','T123'};
bins = {'five','ten','fifteen','twenty','twentyfive','thirty','thirtyfive','forty','fortyfive','fifty','fiftyfive','sixty','sixtyplus'};
colorA = [(51/256),(160/256),(44/256)];   % rest color
colorB = [(192/256),(0/256),(256/256)];   % NREM color
colorC = [(255/256),(140/256),(0/256)];   % REM color
colorD = [(31/256),(120/256),(180/256)];  % whisk color

%% cd through each animal's directory and extract the appropriate analysis results
c = 1;
e = 1;
for a = 1:length(animalIDs)
    animalID = animalIDs{1,a};
    % rest event probability
    for b = 1:length(bins)
        bin = bins{1,b};
        data.(bin).ind{c,1} = AnalysisResults.(animalID).SleepProbability.(bin).awakeLogical;
    end
    % awake hypnogram probability
    c = c + 1;
    strDays = fields(AnalysisResults.(animalID).SleepProbability.Hypnogram);
    q = 1;
    for d = 1:length(strDays)
        strDay = strDays{d,1};
        data.hypAwakeProb.all{e,1} = AnalysisResults.(animalID).SleepProbability.Hypnogram.(strDay).AwakeProb_inds;
        data.hypNREMProb.all{e,1} = AnalysisResults.(animalID).SleepProbability.Hypnogram.(strDay).NREMProb_inds;
        data.hypREMProb.all{e,1} = AnalysisResults.(animalID).SleepProbability.Hypnogram.(strDay).REMProb_inds;
        data.hypAwakeProb.(animalID).ind{q,1} = AnalysisResults.(animalID).SleepProbability.Hypnogram.(strDay).AwakeProb_inds;
        data.hypNREMProb.((animalID)).ind{q,1} = AnalysisResults.(animalID).SleepProbability.Hypnogram.(strDay).NREMProb_inds;
        data.hypREMProb.((animalID)).ind{q,1} = AnalysisResults.(animalID).SleepProbability.Hypnogram.(strDay).REMProb_inds;
        e = e + 1;
        q = q + 1;
    end
end
% concatenate and organize the data
for f = 1:length(bins)
    bin = bins{1,f};
    % rest event probability
    data.(bin).all = [];
    for g = 1:length(data.(bin).ind)
        data.(bin).all = cat(1,data.(bin).all,data.(bin).ind{g,1});
    end
    for q = 1:length(data.(bin).ind)
        data.(bin).indProb{q,1} = sum(data.(bin).ind{q,1})/length(data.(bin).ind{q,1});
    end
    % awake hypnogram probability
    for h = 1:length(data.hypAwakeProb.all)
        awakeHypLength(h,1) = length(data.hypAwakeProb.all{h,1}); %#ok<*AGROW>
    end
    maxHypLength = max(awakeHypLength);
    for i = 1:length(data.hypAwakeProb.all)
        indHypLength = length(data.hypAwakeProb.all{i,1});
        lenDiff = maxHypLength - indHypLength;
        nanPad = NaN(1,lenDiff);
        awakePadHypData = cat(2,data.hypAwakeProb.all{i,1},nanPad);
        awakeAllHypData(i,:) = awakePadHypData;
        nremPadHypData = cat(2,data.hypNREMProb.all{i,1},nanPad);
        nremAllHypData(i,:) = nremPadHypData;
        remPadHypData = cat(2,data.hypREMProb.all{i,1},nanPad);
        remAllHypData(i,:) = remPadHypData;
    end
end
%
for x = 1:length(animalIDs)
    animalID = animalIDs{1,x};
    indRestEventProbability = [];
    for f = 1:length(bins)
        bin = bins{1,f};
        indRestEventProbability = cat(1,indRestEventProbability,data.(bin).indProb{x,1});
    end
    %
    for z = 1:length(data.hypAwakeProb.(animalID).ind)
        indHypLength = length(data.hypAwakeProb.(animalID).ind{z,1});
        lenDiff = maxHypLength - indHypLength;
        nanPad = NaN(1,lenDiff);
        indAwakePadHypData = cat(2,data.hypAwakeProb.(animalID).ind{z,1},nanPad);
        allIndAwakeAllHypData(z,:) = indAwakePadHypData;
        indNremPadHypData = cat(2,data.hypNREMProb.(animalID).ind{z,1},nanPad);
        allIndNremAllHypData(z,:) = indNremPadHypData;
        indRemPadHypData = cat(2,data.hypREMProb.(animalID).ind{z,1},nanPad);
        allIndRemAllHypData(z,:) = indRemPadHypData;
    end
    data.hypAwakeProb.(animalID).awakeProb = allIndAwakeAllHypData;
    data.hypNREMProb.(animalID).nremProb = allIndNremAllHypData;
    data.hypREMProb.(animalID).remProb = allIndRemAllHypData;
end
% calculate rest event awakeness probability over time
for j = 1:length(bins)
    bin = bins{1,j};
    restEventProbability(j,1) = sum(data.(bin).all)/length(data.(bin).all);
end
% calculate awake probabilty over time
awakeProbability = nansum(awakeAllHypData)./(length(data.hypAwakeProb.all) - sum(isnan(awakeAllHypData)));
awakeNaNInds = ~isnan(awakeProbability);
awakeDiffs = cumsum(awakeNaNInds - diff([1,awakeNaNInds])/2);
patchedAwakeProbability = interp1(1:nnz(awakeNaNInds),awakeProbability(awakeNaNInds),awakeDiffs);
% NREM
nremProbability = nansum(nremAllHypData)./(length(data.hypNREMProb.all) - sum(isnan(nremAllHypData)));
nremNaNInds = ~isnan(nremProbability);
nremDiffs = cumsum(nremNaNInds - diff([1,nremNaNInds])/2);
patchedNREMProbability = interp1(1:nnz(nremNaNInds),nremProbability(nremNaNInds),nremDiffs);
% REM
remProbability = nansum(remAllHypData)./(length(data.hypREMProb.all) - sum(isnan(remAllHypData)));
remNaNInds = ~isnan(remProbability);
remDiffs = cumsum(remNaNInds - diff([1,remNaNInds])/2);
patchedREMProbability = interp1(1:nnz(remNaNInds),remProbability(remNaNInds),remDiffs);
%
dataLength = (3*60*60)/5;   % 3 hrs - 60 minutes - 60 seconds - 5 second bins
patchedAwakeProbability = patchedAwakeProbability(1:dataLength);
patchedNREMProbability = patchedNREMProbability(1:dataLength);
patchedREMProbability = patchedREMProbability(1:dataLength);
%
for qx = 1:length(animalIDs)
    animalID = animalIDs{1,qx};
    % calculate awake probabilty over time
    indAwakeProbability{qx,1} = nansum(data.hypAwakeProb.(animalID).awakeProb)./(size(data.hypAwakeProb.(animalID).awakeProb,1) - sum(isnan(data.hypAwakeProb.(animalID).awakeProb)));
    indAwakeNaNInds{qx,1} = ~isnan(indAwakeProbability{qx,1});
    indAwakeDiffs{qx,1} = cumsum(indAwakeNaNInds{qx,1} - diff([1,indAwakeNaNInds{qx,1}])/2);
    indPatchedAwakeProbability{qx,1} = interp1(1:nnz(indAwakeNaNInds{qx,1}),indAwakeProbability{qx,1}(indAwakeNaNInds{qx,1}),indAwakeDiffs{qx,1});
    finalPatchedAwakeProbability{qx,1} = indPatchedAwakeProbability{qx,1}(1:dataLength);
    % NREM
    indNREMProbability{qx,1} = nansum(data.hypNREMProb.(animalID).nremProb)./(size(data.hypNREMProb.(animalID).nremProb,1) - sum(isnan(data.hypNREMProb.(animalID).nremProb)));
    indNREMNaNInds{qx,1} = ~isnan(indNREMProbability{qx,1});
    indNREMDiffs{qx,1} = cumsum(indNREMNaNInds{qx,1} - diff([1,indNREMNaNInds{qx,1}])/2);
    indPatchedNREMProbability{qx,1} = interp1(1:nnz(indNREMNaNInds{qx,1}),indNREMProbability{qx,1}(indNREMNaNInds{qx,1}),indNREMDiffs{qx,1});
    finalPatchedNREMProbability{qx,1} = indPatchedNREMProbability{qx,1}(1:dataLength);
    % REM
    indREMProbability{qx,1} = nansum(data.hypREMProb.(animalID).remProb)./(size(data.hypREMProb.(animalID).remProb,1) - sum(isnan(data.hypREMProb.(animalID).remProb)));
    indREMNaNInds{qx,1} = ~isnan(indREMProbability{qx,1});
    indREMDiffs{qx,1} = cumsum(indREMNaNInds{qx,1} - diff([1,indREMNaNInds{qx,1}])/2);
    indPatchedREMProbability{qx,1} = interp1(1:nnz(indREMNaNInds{qx,1}),indREMProbability{qx,1}(indREMNaNInds{qx,1}),indREMDiffs{qx,1});
    finalPatchedREMProbability{qx,1} = indPatchedREMProbability{qx,1}(1:dataLength);
end
%
binSize = 60/5;   % 60 sec divided by 5 sec bins
numBins = length(patchedAwakeProbability)/binSize;
for k = 1:numBins
    if k == 1
        binnedAwakeProbability(1,k) = mean(patchedAwakeProbability(1:binSize));
        binnedNREMProbability(1,k) = mean(patchedNREMProbability(1:binSize));
        binnedREMProbability(1,k) = mean(patchedNREMProbability(1:binSize));
    else
        binnedAwakeProbability(1,k) = mean(patchedAwakeProbability((k - 1)*binSize + 1:k*binSize));
        binnedNREMProbability(1,k) = mean(patchedNREMProbability((k - 1)*binSize + 1:k*binSize));
        binnedREMProbability(1,k) = mean(patchedREMProbability((k - 1)*binSize + 1:k*binSize));
    end
end
%
for qx = 1:length(animalIDs)
    for k = 1:numBins
        if k == 1
            binnedIndFinalPatchedAwakeProbability{qx,1}(1,k) = mean(finalPatchedAwakeProbability{qx,1}(1:binSize));
            binnedIndFinalPatchedNREMProbability{qx,1}(1,k) = mean(finalPatchedNREMProbability{qx,1}(1:binSize));
            binnedIndFinalPatchedREMProbability{qx,1}(1,k) = mean(finalPatchedREMProbability{qx,1}(1:binSize));
        else
            binnedIndFinalPatchedAwakeProbability{qx,1}(1,k) =  mean(finalPatchedAwakeProbability{qx,1}((k - 1)*binSize + 1:k*binSize));
            binnedIndFinalPatchedNREMProbability{qx,1}(1,k) =  mean(finalPatchedNREMProbability{qx,1}((k - 1)*binSize + 1:k*binSize));
            binnedIndFinalPatchedREMProbability{qx,1}(1,k) =  mean(finalPatchedREMProbability{qx,1}((k - 1)*binSize + 1:k*binSize));
        end
    end
end
%% Mean HbT and heart rate comparison between behaviors
% cd through each animal's directory and extract the appropriate analysis results
behavFields = {'Awake','NREM','REM'};
for a = 1:length(animalIDs)
    animalID = animalIDs{1,a};
    for b = 1:length(behavFields)
        behavField = behavFields{1,b};
        data.BehavioralDistributions.(behavField).EMG{a,1} = AnalysisResults.(animalID).BehaviorDistributions.(behavField).EMG;
        data.BehavioralDistributions.(behavField).Whisk{a,1} = AnalysisResults.(animalID).BehaviorDistributions.(behavField).Whisk;
        data.BehavioralDistributions.(behavField).HR{a,1} = AnalysisResults.(animalID).BehaviorDistributions.(behavField).HR;
        animalCell = cell(length(data.BehavioralDistributions.(behavField).HR{a,1}),1);
        behavCell = cell(length(data.BehavioralDistributions.(behavField).HR{a,1}),1);
        animalCell(:) = {animalID};
        behavCell(:) = {behavField};
        data.BehavioralDistributions.(behavField).animalIDs{a,1} = animalCell;
        data.BehavioralDistributions.(behavField).behaviors{a,1} = behavCell;
    end
end
% take the mean and standard deviation of each set of signals
data.BehavioralDistributions.Awake.catWhisk = []; data.BehavioralDistributions.NREM.catWhisk = []; data.BehavioralDistributions.REM.catWhisk = []; 
data.BehavioralDistributions.Awake.catHeart = []; data.BehavioralDistributions.NREM.catHeart = []; data.BehavioralDistributions.REM.catHeart = [];
data.BehavioralDistributions.Awake.catEMG = []; data.BehavioralDistributions.NREM.catEMG = []; data.BehavioralDistributions.REM.catEMG = [];
data.BehavioralDistributions.Awake.catAnimalIDs = []; data.BehavioralDistributions.NREM.catAnimalIDs = []; data.BehavioralDistributions.REM.catAnimalIDs = [];
data.BehavioralDistributions.Awake.catBehaviors = []; data.BehavioralDistributions.NREM.catBehaviors = []; data.BehavioralDistributions.REM.catBehaviors = [];
for e = 1:length(behavFields)
    behavField = behavFields{1,e};
    % concatenate individual heart rate bins
    for f = 1:length(data.BehavioralDistributions.(behavField).HR)
        data.BehavioralDistributions.(behavField).catHeart = vertcat(data.BehavioralDistributions.(behavField).catHeart,data.BehavioralDistributions.(behavField).HR{f,1});
        data.BehavioralDistributions.(behavField).catWhisk = vertcat(data.BehavioralDistributions.(behavField).catWhisk,data.BehavioralDistributions.(behavField).Whisk{f,1});
        data.BehavioralDistributions.(behavField).catEMG = vertcat(data.BehavioralDistributions.(behavField).catEMG,data.BehavioralDistributions.(behavField).EMG{f,1});
        data.BehavioralDistributions.(behavField).catAnimalIDs = vertcat(data.BehavioralDistributions.(behavField).catAnimalIDs,data.BehavioralDistributions.(behavField).animalIDs{f,1});
        data.BehavioralDistributions.(behavField).catBehaviors = vertcat(data.BehavioralDistributions.(behavField).catBehaviors,data.BehavioralDistributions.(behavField).behaviors{f,1});
    end
end
%% Mean HbT and heart rate comparison between behaviors
% cd through each animal's directory and extract the appropriate analysis results
IOS_behavFields = {'Rest','Whisk','NREM','REM'};
for a = 1:length(animalIDs)
    animalID = animalIDs{1,a};
    for b = 1:length(IOS_behavFields)
        behavField = IOS_behavFields{1,b};
        if strcmp(behavField,'Rest') == true || strcmp(behavField,'Whisk') == true
            data.(behavField).HR(a,1) = mean(AnalysisResults.(animalID).MeanHR.(behavField));
        elseif strcmp(behavField,'NREM') == true || strcmp(behavField,'REM') == true
            data.(behavField).HR(a,1) = mean(AnalysisResults.(animalID).MeanHR.(behavField));
        end
        data.(behavField).CBV_HbT.animalID{a,1} = animalID;
        data.(behavField).CBV_HbT.behavior{a,1} = behavField;
    end
end
% take the mean and standard deviation of each set of signals
for e = 1:length(IOS_behavFields)
    behavField = IOS_behavFields{1,e};
    data.(behavField).meanHR = mean(data.(behavField).HR);
    data.(behavField).stdHR = std(data.(behavField).HR,0,1);
end
%% statistics - generalized linear mixed effects model
% heart rate
HRtableSize = cat(1,data.Rest.HR,data.Whisk.HR,data.NREM.HR,data.REM.HR);
HRTable = table('Size',[size(HRtableSize,1),3],'VariableTypes',{'string','double','string'},'VariableNames',{'Mouse','HR','Behavior'});
HRTable.Mouse = cat(1,data.Rest.CBV_HbT.animalID,data.Whisk.CBV_HbT.animalID,data.NREM.CBV_HbT.animalID,data.REM.CBV_HbT.animalID);
HRTable.HR = cat(1,data.Rest.HR,data.Whisk.HR,data.NREM.HR,data.REM.HR);
HRTable.Behavior = cat(1,data.Rest.CBV_HbT.behavior,data.Whisk.CBV_HbT.behavior,data.NREM.CBV_HbT.behavior,data.REM.CBV_HbT.behavior);
HRFitFormula = 'HR ~ 1 + Behavior + (1|Mouse)';
HRStats = fitglme(HRTable,HRFitFormula);
%% extract data from each animal's sleep scoring results
allCatLabels = [];
for a = 1:length(animalIDs)
    animalID = animalIDs{1,a};
    dataLoc = [rootFolder '/' animalID '/Bilateral Imaging/'];
    cd(dataLoc)
    scoringResults = 'Forest_ScoringResults.mat';
    load(scoringResults,'-mat')
    numberOfScores(a,1) = length(ScoringResults.alllabels); %#ok<*AGROW,*NASGU>
    indAwakePerc(a,1) = round((sum(strcmp(ScoringResults.alllabels,'Not Sleep'))/length(ScoringResults.alllabels))*100,1);
    indNremPerc(a,1) = round((sum(strcmp(ScoringResults.alllabels,'NREM Sleep'))/length(ScoringResults.alllabels))*100,1);
    indRemPerc(a,1) = round((sum(strcmp(ScoringResults.alllabels,'REM Sleep'))/length(ScoringResults.alllabels))*100,1);
    allCatLabels = vertcat(allCatLabels,ScoringResults.alllabels); 
end
labels = {'Awake','NREM','REM'};
% mean percentage of each state between animals
meanAwakePerc = mean(indAwakePerc,1);
stdAwakePerc = std(indAwakePerc,0,1);
meanNremPerc = mean(indNremPerc,1);
stdNremPerc = std(indNremPerc,0,1);
meanRemPerc = mean(indRemPerc,1);
stdRemPerc = std(indRemPerc,0,1);
meanPercs = horzcat(meanAwakePerc,meanNremPerc,meanRemPerc);
% percentage of each state for all labels together
allAwakePerc = round((sum(strcmp(allCatLabels,'Not Sleep'))/length(allCatLabels))*100,1);
allNremPerc = round((sum(strcmp(allCatLabels,'NREM Sleep'))/length(allCatLabels))*100,1);
allRemPerc = round((sum(strcmp(allCatLabels,'REM Sleep'))/length(allCatLabels))*100,1);
meanAllPercs = horzcat(allAwakePerc,allNremPerc,allRemPerc);
% total time per animal behavioral states
labelTime = 5;   % seconds
IOS_indTotalTimeHours = ((numberOfScores*labelTime)/60)/60;
IOS_allTimeHours = sum(IOS_indTotalTimeHours);
IOS_meanTimeHours = mean(IOS_indTotalTimeHours,1);
IOS_stdTimeHours = std(IOS_indTotalTimeHours,0,1);
allTimeDays = sum(IOS_indTotalTimeHours)/24;
totalTimeAwake = IOS_indTotalTimeHours.*(indAwakePerc/100);
meanAwakeHours = mean(totalTimeAwake,1);
stdAwakeHours = std(totalTimeAwake,0,1);
totalTimeNREM = IOS_indTotalTimeHours.*(indNremPerc/100);
meanNREMHours = mean(totalTimeNREM);
stdNREMHours = std(totalTimeNREM,0,1);
totalTimeREM = IOS_indTotalTimeHours.*(indRemPerc/100);
meanREMHours = mean(totalTimeREM);
stdREMHours = std(totalTimeREM,0,1);
%% 2p data
animalIDs2 = {'T115','T116','T117','T118','T125','T126'};
allFileIDs = [];
% extract data from each animal's sleep scoring results
for a = 1:length(animalIDs2)
    animalID = animalIDs2{1,a};
    dataLoc = [rootFolder '/' animalID '/2P Data/'];
    cd(dataLoc)
     % Character list of all MergedData files
    mergedDirectory = dir('*_MergedData.mat');
    mergedDataFiles = {mergedDirectory.name}';
    mergedDataFileIDs = char(mergedDataFiles);
    allFileIDs(a,1) = size(mergedDataFileIDs,1);
end
PLSM_indTotalTimeHours = (allFileIDs.*15)./60;
PLSM_allTimeHours = sum(PLSM_indTotalTimeHours);
PLSM_meanTimeHours = mean(PLSM_indTotalTimeHours,1);
PLSM_stdTimeHours = std(PLSM_indTotalTimeHours,0,1);
allHours = IOS_allTimeHours + PLSM_allTimeHours;
%% Figure Panel 2
summaryFigureA = figure('Name','Fig2 (a)');
sgtitle('Figure Panel 2 (a) Turner Manuscript 2020')
%% [2a] IOS imaging schematic
binTime = 5;
timeConv = 60*(60/binTime);
uniqueDays = fieldnames(AnalysisResults.T120.SleepProbability.Hypnogram);
% day 1
subplot(6,1,1)
b1 = bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{1,1}).NotSleep_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{1,1}).NotSleep_inds,'FaceColor',colors_Manuscript2020('rich black'),'BarWidth',1);
hold on
b2 = bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{1,1}).NREM_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{1,1}).NREM_inds,'FaceColor',colorB,'BarWidth',1);
b3 = bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{1,1}).REM_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{1,1}).REM_inds,'FaceColor',colorC,'BarWidth',1);
legend([b1,b2,b3],'Not Sleep','NREM Sleep','REM Sleep')
xlim([0,3])
title('[2a] Changes in arousal state over time')
set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]);
set(gca,'Ticklength',[0,0])
set(gca,'box','off')
ylabel('Session 1')
% day 2
subplot(6,1,2)
bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{2,1}).NotSleep_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{2,1}).NotSleep_inds,'FaceColor',colors_Manuscript2020('rich black'),'BarWidth',1);
hold on
bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{2,1}).NREM_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{2,1}).NREM_inds,'FaceColor',colorB,'BarWidth',1);
bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{2,1}).REM_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{2,1}).REM_inds,'FaceColor',colorC,'BarWidth',1);
xlim([0,3])
set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]);
set(gca,'Ticklength',[0,0])
set(gca,'box','off')
ylabel('Session 2')
% day 3
subplot(6,1,3)
bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{3,1}).NotSleep_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{3,1}).NotSleep_inds,'FaceColor',colors_Manuscript2020('rich black'),'BarWidth',1);
hold on
bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{3,1}).NREM_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{3,1}).NREM_inds,'FaceColor',colorB,'BarWidth',1);
bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{3,1}).REM_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{3,1}).REM_inds,'FaceColor',colorC,'BarWidth',1);
xlim([0,3])
set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]);
set(gca,'Ticklength',[0,0])
set(gca,'box','off')
ylabel('Session 3')
% day 4
subplot(6,1,4)
bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{4,1}).NotSleep_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{4,1}).NotSleep_inds,'FaceColor',colors_Manuscript2020('rich black'),'BarWidth',1);
hold on
bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{4,1}).NREM_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{4,1}).NREM_inds,'FaceColor',colorB,'BarWidth',1);
bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{4,1}).REM_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{4,1}).REM_inds,'FaceColor',colorC,'BarWidth',1);
xlim([0,3])
set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]);
set(gca,'Ticklength',[0,0])
set(gca,'box','off')
ylabel('Session 4')
% day 5
subplot(6,1,5)
bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{5,1}).NotSleep_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{5,1}).NotSleep_inds,'FaceColor',colors_Manuscript2020('rich black'),'BarWidth',1);
hold on
bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{5,1}).NREM_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{5,1}).NREM_inds,'FaceColor',colorB,'BarWidth',1);
bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{5,1}).REM_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{5,1}).REM_inds,'FaceColor',colorC,'BarWidth',1);
xlim([0,3])
set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]);
set(gca,'Ticklength',[0,0])
set(gca,'box','off')
ylabel('Session 5')
% day 6
subplot(6,1,6)
bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{6,1}).NotSleep_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{6,1}).NotSleep_inds,'FaceColor',colors_Manuscript2020('rich black'),'BarWidth',1);
hold on
bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{6,1}).NREM_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{6,1}).NREM_inds,'FaceColor',colorB,'BarWidth',1);
bar((1:length(AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{6,1}).REM_inds))/timeConv,AnalysisResults.T120.SleepProbability.Hypnogram.(uniqueDays{6,1}).REM_inds,'FaceColor',colorC,'BarWidth',1);
xlim([0,3])
set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]);
set(gca,'Ticklength',[0,0])
set(gca,'box','off')
xlabel('Time (hr)')
ylabel('Session 6')
%% save figure(s)
dirpath = [rootFolder '\Summary Figures and Structures\'];
if ~exist(dirpath,'dir')
    mkdir(dirpath);
end
savefig(summaryFigureA,[dirpath 'Fig2_A']);
set(summaryFigureA,'PaperPositionMode','auto');
print('-painters','-dpdf','-bestfit',[dirpath 'Fig2_A'])
%% second part of figure panel 2
summaryFigureB = figure('Name','Fig2 (b-i)');
sgtitle('Figure Panel 2 (b-i) Turner Manuscript 2020')
%% [2b] Perc of behav states scores
ax1 = subplot(2,4,1);
p1 = pie(meanPercs);
pText = findobj(p1,'Type','text');
percentValues = get(pText,'String'); 
txt = {'Awake: ';'NREM: ';'REM: '}; 
combinedtxt = strcat(txt,percentValues); 
pText(1).String = combinedtxt(1);
pText(2).String = combinedtxt(2);
pText(3).String = combinedtxt(3);
title({'[2b] Sleep scoring label probability','Mean animal sleep scoring labels',''})
%% [2c] Ternary
ax2 = subplot(2,4,2);
terplot_Manuscript2020();
[hd] = ternaryc_Manuscript2020(indAwakePerc/100,indNremPerc/100,indRemPerc/100);
hlabels = terlabel_Manuscript2020('Not asleep','NREM sleep','REM sleep');
title({'[2c] Ternary plot of ind animals',' ',' '})
%% [2d]
ax3 = subplot(2,4,3);
xinds1 = (1:numBins)/(numBins/3);
% awake
scatter(xinds1,binnedAwakeProbability,25,'MarkerEdgeColor','k','MarkerFaceColor',colors_Manuscript2020('rich black'));
[awakeHypExpCurve,~] = fit(xinds1',binnedAwakeProbability','exp1','StartPoint',[0,0]);
awakeHypExpFit = awakeHypExpCurve(xinds1);
hold on
plot(xinds1,awakeHypExpFit,'color',colors_Manuscript2020('rich black'),'LineWidth',2);
% nrem
scatter(xinds1,binnedNREMProbability,25,'MarkerEdgeColor','k','MarkerFaceColor',colorB);
[nremHypExpCurve,~] = fit(xinds1',binnedNREMProbability','exp1','StartPoint',[0,0]);
nremHypExpFit = nremHypExpCurve(xinds1);
plot(xinds1,nremHypExpFit,'color',colorB,'LineWidth',2);
% rem
scatter(xinds1,binnedREMProbability,25,'MarkerEdgeColor','k','MarkerFaceColor',colorC);
[remHypExpCurve,~] = fit(xinds1',binnedREMProbability','exp1','StartPoint',[0,0]);
remHypExpFit = remHypExpCurve(xinds1);
plot(xinds1,remHypExpFit,'color',colorC,'LineWidth',2);
% legend([s1,p1,s2,p2,s3,p3],'Awake bin prob',['(Exp2) adjR^2 = ' num2str(round(awakeHypGOF.adjrsquare,2))],'NREM bin prob',['(Exp2) adjR^2 = ' num2str(round(nremHypGOF.adjrsquare,2))],'REM bin prob',['(Exp2) adjR^2 = ' num2str(round(remHypGOF.adjrsquare,2))])
title({'[2d] Imaging timeline','Awake probability',''})
xlabel('Time (Hr)')
ylabel('Probability')
ylim([0,1])
set(gca,'box','off')
axis square
ax3.TickLength = [0.03,0.03];
%% [2e] Rest event probability
ax4 = subplot(2,4,4);
xinds2 = 0:length(bins) - 1;
xinds3 = 0:0.01:length(bins) - 1;
scatter(xinds2,restEventProbability,75,'MarkerEdgeColor','k','MarkerFaceColor',colorA);
[restExpCurve,~] = fit(xinds2',restEventProbability,'exp2');
restExpFit = restExpCurve(xinds3);
hold on
plot(xinds3,restExpFit,'k','LineWidth',2);
% legend([s2,p2],'Time point probability',['(Exp2) adjR^2 = ' num2str(round(restGOF.adjrsquare,3))])
xticks([1,3,5,7,9,11])
xticklabels({'10','20','30','40','50','60'})
title({'[2e] Awake probability','of ''Rest'' events',''})
xlabel('Duration (s)')
ylabel('Probability')
xlim([0,12])
ylim([0,1])
set(gca,'box','off')
axis square
ax4.TickLength = [0.03,0.03];
%% [2f] EMG during different arousal states
ax5 = subplot(2,4,5);
edges = -2.5:0.5:2.5;
[curve1] = SmoothHistogramBins_Manuscript2020(data.BehavioralDistributions.Awake.catEMG,edges);
[curve2] = SmoothHistogramBins_Manuscript2020(data.BehavioralDistributions.NREM.catEMG,edges);
[curve3] = SmoothHistogramBins_Manuscript2020(data.BehavioralDistributions.REM.catEMG,edges);
before = findall(gca);
fnplt(curve1);
added = setdiff(findall(gca),before);
set(added,'Color',colors_Manuscript2020('rich black'))
hold on
before = findall(gca);
fnplt(curve2);
added = setdiff(findall(gca),before);
set(added,'Color',colorB)
before = findall(gca);
fnplt(curve3);
added = setdiff(findall(gca),before);
set(added,'Color',colorC)
title({'[2f] EMG power','arousal-state distribution',''})
xlabel('EMG (log10(pwr))')
ylabel('Probability')
xlim([-2.5,2.5])
ylim([0,0.5])
axis square
set(gca,'box','off')
ax5.TickLength = [0.03,0.03];
%% [2g] Whisking distribution during different arousal states
ax6 = subplot(2,4,6);
edges = -3:0.75:3;
[curve1] = SmoothLogHistogramBins_Manuscript2020(data.BehavioralDistributions.Awake.catWhisk,edges);
[curve2] = SmoothLogHistogramBins_Manuscript2020(data.BehavioralDistributions.NREM.catWhisk,edges);
[curve3] = SmoothLogHistogramBins_Manuscript2020(data.BehavioralDistributions.REM.catWhisk,edges);
before = findall(gca);
fnplt(curve1);
added = setdiff(findall(gca),before);
set(added,'Color',colors_Manuscript2020('rich black'))
hold on
before = findall(gca);
fnplt(curve2);
added = setdiff(findall(gca),before);
set(added,'Color',colorB)
before = findall(gca);
fnplt(curve3);
added = setdiff(findall(gca),before);
set(added,'Color',colorC)
title({'[2g] Variance of whisker angle','arousal-state distribution',''})
xlabel('Whisker angle (deg^2)')
ylabel('Probability')
xlim([-3,3])
ylim([0,0.35])
axis square
set(gca,'box','off')
ax6.TickLength = [0.03,0.03];
%% [2h] Heart rate distribution during different arousal states
ax7 = subplot(2,4,7);
edges = 4:1:12;
[curve1] = SmoothHistogramBins_Manuscript2020(data.BehavioralDistributions.Awake.catHeart,edges);
[curve2] = SmoothHistogramBins_Manuscript2020(data.BehavioralDistributions.NREM.catHeart,edges);
[curve3] = SmoothHistogramBins_Manuscript2020(data.BehavioralDistributions.REM.catHeart,edges);
before = findall(gca);
fnplt(curve1);
added = setdiff(findall(gca),before);
set(added,'Color',colors_Manuscript2020('rich black'))
hold on
before = findall(gca);
fnplt(curve2);
added = setdiff(findall(gca),before);
set(added,'Color',colorB)
before = findall(gca);
fnplt(curve3);
added = setdiff(findall(gca),before);
set(added,'Color',colorC)
title({'[2h] Heart rate','arousal-state distribution',''})
xlabel('Heart rate (Hz)')
ylabel('Probability')
ylim([0,0.6])
axis square
set(gca,'box','off')
ax7.TickLength = [0.03,0.03];
%% [2i] Mean heart rate during different behaviors
ax8 = subplot(2,4,8);
HR_xInds = ones(1,length(animalIDs));
s1 = scatter(HR_xInds*1,data.Rest.HR,75,'MarkerEdgeColor','k','MarkerFaceColor',colorA,'jitter','on','jitterAmount',0.25);
hold on
e6 = errorbar(1,data.Rest.meanHR,data.Rest.stdHR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e6.Color = 'black';
e6.MarkerSize = 10;
e6.CapSize = 10;
s2 = scatter(HR_xInds*2,data.Whisk.HR,75,'MarkerEdgeColor','k','MarkerFaceColor',colorD,'jitter','on','jitterAmount',0.25);
e7 = errorbar(2,data.Whisk.meanHR,data.Whisk.stdHR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e7.Color = 'black';
e7.MarkerSize = 10;
e7.CapSize = 10;
s3 = scatter(HR_xInds*3,data.NREM.HR,75,'MarkerEdgeColor','k','MarkerFaceColor',colorB,'jitter','on','jitterAmount',0.25);
e8 = errorbar(3,data.NREM.meanHR,data.NREM.stdHR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e8.Color = 'black';
e8.MarkerSize = 10;
e8.CapSize = 10;
s4 = scatter(HR_xInds*4,data.REM.HR,75,'MarkerEdgeColor','k','MarkerFaceColor',colorC,'jitter','on','jitterAmount',0.25);
e9 = errorbar(4,data.REM.meanHR,data.REM.stdHR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e9.Color = 'black';
e9.MarkerSize = 10;
e9.CapSize = 10;
title({'[2i] Mean heart rate','during arousal states',''})
ylabel('Heart rate (Hz)')
legend([s1,s2,s3,s4],'Rest','Whisking','NREM','REM')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,length(IOS_behavFields) + 1])
ylim([5,11])
set(gca,'box','off')
ax8.TickLength = [0.03,0.03];
%% save figure(s)
dirpath = [rootFolder '\Summary Figures and Structures\'];
if ~exist(dirpath,'dir')
    mkdir(dirpath);
end
savefig(summaryFigureB,[dirpath 'Fig2_B']);
set(summaryFigureB,'PaperPositionMode','auto');
print('-painters','-dpdf','-bestfit',[dirpath 'Fig2_B'])
%% statistical diary
diaryFile = [dirpath 'Fig2_Statistics.txt'];
if exist(diaryFile,'file') == 2
    delete(diaryFile)
end
diary(diaryFile)
diary on
% heart rate statistical diary
disp('======================================================================================================================')
disp('[2i] Generalized linear mixed-effects model statistics for mean heart rate during Rest, Whisk, NREM, and REM')
disp('======================================================================================================================')
disp(HRStats)
disp('----------------------------------------------------------------------------------------------------------------------')
diary off

end
