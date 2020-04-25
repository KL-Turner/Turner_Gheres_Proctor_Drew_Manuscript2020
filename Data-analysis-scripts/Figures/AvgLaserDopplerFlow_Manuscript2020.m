function [] = AvgLaserDopplerFlow_Manuscript2020(rootFolder,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: Calculate the average laser doppler flow during different behavioral states
%________________________________________________________________________________________________________________________

dopplerAnimalIDs = {'T109','T110','T111','T119','T120','T121'};
behavFields = {'Whisk','Rest','NREM','REM'};
colorA = [(51/256),(160/256),(44/256)];   % rest color
colorB = [(192/256),(0/256),(256/256)];   % NREM color
colorC = [(255/256),(140/256),(0/256)];   % REM color
colorD = [(31/256),(120/256),(180/256)];  % whisk color

%% cd through each animal's directory and extract the appropriate analysis results
for a = 1:length(dopplerAnimalIDs)
    animalID = dopplerAnimalIDs{1,a};
    for b = 1:length(behavFields)
        behavField = behavFields{1,b};
        data.(behavField).LDFlow.flowMeans(a,1) = mean(AnalysisResults.(animalID).LDFlow.(behavField));
        data.(behavField).animalID{a,1} = animalID;
        data.(behavField).behavior{a,1} = behavField;
    end
end
% 
for c = 1:length(behavFields)
    behavField = behavFields{1,c};
    data.(behavField).LDFlow.behavMean = mean(data.(behavField).LDFlow.flowMeans);
    data.(behavField).LDFlow.behavStD = std(data.(behavField).LDFlow.flowMeans,0,1);
end

%% statistics - linear mixed effects model
alphaConf = 0.05;
numComparisons = 3;
tableSize = cat(1,data.Rest.LDFlow.flowMeans,data.Whisk.LDFlow.flowMeans,data.NREM.LDFlow.flowMeans,data.REM.LDFlow.flowMeans);
flowTable = table('Size',[size(tableSize,1),3],'VariableTypes',{'string','double','string'},'VariableNames',{'Mouse','Flow','Behavior'});
flowTable.Mouse = cat(1,data.Rest.animalID,data.Whisk.animalID,data.NREM.animalID,data.REM.animalID);
flowTable.Flow = cat(1,data.Rest.LDFlow.flowMeans,data.Whisk.LDFlow.flowMeans,data.NREM.LDFlow.flowMeans,data.REM.LDFlow.flowMeans);
flowTable.Behavior = cat(1,data.Rest.behavior,data.Whisk.behavior,data.NREM.behavior,data.REM.behavior);
flowFitFormula = 'Flow ~ 1 + Behavior + (1|Mouse)';
flowStats = fitglme(flowTable,flowFitFormula);
flowCI = coefCI(flowStats,'Alpha',(alphaConf/numComparisons));

%% summary figure(s)
summaryFigure = figure;
LDF_xInds = ones(1,length(dopplerAnimalIDs));
%% CBV HbT
s1 = scatter(LDF_xInds*1,data.Whisk.LDFlow.flowMeans,100,'MarkerEdgeColor','k','MarkerFaceColor',colorD,'jitter','on','jitterAmount',0.25);
hold on
e1 = errorbar(1,data.Whisk.LDFlow.behavMean,data.Whisk.LDFlow.behavStD,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 15;
e1.CapSize = 15;
s2 = scatter(LDF_xInds*2,data.Rest.LDFlow.flowMeans,100,'MarkerEdgeColor','k','MarkerFaceColor',colorA,'jitter','on','jitterAmount',0.25);
e2 = errorbar(2,data.Rest.LDFlow.behavMean,data.Rest.LDFlow.behavStD,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 15;
e2.CapSize = 15;
s3 = scatter(LDF_xInds*3,data.NREM.LDFlow.flowMeans,100,'MarkerEdgeColor','k','MarkerFaceColor',colorB,'jitter','on','jitterAmount',0.25);
e3 = errorbar(3,data.NREM.LDFlow.behavMean,data.NREM.LDFlow.behavStD,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 15;
e3.CapSize = 15;
s4 = scatter(LDF_xInds*4,data.REM.LDFlow.flowMeans,100,'MarkerEdgeColor','k','MarkerFaceColor',colorC,'jitter','on','jitterAmount',0.25);
e4 = errorbar(4,data.REM.LDFlow.behavMean,data.REM.LDFlow.behavStD,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 15;
e4.CapSize = 15;
title('Mean Laser Doppler Flow')
ylabel('Flow Increase (%)')
legend([s1,s2,s3,s4],'Whisking','Awake Rest','NREM','REM','Location','NorthWest')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,length(behavFields) + 1])
set(gca,'box','off')

% save figure(s)
dirpath = [rootFolder '\Summary Figures and Structures\'];
if ~exist(dirpath,'dir')
    mkdir(dirpath);
end
savefig(summaryFigure,[dirpath 'Summary Figure - Laser Doppler Flow']);
% statistical diary
diary([dirpath 'Behavior_MeanDopplerFlow_Stats.txt'])
diary on
disp('Generalized linear mixed-effects model statistics for mean doppler flow during Rest, Whisking, NREM, and REM')
disp('======================================================================================================================')
disp(flowStats)
disp('======================================================================================================================')
disp('Alpha = 0.05 confidence intervals with 3 comparisons to ''Rest'' (Intercept): ')
disp(['Rest: ' num2str(flowCI(1,:))])
disp(['Whisk: ' num2str(flowCI(2,:))])
disp(['NREM: ' num2str(flowCI(3,:))])
disp(['REM: ' num2str(flowCI(4,:))])
diary off

end
