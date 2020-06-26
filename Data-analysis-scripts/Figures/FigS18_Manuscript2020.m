function [AnalysisResults] = FigS18_Manuscript2020(rootFolder,saveFigs,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Generate figure panel S18 for Turner_Kederasetti_Gheres_Proctor_Costanzo_Drew_Manuscript2020
%________________________________________________________________________________________________________________________

IOS_animalIDs = {'T99','T101','T102','T103','T105','T108','T109','T110','T111','T119','T120','T121','T122','T123'};
behavFields = {'Rest','NREM','REM','Awake','Sleep','All'};
behavFields2 = {'Rest','Whisk','NREM','REM','Awake','Sleep','All'};
dataTypes = {'deltaBandPower','thetaBandPower','alphaBandPower','betaBandPower'};
colorRest = [(51/256),(160/256),(44/256)];
colorNREM = [(192/256),(0/256),(256/256)];
colorREM = [(255/256),(140/256),(0/256)];
colorAwake = [(256/256),(192/256),(0/256)];
colorSleep = [(0/256),(128/256),(256/256)];
colorAll = [(184/256),(115/256),(51/256)];
colorWhisk = [(31/256),(120/256),(180/256)];
% colorStim = [(256/256),(28/256),(207/256)];
% colorIso = [(0/256),(256/256),(256/256)];
%% Average coherence during different behaviors
% cd through each animal's directory and extract the appropriate analysis results
data.Coherr = [];
for a = 1:length(IOS_animalIDs)
    animalID = IOS_animalIDs{1,a};
    for b = 1:length(behavFields)
        behavField = behavFields{1,b};
        % create the behavior folder for the first iteration of the loop
        if isfield(data.Coherr,behavField) == false
            data.Coherr.(behavField) = [];
        end
        for c = 1:length(dataTypes)
            dataType = dataTypes{1,c};
            % don't concatenate empty arrays where there was no data for this behavior
            if isempty(AnalysisResults.(animalID).Coherence.(behavField).(dataType).C) == false
                % create the data type folder for the first iteration of the loop
                if isfield(data.Coherr.(behavField),dataType) == false
                    data.Coherr.(behavField).(dataType).C = [];
                    data.Coherr.(behavField).(dataType).f = [];
                    data.Coherr.(behavField).(dataType).confC = [];
                end
                % concatenate C/f for existing data - exclude any empty sets
                data.Coherr.(behavField).(dataType).C = cat(2,data.Coherr.(behavField).(dataType).C,AnalysisResults.(animalID).Coherence.(behavField).(dataType).C);
                data.Coherr.(behavField).(dataType).f = cat(1,data.Coherr.(behavField).(dataType).f,AnalysisResults.(animalID).Coherence.(behavField).(dataType).f);
                data.Coherr.(behavField).(dataType).confC = cat(1,data.Coherr.(behavField).(dataType).confC,AnalysisResults.(animalID).Coherence.(behavField).(dataType).confC);
            end
        end
    end
end
% take mean/StD of C/f and determine confC line
for e = 1:length(behavFields)
    behavField = behavFields{1,e};
    for f = 1:length(dataTypes)
        dataType = dataTypes{1,f};
        data.Coherr.(behavField).(dataType).meanC = mean(data.Coherr.(behavField).(dataType).C,2);
        data.Coherr.(behavField).(dataType).stdC = std(data.Coherr.(behavField).(dataType).C,0,2);
        data.Coherr.(behavField).(dataType).meanf = mean(data.Coherr.(behavField).(dataType).f,1);
        data.Coherr.(behavField).(dataType).maxConfC = geomean(data.Coherr.(behavField).(dataType).confC);
        data.Coherr.(behavField).(dataType).maxConfC_Y = ones(length(data.Coherr.(behavField).(dataType).meanf),1)*data.Coherr.(behavField).(dataType).maxConfC;
    end
end
%% Power spectra during different behaviors
% cd through each animal's directory and extract the appropriate analysis results
for a = 1:length(IOS_animalIDs)
    animalID = IOS_animalIDs{1,a};
    for b = 1:length(behavFields)
        behavField = behavFields{1,b};
        for c = 1:length(dataTypes)
            dataType = dataTypes{1,c};
            data.PowerSpec.(behavField).(dataType).adjLH.S{a,1} = AnalysisResults.(animalID).PowerSpectra.(behavField).(dataType).adjLH.S;
            data.PowerSpec.(behavField).(dataType).adjLH.f{a,1} = AnalysisResults.(animalID).PowerSpectra.(behavField).(dataType).adjLH.f;
            data.PowerSpec.(behavField).(dataType).adjRH.S{a,1} = AnalysisResults.(animalID).PowerSpectra.(behavField).(dataType).adjRH.S;
            data.PowerSpec.(behavField).(dataType).adjRH.f{a,1} = AnalysisResults.(animalID).PowerSpectra.(behavField).(dataType).adjRH.f;
        end
    end
end
% find the peak of the resting PSD for each animal/hemisphere
for a = 1:length(IOS_animalIDs)
    for c = 1:length(dataTypes)
        dataType = dataTypes{1,c};
        data.PowerSpec.baseline.(dataType).LH{a,1} = max(data.PowerSpec.Rest.(dataType).adjLH.S{a,1});
        data.PowerSpec.baseline.(dataType).RH{a,1} = max(data.PowerSpec.Rest.(dataType).adjRH.S{a,1});
    end
end
% DC-shift each animal/hemisphere/behavior PSD with respect to the resting peak
for a = 1:length(IOS_animalIDs)
    for dd = 1:length(behavFields)
        behavField = behavFields{1,dd};
        for j = 1:length(dataTypes)
            dataType = dataTypes{1,j};
            for ee = 1:size(data.PowerSpec.(behavField).(dataType).adjLH.S,2)
                data.PowerSpec.(behavField).(dataType).normLH{a,1} = (data.PowerSpec.(behavField).(dataType).adjLH.S{a,1})*(1/(data.PowerSpec.baseline.(dataType).LH{a,1}));
                data.PowerSpec.(behavField).(dataType).normRH{a,1} = (data.PowerSpec.(behavField).(dataType).adjRH.S{a,1})*(1/(data.PowerSpec.baseline.(dataType).RH{a,1}));
            end
        end
    end
end
% concatenate the data from the left and right hemispheres - removes any empty data
for e = 1:length(behavFields)
    behavField = behavFields{1,e};
    for f = 1:length(dataTypes)
        dataType = dataTypes{1,f};
        data.PowerSpec.(behavField).(dataType).cat_S = [];
        data.PowerSpec.(behavField).(dataType).cat_f = [];
        for z = 1:length(data.PowerSpec.(behavField).(dataType).normLH)
            data.PowerSpec.(behavField).(dataType).cat_S = cat(2,data.PowerSpec.(behavField).(dataType).cat_S,data.PowerSpec.(behavField).(dataType).normLH{z,1},data.PowerSpec.(behavField).(dataType).normRH{z,1});
            data.PowerSpec.(behavField).(dataType).cat_f = cat(1,data.PowerSpec.(behavField).(dataType).cat_f,data.PowerSpec.(behavField).(dataType).adjLH.f{z,1},data.PowerSpec.(behavField).(dataType).adjRH.f{z,1});
        end
    end
end
% take mean/StD of S/f
for h = 1:length(behavFields)
    behavField = behavFields{1,h};
    for j = 1:length(dataTypes)
        dataType = dataTypes{1,j};
        data.PowerSpec.(behavField).(dataType).meanCortS = mean(data.PowerSpec.(behavField).(dataType).cat_S,2);
        data.PowerSpec.(behavField).(dataType).stdCortS = std(data.PowerSpec.(behavField).(dataType).cat_S,0,2);
        data.PowerSpec.(behavField).(dataType).meanCortf = mean(data.PowerSpec.(behavField).(dataType).cat_f,1);
    end
end
%% Pearson's correlations during different behaviors
% cd through each animal's directory and extract the appropriate analysis results
data.CorrCoef = [];
for a = 1:length(IOS_animalIDs)
    animalID = IOS_animalIDs{1,a};
    for b = 1:length(behavFields2)
        behavField = behavFields2{1,b};
        % create the behavior folder for the first iteration of the loop
        if isfield(data.CorrCoef,behavField) == false
            data.CorrCoef.(behavField) = [];
        end
        for c = 1:length(dataTypes)
            dataType = dataTypes{1,c};
            % don't concatenate empty arrays where there was no data for this behavior
            if isempty(AnalysisResults.(animalID).CorrCoeff.(behavField).(dataType).meanR) == false
                % create the data type folder for the first iteration of the loop
                if isfield(data.CorrCoef.(behavField),dataType) == false
                    data.CorrCoef.(behavField).(dataType).meanRs = [];
                    data.CorrCoef.(behavField).(dataType).animalID = {};
                    data.CorrCoef.(behavField).(dataType).behavior = {};
                end
                % concatenate mean R and the animalID/behavior for statistics table
                data.CorrCoef.(behavField).(dataType).meanRs = cat(1,data.CorrCoef.(behavField).(dataType).meanRs,AnalysisResults.(animalID).CorrCoeff.(behavField).(dataType).meanR);
                data.CorrCoef.(behavField).(dataType).animalID = cat(1,data.CorrCoef.(behavField).(dataType).animalID,animalID);
                data.CorrCoef.(behavField).(dataType).behavior = cat(1,data.CorrCoef.(behavField).(dataType).behavior,behavField);
            end
        end
    end
end
% take mean/STD of R
for e = 1:length(behavFields2)
    behavField = behavFields2{1,e};
    for f = 1:length(dataTypes)
        dataType = dataTypes{1,f};
        data.CorrCoef.(behavField).(dataType).meanR = mean(data.CorrCoef.(behavField).(dataType).meanRs,1);
        data.CorrCoef.(behavField).(dataType).stdR = std(data.CorrCoef.(behavField).(dataType).meanRs,0,1);
    end
end
%% statistics - linear mixed effects model
% delta-band power
deltatableSize = cat(1,data.CorrCoef.Rest.deltaBandPower.meanRs,data.CorrCoef.Whisk.deltaBandPower.meanRs,data.CorrCoef.NREM.deltaBandPower.meanRs,data.CorrCoef.REM.deltaBandPower.meanRs,...
    data.CorrCoef.Awake.deltaBandPower.meanRs,data.CorrCoef.Sleep.deltaBandPower.meanRs,data.CorrCoef.All.deltaBandPower.meanRs);
deltaTable = table('Size',[size(deltatableSize,1),3],'VariableTypes',{'string','double','string'},'VariableNames',{'Mouse','CorrCoef','Behavior'});
deltaTable.Mouse = cat(1,data.CorrCoef.Rest.deltaBandPower.animalID,data.CorrCoef.Whisk.deltaBandPower.animalID,data.CorrCoef.NREM.deltaBandPower.animalID,data.CorrCoef.REM.deltaBandPower.animalID,...
    data.CorrCoef.Awake.deltaBandPower.animalID,data.CorrCoef.Sleep.deltaBandPower.animalID,data.CorrCoef.All.deltaBandPower.animalID);
deltaTable.CorrCoef = cat(1,data.CorrCoef.Rest.deltaBandPower.meanRs,data.CorrCoef.Whisk.deltaBandPower.meanRs,data.CorrCoef.NREM.deltaBandPower.meanRs,data.CorrCoef.REM.deltaBandPower.meanRs,...
    data.CorrCoef.Awake.deltaBandPower.meanRs,data.CorrCoef.Sleep.deltaBandPower.meanRs,data.CorrCoef.All.deltaBandPower.meanRs);
deltaTable.Behavior = cat(1,data.CorrCoef.Rest.deltaBandPower.behavior,data.CorrCoef.Whisk.deltaBandPower.behavior,data.CorrCoef.NREM.deltaBandPower.behavior,data.CorrCoef.REM.deltaBandPower.behavior,...
    data.CorrCoef.Awake.deltaBandPower.behavior,data.CorrCoef.Sleep.deltaBandPower.behavior,data.CorrCoef.All.deltaBandPower.behavior);
deltaFitFormula = 'CorrCoef ~ 1 + Behavior + (1|Mouse)';
deltaStats = fitglme(deltaTable,deltaFitFormula);
% theta-band power
thetatableSize = cat(1,data.CorrCoef.Rest.thetaBandPower.meanRs,data.CorrCoef.Whisk.thetaBandPower.meanRs,data.CorrCoef.NREM.thetaBandPower.meanRs,data.CorrCoef.REM.thetaBandPower.meanRs,...
    data.CorrCoef.Awake.thetaBandPower.meanRs,data.CorrCoef.Sleep.thetaBandPower.meanRs,data.CorrCoef.All.thetaBandPower.meanRs);
thetaTable = table('Size',[size(thetatableSize,1),3],'VariableTypes',{'string','double','string'},'VariableNames',{'Mouse','CorrCoef','Behavior'});
thetaTable.Mouse = cat(1,data.CorrCoef.Rest.thetaBandPower.animalID,data.CorrCoef.Whisk.thetaBandPower.animalID,data.CorrCoef.NREM.thetaBandPower.animalID,data.CorrCoef.REM.thetaBandPower.animalID,...
    data.CorrCoef.Awake.thetaBandPower.animalID,data.CorrCoef.Sleep.thetaBandPower.animalID,data.CorrCoef.All.thetaBandPower.animalID);
thetaTable.CorrCoef = cat(1,data.CorrCoef.Rest.thetaBandPower.meanRs,data.CorrCoef.Whisk.thetaBandPower.meanRs,data.CorrCoef.NREM.thetaBandPower.meanRs,data.CorrCoef.REM.thetaBandPower.meanRs,...
    data.CorrCoef.Awake.thetaBandPower.meanRs,data.CorrCoef.Sleep.thetaBandPower.meanRs,data.CorrCoef.All.thetaBandPower.meanRs);
thetaTable.Behavior = cat(1,data.CorrCoef.Rest.thetaBandPower.behavior,data.CorrCoef.Whisk.thetaBandPower.behavior,data.CorrCoef.NREM.thetaBandPower.behavior,data.CorrCoef.REM.thetaBandPower.behavior,...
    data.CorrCoef.Awake.thetaBandPower.behavior,data.CorrCoef.Sleep.thetaBandPower.behavior,data.CorrCoef.All.thetaBandPower.behavior);
thetaFitFormula = 'CorrCoef ~ 1 + Behavior + (1|Mouse)';
thetaStats = fitglme(thetaTable,thetaFitFormula);
% alpha-band power
alphatableSize = cat(1,data.CorrCoef.Rest.alphaBandPower.meanRs,data.CorrCoef.Whisk.alphaBandPower.meanRs,data.CorrCoef.NREM.alphaBandPower.meanRs,data.CorrCoef.REM.alphaBandPower.meanRs,...
    data.CorrCoef.Awake.alphaBandPower.meanRs,data.CorrCoef.Sleep.alphaBandPower.meanRs,data.CorrCoef.All.alphaBandPower.meanRs);
alphaTable = table('Size',[size(alphatableSize,1),3],'VariableTypes',{'string','double','string'},'VariableNames',{'Mouse','CorrCoef','Behavior'});
alphaTable.Mouse = cat(1,data.CorrCoef.Rest.alphaBandPower.animalID,data.CorrCoef.Whisk.alphaBandPower.animalID,data.CorrCoef.NREM.alphaBandPower.animalID,data.CorrCoef.REM.alphaBandPower.animalID,...
    data.CorrCoef.Awake.alphaBandPower.animalID,data.CorrCoef.Sleep.alphaBandPower.animalID,data.CorrCoef.All.alphaBandPower.animalID);
alphaTable.CorrCoef = cat(1,data.CorrCoef.Rest.alphaBandPower.meanRs,data.CorrCoef.Whisk.alphaBandPower.meanRs,data.CorrCoef.NREM.alphaBandPower.meanRs,data.CorrCoef.REM.alphaBandPower.meanRs,...
    data.CorrCoef.Awake.alphaBandPower.meanRs,data.CorrCoef.Sleep.alphaBandPower.meanRs,data.CorrCoef.All.alphaBandPower.meanRs);
alphaTable.Behavior = cat(1,data.CorrCoef.Rest.alphaBandPower.behavior,data.CorrCoef.Whisk.alphaBandPower.behavior,data.CorrCoef.NREM.alphaBandPower.behavior,data.CorrCoef.REM.alphaBandPower.behavior,...
    data.CorrCoef.Awake.alphaBandPower.behavior,data.CorrCoef.Sleep.alphaBandPower.behavior,data.CorrCoef.All.alphaBandPower.behavior);
alphaFitFormula = 'CorrCoef ~ 1 + Behavior + (1|Mouse)';
alphaStats = fitglme(alphaTable,alphaFitFormula);
% beta-band power
betatableSize = cat(1,data.CorrCoef.Rest.betaBandPower.meanRs,data.CorrCoef.Whisk.betaBandPower.meanRs,data.CorrCoef.NREM.betaBandPower.meanRs,data.CorrCoef.REM.betaBandPower.meanRs,...
    data.CorrCoef.Awake.betaBandPower.meanRs,data.CorrCoef.Sleep.betaBandPower.meanRs,data.CorrCoef.All.betaBandPower.meanRs);
betaTable = table('Size',[size(betatableSize,1),3],'VariableTypes',{'string','double','string'},'VariableNames',{'Mouse','CorrCoef','Behavior'});
betaTable.Mouse = cat(1,data.CorrCoef.Rest.betaBandPower.animalID,data.CorrCoef.Whisk.betaBandPower.animalID,data.CorrCoef.NREM.betaBandPower.animalID,data.CorrCoef.REM.betaBandPower.animalID,...
    data.CorrCoef.Awake.betaBandPower.animalID,data.CorrCoef.Sleep.betaBandPower.animalID,data.CorrCoef.All.betaBandPower.animalID);
betaTable.CorrCoef = cat(1,data.CorrCoef.Rest.betaBandPower.meanRs,data.CorrCoef.Whisk.betaBandPower.meanRs,data.CorrCoef.NREM.betaBandPower.meanRs,data.CorrCoef.REM.betaBandPower.meanRs,...
    data.CorrCoef.Awake.betaBandPower.meanRs,data.CorrCoef.Sleep.betaBandPower.meanRs,data.CorrCoef.All.betaBandPower.meanRs);
betaTable.Behavior = cat(1,data.CorrCoef.Rest.betaBandPower.behavior,data.CorrCoef.Whisk.betaBandPower.behavior,data.CorrCoef.NREM.betaBandPower.behavior,data.CorrCoef.REM.betaBandPower.behavior,...
    data.CorrCoef.Awake.betaBandPower.behavior,data.CorrCoef.Sleep.betaBandPower.behavior,data.CorrCoef.All.betaBandPower.behavior);
betaFitFormula = 'CorrCoef ~ 1 + Behavior + (1|Mouse)';
betaStats = fitglme(betaTable,betaFitFormula);
%% Fig. S18
summaryFigure = figure('Name','FigS18 (a-l)'); %#ok<*NASGU>
sgtitle('Figure Panel S18 (a-l) Turner Manuscript 2020')
CC_xInds = ones(1,length(IOS_animalIDs));
CC_xInds2 = ones(1,length(data.CorrCoef.Awake.deltaBandPower.animalID));
CC_xInds3 = ones(1,length(data.CorrCoef.Sleep.deltaBandPower.animalID));

%% [S18a] Power spectra of delta-band power during different arousal-states
ax1 = subplot(4,3,1);
L1 = loglog(data.PowerSpec.Rest.deltaBandPower.meanCortf,data.PowerSpec.Rest.deltaBandPower.meanCortS,'color',colorRest,'LineWidth',2);
hold on
L2 = loglog(data.PowerSpec.NREM.deltaBandPower.meanCortf,data.PowerSpec.NREM.deltaBandPower.meanCortS,'color',colorNREM,'LineWidth',2);
L3 = loglog(data.PowerSpec.REM.deltaBandPower.meanCortf,data.PowerSpec.REM.deltaBandPower.meanCortS,'color',colorREM,'LineWidth',2);
L4 = loglog(data.PowerSpec.Awake.deltaBandPower.meanCortf,data.PowerSpec.Awake.deltaBandPower.meanCortS,'color',colorAwake,'LineWidth',2);
L5 = loglog(data.PowerSpec.Sleep.deltaBandPower.meanCortf,data.PowerSpec.Sleep.deltaBandPower.meanCortS,'color',colorSleep,'LineWidth',2);
L6 = loglog(data.PowerSpec.All.deltaBandPower.meanCortf,data.PowerSpec.All.deltaBandPower.meanCortS,'color',colorAll,'LineWidth',2);
xline(1/10,'color','k');
xline(1/30,'color','k');
xline(1/60,'color','k');
title({'[S18a] Cortical power','Delta-band [1-4 Hz]',''})
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([L1,L2,L3,L4,L5,L6],'Rest','NREM','REM','Awake','Sleep','All','Location','SouthEast')
axis square
xlim([0.003,0.5])
y5 = ylim(ax1);
ylim([y5(1)/2,y5(2)*2])
set(gca,'box','off')
ax1.TickLength = [0.03,0.03];
%% [S18b] Coherence between bilateral delta-band power during different arousal-states
ax2 = subplot(4,3,2);
semilogx(data.Coherr.Rest.deltaBandPower.meanf,data.Coherr.Rest.deltaBandPower.meanC.^2,'color',colorRest,'LineWidth',2);
hold on
semilogx(data.Coherr.NREM.deltaBandPower.meanf,data.Coherr.NREM.deltaBandPower.meanC.^2,'color',colorNREM,'LineWidth',2);
semilogx(data.Coherr.REM.deltaBandPower.meanf,data.Coherr.REM.deltaBandPower.meanC.^2,'color',colorREM,'LineWidth',2);
semilogx(data.Coherr.Awake.deltaBandPower.meanf,data.Coherr.Awake.deltaBandPower.meanC.^2,'color',colorAwake,'LineWidth',2);
semilogx(data.Coherr.Sleep.deltaBandPower.meanf,data.Coherr.Sleep.deltaBandPower.meanC.^2,'color',colorSleep,'LineWidth',2);
semilogx(data.Coherr.All.deltaBandPower.meanf,data.Coherr.All.deltaBandPower.meanC.^2,'color',colorAll,'LineWidth',2);
% confidence lines
semilogx(data.Coherr.Rest.deltaBandPower.meanf,data.Coherr.Rest.deltaBandPower.maxConfC_Y.^2,'-','color',colorRest,'LineWidth',1);
semilogx(data.Coherr.NREM.deltaBandPower.meanf,data.Coherr.NREM.deltaBandPower.maxConfC_Y.^2,'-','color',colorNREM,'LineWidth',1);
semilogx(data.Coherr.REM.deltaBandPower.meanf,data.Coherr.REM.deltaBandPower.maxConfC_Y.^2,'-','color',colorREM,'LineWidth',1);
semilogx(data.Coherr.Awake.deltaBandPower.meanf,data.Coherr.Awake.deltaBandPower.maxConfC_Y.^2,'-','color',colorAwake,'LineWidth',1);
semilogx(data.Coherr.Sleep.deltaBandPower.meanf,data.Coherr.Sleep.deltaBandPower.maxConfC_Y.^2,'-','color',colorSleep,'LineWidth',1);
semilogx(data.Coherr.All.deltaBandPower.meanf,data.Coherr.All.deltaBandPower.maxConfC_Y.^2,'-','color',colorAll,'LineWidth',1);
xline(1/10,'color','k');
xline(1/30,'color','k');
xline(1/60,'color','k');
title('Delta-band [1-4 Hz]')
ylabel('Coherence^2')
xlabel('Freq (Hz)')
title({'[S18b] Bilateral coherence','Delta-band [1-4 Hz]',''})
axis square
xlim([0.003,0.5])
ylim([0,1])
set(gca,'box','off')
ax2.TickLength = [0.03,0.03];
%% [S18c] Pearson's correlations between bilateral delta-band power during different arousal-states
ax3 = subplot(4,3,3);
s1 = scatter(CC_xInds*1,data.CorrCoef.Rest.deltaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorRest,'jitter','on', 'jitterAmount',0.25);
hold on
e1 = errorbar(1,data.CorrCoef.Rest.deltaBandPower.meanR,data.CorrCoef.Rest.deltaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
s2 = scatter(CC_xInds*2,data.CorrCoef.Whisk.deltaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorWhisk,'jitter','on', 'jitterAmount',0.25);
e2 = errorbar(2,data.CorrCoef.Whisk.deltaBandPower.meanR,data.CorrCoef.Whisk.deltaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
s3 = scatter(CC_xInds*3,data.CorrCoef.NREM.deltaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorNREM,'jitter','on', 'jitterAmount',0.25);
e3 = errorbar(3,data.CorrCoef.NREM.deltaBandPower.meanR,data.CorrCoef.NREM.deltaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
s4 = scatter(CC_xInds*4,data.CorrCoef.REM.deltaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorREM,'jitter','on', 'jitterAmount',0.25);
e4 = errorbar(4,data.CorrCoef.REM.deltaBandPower.meanR,data.CorrCoef.REM.deltaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
s5 = scatter(CC_xInds2*5,data.CorrCoef.Awake.deltaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAwake,'jitter','on', 'jitterAmount',0.25);
e5 = errorbar(5,data.CorrCoef.Awake.deltaBandPower.meanR,data.CorrCoef.Awake.deltaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
s6 = scatter(CC_xInds3*6,data.CorrCoef.Sleep.deltaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorSleep,'jitter','on', 'jitterAmount',0.25);
e6 = errorbar(6,data.CorrCoef.Sleep.deltaBandPower.meanR,data.CorrCoef.Sleep.deltaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e6.Color = 'black';
e6.MarkerSize = 10;
e6.CapSize = 10;
s7 = scatter(CC_xInds*7,data.CorrCoef.All.deltaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAll,'jitter','on', 'jitterAmount',0.25);
e7 = errorbar(7,data.CorrCoef.All.deltaBandPower.meanR,data.CorrCoef.All.deltaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e7.Color = 'black';
e7.MarkerSize = 10;
e7.CapSize = 10;
title({'[S18c] Cortical Pearson''s corr. coef','Delta-band [1-4 Hz]',''})
ylabel({'Corr. Coefficient';'Left hem vs. Right hem'})
legend([s1,s2,s3,s4,s5,s6,s7],'Rest','Whisk','NREM','REM','Awake','Sleep','All')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,length(behavFields2) + 1])
ylim([-0.1,1])
set(gca,'box','off')
ax3.TickLength = [0.03,0.03];
%% [S18d] Power spectra of theta-band power during different arousal-states
ax4 = subplot(4,3,4);
loglog(data.PowerSpec.Rest.thetaBandPower.meanCortf,data.PowerSpec.Rest.thetaBandPower.meanCortS,'color',colorRest,'LineWidth',2);
hold on
loglog(data.PowerSpec.NREM.thetaBandPower.meanCortf,data.PowerSpec.NREM.thetaBandPower.meanCortS,'color',colorNREM,'LineWidth',2);
loglog(data.PowerSpec.REM.thetaBandPower.meanCortf,data.PowerSpec.REM.thetaBandPower.meanCortS,'color',colorREM,'LineWidth',2);
loglog(data.PowerSpec.Awake.thetaBandPower.meanCortf,data.PowerSpec.Awake.thetaBandPower.meanCortS,'color',colorAwake,'LineWidth',2);
loglog(data.PowerSpec.Sleep.thetaBandPower.meanCortf,data.PowerSpec.Sleep.thetaBandPower.meanCortS,'color',colorSleep,'LineWidth',2);
loglog(data.PowerSpec.All.thetaBandPower.meanCortf,data.PowerSpec.All.thetaBandPower.meanCortS,'color',colorAll,'LineWidth',2);
xline(1/10,'color','k');
xline(1/30,'color','k');
xline(1/60,'color','k');
title({'[S18d] Cortical power','Theta-band [4-10 Hz]',''})
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
axis square
xlim([0.003,0.5])
y5 = ylim(ax4);
ylim([y5(1)/2,y5(2)*2])
set(gca,'box','off')
ax4.TickLength = [0.03,0.03];
%% [S18e] Coherence between bilateral theta-band power during different arousal-states
ax5 = subplot(4,3,5);
semilogx(data.Coherr.Rest.thetaBandPower.meanf,data.Coherr.Rest.thetaBandPower.meanC.^2,'color',colorRest,'LineWidth',2);
hold on
semilogx(data.Coherr.NREM.thetaBandPower.meanf,data.Coherr.NREM.thetaBandPower.meanC.^2,'color',colorNREM,'LineWidth',2);
semilogx(data.Coherr.REM.thetaBandPower.meanf,data.Coherr.REM.thetaBandPower.meanC.^2,'color',colorREM,'LineWidth',2);
semilogx(data.Coherr.Awake.thetaBandPower.meanf,data.Coherr.Awake.thetaBandPower.meanC.^2,'color',colorAwake,'LineWidth',2);
semilogx(data.Coherr.Sleep.thetaBandPower.meanf,data.Coherr.Sleep.thetaBandPower.meanC.^2,'color',colorSleep,'LineWidth',2);
semilogx(data.Coherr.All.thetaBandPower.meanf,data.Coherr.All.thetaBandPower.meanC.^2,'color',colorAll,'LineWidth',2);
% confidence lines
semilogx(data.Coherr.Rest.thetaBandPower.meanf,data.Coherr.Rest.thetaBandPower.maxConfC_Y.^2,'-','color',colorRest,'LineWidth',1);
semilogx(data.Coherr.NREM.thetaBandPower.meanf,data.Coherr.NREM.thetaBandPower.maxConfC_Y.^2,'-','color',colorNREM,'LineWidth',1);
semilogx(data.Coherr.REM.thetaBandPower.meanf,data.Coherr.REM.thetaBandPower.maxConfC_Y.^2,'-','color',colorREM,'LineWidth',1);
semilogx(data.Coherr.Awake.thetaBandPower.meanf,data.Coherr.Awake.thetaBandPower.maxConfC_Y.^2,'-','color',colorAwake,'LineWidth',1);
semilogx(data.Coherr.Sleep.thetaBandPower.meanf,data.Coherr.Sleep.thetaBandPower.maxConfC_Y.^2,'-','color',colorSleep,'LineWidth',1);
semilogx(data.Coherr.All.thetaBandPower.meanf,data.Coherr.All.thetaBandPower.maxConfC_Y.^2,'-','color',colorAll,'LineWidth',1);
xline(1/10,'color','k');
xline(1/30,'color','k');
xline(1/60,'color','k');
title('Theta-band [4-10 Hz]')
ylabel('Coherence^2')
xlabel('Freq (Hz)')
title({'[S18e] Bilateral coherence','Theta-band [4-10 Hz]',''})
axis square
xlim([0.003,0.5])
ylim([0,1])
set(gca,'box','off')
ax5.TickLength = [0.03,0.03];
%% [S18f] Pearson's correlations between bilateral theta-band power during different arousal-states
ax6 = subplot(4,3,6);
scatter(CC_xInds*1,data.CorrCoef.Rest.thetaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorRest,'jitter','on', 'jitterAmount',0.25);
hold on
e1 = errorbar(1,data.CorrCoef.Rest.thetaBandPower.meanR,data.CorrCoef.Rest.thetaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(CC_xInds*2,data.CorrCoef.Whisk.thetaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorWhisk,'jitter','on', 'jitterAmount',0.25);
e2 = errorbar(2,data.CorrCoef.Whisk.thetaBandPower.meanR,data.CorrCoef.Whisk.thetaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(CC_xInds*3,data.CorrCoef.NREM.thetaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorNREM,'jitter','on', 'jitterAmount',0.25);
e3 = errorbar(3,data.CorrCoef.NREM.thetaBandPower.meanR,data.CorrCoef.NREM.thetaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
scatter(CC_xInds*4,data.CorrCoef.REM.thetaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorREM,'jitter','on', 'jitterAmount',0.25);
e4 = errorbar(4,data.CorrCoef.REM.thetaBandPower.meanR,data.CorrCoef.REM.thetaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
scatter(CC_xInds2*5,data.CorrCoef.Awake.thetaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAwake,'jitter','on', 'jitterAmount',0.25);
e5 = errorbar(5,data.CorrCoef.Awake.thetaBandPower.meanR,data.CorrCoef.Awake.thetaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
scatter(CC_xInds3*6,data.CorrCoef.Sleep.thetaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorSleep,'jitter','on', 'jitterAmount',0.25);
e6 = errorbar(6,data.CorrCoef.Sleep.thetaBandPower.meanR,data.CorrCoef.Sleep.thetaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e6.Color = 'black';
e6.MarkerSize = 10;
e6.CapSize = 10;
scatter(CC_xInds*7,data.CorrCoef.All.thetaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAll,'jitter','on', 'jitterAmount',0.25);
e7 = errorbar(7,data.CorrCoef.All.thetaBandPower.meanR,data.CorrCoef.All.thetaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e7.Color = 'black';
e7.MarkerSize = 10;
e7.CapSize = 10;
title({'[S18f] Cortical Pearson''s corr. coef','Theta-band [4-10 Hz]',''})
ylabel({'Corr. Coefficient';'Left hem vs. Right hem'})
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,length(behavFields2) + 1])
ylim([-0.1,1])
set(gca,'box','off')
ax6.TickLength = [0.03,0.03];
%% [S18g] Power spectra of alpha-band power during different arousal-states
ax7 = subplot(4,3,7);
loglog(data.PowerSpec.Rest.alphaBandPower.meanCortf,data.PowerSpec.Rest.alphaBandPower.meanCortS,'color',colorRest,'LineWidth',2);
hold on
loglog(data.PowerSpec.NREM.alphaBandPower.meanCortf,data.PowerSpec.NREM.alphaBandPower.meanCortS,'color',colorNREM,'LineWidth',2);
loglog(data.PowerSpec.REM.alphaBandPower.meanCortf,data.PowerSpec.REM.alphaBandPower.meanCortS,'color',colorREM,'LineWidth',2);
loglog(data.PowerSpec.Awake.alphaBandPower.meanCortf,data.PowerSpec.Awake.alphaBandPower.meanCortS,'color',colorAwake,'LineWidth',2);
loglog(data.PowerSpec.Sleep.alphaBandPower.meanCortf,data.PowerSpec.Sleep.alphaBandPower.meanCortS,'color',colorSleep,'LineWidth',2);
loglog(data.PowerSpec.All.alphaBandPower.meanCortf,data.PowerSpec.All.alphaBandPower.meanCortS,'color',colorAll,'LineWidth',2);
xline(1/10,'color','k');
xline(1/30,'color','k');
xline(1/60,'color','k');
title({'[S18g] Cortical power','Alpha-band [10-13 Hz]',''})
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
axis square
xlim([0.003,0.5])
y5 = ylim(ax7);
ylim([y5(1)/2,y5(2)*2])
set(gca,'box','off')
ax7.TickLength = [0.03,0.03];
%% [S18h] Coherence between bilateral alpha-band power during different arousal-states
ax8 = subplot(4,3,8);
semilogx(data.Coherr.Rest.alphaBandPower.meanf,data.Coherr.Rest.alphaBandPower.meanC.^2,'color',colorRest,'LineWidth',2);
hold on
semilogx(data.Coherr.NREM.alphaBandPower.meanf,data.Coherr.NREM.alphaBandPower.meanC.^2,'color',colorNREM,'LineWidth',2);
semilogx(data.Coherr.REM.alphaBandPower.meanf,data.Coherr.REM.alphaBandPower.meanC.^2,'color',colorREM,'LineWidth',2);
semilogx(data.Coherr.Awake.alphaBandPower.meanf,data.Coherr.Awake.alphaBandPower.meanC.^2,'color',colorAwake,'LineWidth',2);
semilogx(data.Coherr.Sleep.alphaBandPower.meanf,data.Coherr.Sleep.alphaBandPower.meanC.^2,'color',colorSleep,'LineWidth',2);
semilogx(data.Coherr.All.alphaBandPower.meanf,data.Coherr.All.alphaBandPower.meanC.^2,'color',colorAll,'LineWidth',2);
% confidence lines
semilogx(data.Coherr.Rest.alphaBandPower.meanf,data.Coherr.Rest.alphaBandPower.maxConfC_Y.^2,'-','color',colorRest,'LineWidth',1);
semilogx(data.Coherr.NREM.alphaBandPower.meanf,data.Coherr.NREM.alphaBandPower.maxConfC_Y.^2,'-','color',colorNREM,'LineWidth',1);
semilogx(data.Coherr.REM.alphaBandPower.meanf,data.Coherr.REM.alphaBandPower.maxConfC_Y.^2,'-','color',colorREM,'LineWidth',1);
semilogx(data.Coherr.Awake.alphaBandPower.meanf,data.Coherr.Awake.alphaBandPower.maxConfC_Y.^2,'-','color',colorAwake,'LineWidth',1);
semilogx(data.Coherr.Sleep.alphaBandPower.meanf,data.Coherr.Sleep.alphaBandPower.maxConfC_Y.^2,'-','color',colorSleep,'LineWidth',1);
semilogx(data.Coherr.All.alphaBandPower.meanf,data.Coherr.All.alphaBandPower.maxConfC_Y.^2,'-','color',colorAll,'LineWidth',1);
xline(1/10,'color','k');
xline(1/30,'color','k');
xline(1/60,'color','k');
title('Alpha-band [10-13 Hz]')
ylabel('Coherence^2')
xlabel('Freq (Hz)')
title({'[S18h] Bilateral coherence','Alpha-band [10-13 Hz]',''})
axis square
xlim([0.003,0.5])
ylim([0,1])
set(gca,'box','off')
ax8.TickLength = [0.03,0.03];
%% [S18i] Pearson's correlations between bilateral alpha-band power during different arousal-states
ax9 = subplot(4,3,9);
scatter(CC_xInds*1,data.CorrCoef.Rest.alphaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorRest,'jitter','on', 'jitterAmount',0.25);
hold on
e1 = errorbar(1,data.CorrCoef.Rest.alphaBandPower.meanR,data.CorrCoef.Rest.alphaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(CC_xInds*2,data.CorrCoef.Whisk.alphaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorWhisk,'jitter','on', 'jitterAmount',0.25);
e2 = errorbar(2,data.CorrCoef.Whisk.alphaBandPower.meanR,data.CorrCoef.Whisk.alphaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(CC_xInds*3,data.CorrCoef.NREM.alphaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorNREM,'jitter','on', 'jitterAmount',0.25);
e3 = errorbar(3,data.CorrCoef.NREM.alphaBandPower.meanR,data.CorrCoef.NREM.alphaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
scatter(CC_xInds*4,data.CorrCoef.REM.alphaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorREM,'jitter','on', 'jitterAmount',0.25);
e4 = errorbar(4,data.CorrCoef.REM.alphaBandPower.meanR,data.CorrCoef.REM.alphaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
scatter(CC_xInds2*5,data.CorrCoef.Awake.alphaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAwake,'jitter','on', 'jitterAmount',0.25);
e5 = errorbar(5,data.CorrCoef.Awake.alphaBandPower.meanR,data.CorrCoef.Awake.alphaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
scatter(CC_xInds3*6,data.CorrCoef.Sleep.alphaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorSleep,'jitter','on', 'jitterAmount',0.25);
e6 = errorbar(6,data.CorrCoef.Sleep.alphaBandPower.meanR,data.CorrCoef.Sleep.alphaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e6.Color = 'black';
e6.MarkerSize = 10;
e6.CapSize = 10;
scatter(CC_xInds*7,data.CorrCoef.All.alphaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAll,'jitter','on', 'jitterAmount',0.25);
e7 = errorbar(7,data.CorrCoef.All.alphaBandPower.meanR,data.CorrCoef.All.alphaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e7.Color = 'black';
e7.MarkerSize = 10;
e7.CapSize = 10;
title({'[S18i] Cortical Pearson''s corr. coef','Alpha-band [10-13 Hz]',''})
ylabel({'Corr. Coefficient';'Left hem vs. Right hem'})
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,length(behavFields2) + 1])
ylim([-0.1,1])
set(gca,'box','off')
ax9.TickLength = [0.03,0.03];
%% [S18j] Power spectra of beta-band power during different arousal-states
ax10 = subplot(4,3,10);
loglog(data.PowerSpec.Rest.betaBandPower.meanCortf,data.PowerSpec.Rest.betaBandPower.meanCortS,'color',colorRest,'LineWidth',2);
hold on
loglog(data.PowerSpec.NREM.betaBandPower.meanCortf,data.PowerSpec.NREM.betaBandPower.meanCortS,'color',colorNREM,'LineWidth',2);
loglog(data.PowerSpec.REM.betaBandPower.meanCortf,data.PowerSpec.REM.betaBandPower.meanCortS,'color',colorREM,'LineWidth',2);
loglog(data.PowerSpec.Awake.betaBandPower.meanCortf,data.PowerSpec.Awake.betaBandPower.meanCortS,'color',colorAwake,'LineWidth',2);
loglog(data.PowerSpec.Sleep.betaBandPower.meanCortf,data.PowerSpec.Sleep.betaBandPower.meanCortS,'color',colorSleep,'LineWidth',2);
loglog(data.PowerSpec.All.betaBandPower.meanCortf,data.PowerSpec.All.betaBandPower.meanCortS,'color',colorAll,'LineWidth',2);
xline(1/10,'color','k');
xline(1/30,'color','k');
xline(1/60,'color','k');
title({'[S18j] Cortical power','Beta-band [13-30 Hz]',''})
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
axis square
xlim([0.003,0.5])
y5 = ylim(ax10);
ylim([y5(1)/2,y5(2)*2])
set(gca,'box','off')
ax10.TickLength = [0.03,0.03];
%% [S18k] Coherence between bilateral beta-band power during different arousal-states
ax11 = subplot(4,3,11);
semilogx(data.Coherr.Rest.betaBandPower.meanf,data.Coherr.Rest.betaBandPower.meanC.^2,'color',colorRest,'LineWidth',2);
hold on
semilogx(data.Coherr.NREM.betaBandPower.meanf,data.Coherr.NREM.betaBandPower.meanC.^2,'color',colorNREM,'LineWidth',2);
semilogx(data.Coherr.REM.betaBandPower.meanf,data.Coherr.REM.betaBandPower.meanC.^2,'color',colorREM,'LineWidth',2);
semilogx(data.Coherr.Awake.betaBandPower.meanf,data.Coherr.Awake.betaBandPower.meanC.^2,'color',colorAwake,'LineWidth',2);
semilogx(data.Coherr.Sleep.betaBandPower.meanf,data.Coherr.Sleep.betaBandPower.meanC.^2,'color',colorSleep,'LineWidth',2);
semilogx(data.Coherr.All.betaBandPower.meanf,data.Coherr.All.betaBandPower.meanC.^2,'color',colorAll,'LineWidth',2);
% confidence lines
semilogx(data.Coherr.Rest.betaBandPower.meanf,data.Coherr.Rest.betaBandPower.maxConfC_Y.^2,'-','color',colorRest,'LineWidth',1);
semilogx(data.Coherr.NREM.betaBandPower.meanf,data.Coherr.NREM.betaBandPower.maxConfC_Y.^2,'-','color',colorNREM,'LineWidth',1);
semilogx(data.Coherr.REM.betaBandPower.meanf,data.Coherr.REM.betaBandPower.maxConfC_Y.^2,'-','color',colorREM,'LineWidth',1);
semilogx(data.Coherr.Awake.betaBandPower.meanf,data.Coherr.Awake.betaBandPower.maxConfC_Y.^2,'-','color',colorAwake,'LineWidth',1);
semilogx(data.Coherr.Sleep.betaBandPower.meanf,data.Coherr.Sleep.betaBandPower.maxConfC_Y.^2,'-','color',colorSleep,'LineWidth',1);
semilogx(data.Coherr.All.betaBandPower.meanf,data.Coherr.All.betaBandPower.maxConfC_Y.^2,'-','color',colorAll,'LineWidth',1);
xline(1/10,'color','k');
xline(1/30,'color','k');
xline(1/60,'color','k');
title('Beta-band [13-30 Hz]')
ylabel('Coherence^2')
xlabel('Freq (Hz)')
title({'[S18k] Bilateral coherence','Beta-band [13-30 Hz]',''})
axis square
xlim([0.003,0.5])
ylim([0,1])
set(gca,'box','off')
ax11.TickLength = [0.03,0.03];
%% [S18l] Pearson's correlations between bilateral beta-band power during different arousal-states
ax12 = subplot(4,3,12);
scatter(CC_xInds*1,data.CorrCoef.Rest.betaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorRest,'jitter','on', 'jitterAmount',0.25);
hold on
e1 = errorbar(1,data.CorrCoef.Rest.betaBandPower.meanR,data.CorrCoef.Rest.betaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e1.Color = 'black';
e1.MarkerSize = 10;
e1.CapSize = 10;
scatter(CC_xInds*2,data.CorrCoef.Whisk.betaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorWhisk,'jitter','on', 'jitterAmount',0.25);
e2 = errorbar(2,data.CorrCoef.Whisk.betaBandPower.meanR,data.CorrCoef.Whisk.betaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e2.Color = 'black';
e2.MarkerSize = 10;
e2.CapSize = 10;
scatter(CC_xInds*3,data.CorrCoef.NREM.betaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorNREM,'jitter','on', 'jitterAmount',0.25);
e3 = errorbar(3,data.CorrCoef.NREM.betaBandPower.meanR,data.CorrCoef.NREM.betaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e3.Color = 'black';
e3.MarkerSize = 10;
e3.CapSize = 10;
scatter(CC_xInds*4,data.CorrCoef.REM.betaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorREM,'jitter','on', 'jitterAmount',0.25);
e4 = errorbar(4,data.CorrCoef.REM.betaBandPower.meanR,data.CorrCoef.REM.betaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e4.Color = 'black';
e4.MarkerSize = 10;
e4.CapSize = 10;
scatter(CC_xInds2*5,data.CorrCoef.Awake.betaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAwake,'jitter','on', 'jitterAmount',0.25);
e5 = errorbar(5,data.CorrCoef.Awake.betaBandPower.meanR,data.CorrCoef.Awake.betaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e5.Color = 'black';
e5.MarkerSize = 10;
e5.CapSize = 10;
scatter(CC_xInds3*6,data.CorrCoef.Sleep.betaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorSleep,'jitter','on', 'jitterAmount',0.25);
e6 = errorbar(6,data.CorrCoef.Sleep.betaBandPower.meanR,data.CorrCoef.Sleep.betaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e6.Color = 'black';
e6.MarkerSize = 10;
e6.CapSize = 10;
scatter(CC_xInds*7,data.CorrCoef.All.betaBandPower.meanRs,75,'MarkerEdgeColor','k','MarkerFaceColor',colorAll,'jitter','on', 'jitterAmount',0.25);
e7 = errorbar(7,data.CorrCoef.All.betaBandPower.meanR,data.CorrCoef.All.betaBandPower.stdR,'d','MarkerEdgeColor','k','MarkerFaceColor','k');
e7.Color = 'black';
e7.MarkerSize = 10;
e7.CapSize = 10;
title({'[S18l] Cortical Pearson''s corr. coef','Beta-band [13-30 Hz]',''})
ylabel({'Corr. Coefficient';'Left hem vs. Right hem'})
set(gca,'xtick',[])
set(gca,'xticklabel',[])
axis square
xlim([0,length(behavFields2) + 1])
ylim([-0.1,1])
set(gca,'box','off')
ax12.TickLength = [0.03,0.03];
%% save figure(s)
if strcmp(saveFigs,'y') == true
    dirpath = [rootFolder '\Summary Figures and Structures\'];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(summaryFigure,[dirpath 'FigS18']);
    set(summaryFigure,'PaperPositionMode','auto');
    print('-painters','-dpdf','-fillpage',[dirpath 'FigS18'])
    %% statistical diary
    diaryFile = [dirpath 'FigS18_Statistics.txt'];
    if exist(diaryFile,'file') == 2
        delete(diaryFile)
    end
    diary(diaryFile)
    diary on
    % delta statistical diary
    disp('======================================================================================================================')
    disp('[S18c] Generalized linear mixed-effects model statistics for delta-band corr. coef during Rest, Whisk, NREM, and REM')
    disp('======================================================================================================================')
    disp(deltaStats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest  delta P/P R: ' num2str(round(data.CorrCoef.Rest.deltaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Rest.deltaBandPower.stdR,2))]); disp(' ')
    disp(['Whisk delta P/P R: ' num2str(round(data.CorrCoef.Whisk.deltaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Whisk.deltaBandPower.stdR,2))]); disp(' ')
    disp(['NREM  delta P/P R: ' num2str(round(data.CorrCoef.NREM.deltaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.NREM.deltaBandPower.stdR,2))]); disp(' ')
    disp(['REM   delta P/P R: ' num2str(round(data.CorrCoef.REM.deltaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.REM.deltaBandPower.stdR,2))]); disp(' ')
    disp(['Awake delta P/P R: ' num2str(round(data.CorrCoef.Awake.deltaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Awake.deltaBandPower.stdR,2))]); disp(' ')
    disp(['Sleep delta P/P R: ' num2str(round(data.CorrCoef.Sleep.deltaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Sleep.deltaBandPower.stdR,2))]); disp(' ')
    disp(['All   delta P/P R: ' num2str(round(data.CorrCoef.All.deltaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.All.deltaBandPower.stdR,2))]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % theta statistical diary
    disp('======================================================================================================================')
    disp('[S18f] Generalized linear mixed-effects model statistics for theta-band corr. coef during Rest, Whisk, NREM, and REM')
    disp('======================================================================================================================')
    disp(thetaStats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest  theta P/P R: ' num2str(round(data.CorrCoef.Rest.thetaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Rest.thetaBandPower.stdR,2))]); disp(' ')
    disp(['Whisk theta P/P R: ' num2str(round(data.CorrCoef.Whisk.thetaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Whisk.thetaBandPower.stdR,2))]); disp(' ')
    disp(['NREM  theta P/P R: ' num2str(round(data.CorrCoef.NREM.thetaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.NREM.thetaBandPower.stdR,2))]); disp(' ')
    disp(['REM   theta P/P R: ' num2str(round(data.CorrCoef.REM.thetaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.REM.thetaBandPower.stdR,2))]); disp(' ')
    disp(['Awake theta P/P R: ' num2str(round(data.CorrCoef.Awake.thetaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Awake.thetaBandPower.stdR,2))]); disp(' ')
    disp(['Sleep theta P/P R: ' num2str(round(data.CorrCoef.Sleep.thetaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Sleep.thetaBandPower.stdR,2))]); disp(' ')
    disp(['All   theta P/P R: ' num2str(round(data.CorrCoef.All.thetaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.All.thetaBandPower.stdR,2))]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % alpha statistical diary
    disp('======================================================================================================================')
    disp('[S18i] Generalized linear mixed-effects model statistics for alpha-band corr. coef during Rest, Whisk, NREM, and REM')
    disp('======================================================================================================================')
    disp(alphaStats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest  alpha P/P R: ' num2str(round(data.CorrCoef.Rest.alphaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Rest.alphaBandPower.stdR,2))]); disp(' ')
    disp(['Whisk alpha P/P R: ' num2str(round(data.CorrCoef.Whisk.alphaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Whisk.alphaBandPower.stdR,2))]); disp(' ')
    disp(['NREM  alpha P/P R: ' num2str(round(data.CorrCoef.NREM.alphaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.NREM.alphaBandPower.stdR,2))]); disp(' ')
    disp(['REM   alpha P/P R: ' num2str(round(data.CorrCoef.REM.alphaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.REM.alphaBandPower.stdR,2))]); disp(' ')
    disp(['Awake alpha P/P R: ' num2str(round(data.CorrCoef.Awake.alphaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Awake.alphaBandPower.stdR,2))]); disp(' ')
    disp(['Sleep alpha P/P R: ' num2str(round(data.CorrCoef.Sleep.alphaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Sleep.alphaBandPower.stdR,2))]); disp(' ')
    disp(['All   alpha P/P R: ' num2str(round(data.CorrCoef.All.alphaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.All.alphaBandPower.stdR,2))]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    % beta statistical diary
    disp('======================================================================================================================')
    disp('[S18l] Generalized linear mixed-effects model statistics for beta-band corr. coef during Rest, Whisk, NREM, and REM')
    disp('======================================================================================================================')
    disp(betaStats)
    disp('----------------------------------------------------------------------------------------------------------------------')
    disp(['Rest  beta P/P R: ' num2str(round(data.CorrCoef.Rest.betaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Rest.betaBandPower.stdR,2))]); disp(' ')
    disp(['Whisk beta P/P R: ' num2str(round(data.CorrCoef.Whisk.betaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Whisk.betaBandPower.stdR,2))]); disp(' ')
    disp(['NREM  beta P/P R: ' num2str(round(data.CorrCoef.NREM.betaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.NREM.betaBandPower.stdR,2))]); disp(' ')
    disp(['REM   beta P/P R: ' num2str(round(data.CorrCoef.REM.betaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.REM.betaBandPower.stdR,2))]); disp(' ')
    disp(['Awake beta P/P R: ' num2str(round(data.CorrCoef.Awake.betaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Awake.betaBandPower.stdR,2))]); disp(' ')
    disp(['Sleep beta P/P R: ' num2str(round(data.CorrCoef.Sleep.betaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.Sleep.betaBandPower.stdR,2))]); disp(' ')
    disp(['All   beta P/P R: ' num2str(round(data.CorrCoef.All.betaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.All.betaBandPower.stdR,2))]); disp(' ')
    disp('----------------------------------------------------------------------------------------------------------------------')
    diary off
    %% organized for supplemental table
    % variable names
    ColumnNames_R = {'Rest','Whisk','NREM','REM','Awake','Sleep','All'};
    % delta-band R
    for aa = 1:length(ColumnNames_R)
        Delta_R_MeanStD{1,aa} = [num2str(round(data.CorrCoef.(ColumnNames_R{1,aa}).deltaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.(ColumnNames_R{1,aa}).deltaBandPower.stdR,2))]; %#ok<*AGROW>
    end
    % delta-band R p-values
    for aa = 1:length(ColumnNames_R)
        if strcmp(ColumnNames_R{1,aa},'Rest') == true
            Delta_R_pVal{1,aa} = {' '};
        else
            Delta_R_pVal{1,aa} = ['p < ' num2str(deltaStats.Coefficients.pValue(aa,1))];
        end
    end
    % theta-band R
    for aa = 1:length(ColumnNames_R)
        Theta_R_MeanStD{1,aa} = [num2str(round(data.CorrCoef.(ColumnNames_R{1,aa}).thetaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.(ColumnNames_R{1,aa}).thetaBandPower.stdR,2))]; %#ok<*AGROW>
    end
    % theta-band R p-values
    for aa = 1:length(ColumnNames_R)
        if strcmp(ColumnNames_R{1,aa},'Rest') == true
            Theta_R_pVal{1,aa} = {' '};
        else
            Theta_R_pVal{1,aa} = ['p < ' num2str(thetaStats.Coefficients.pValue(aa,1))];
        end
    end
    % alpha-band R
    for aa = 1:length(ColumnNames_R)
        Alpha_R_MeanStD{1,aa} = [num2str(round(data.CorrCoef.(ColumnNames_R{1,aa}).alphaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.(ColumnNames_R{1,aa}).alphaBandPower.stdR,2))]; %#ok<*AGROW>
    end
    % alpha-band R p-values
    for aa = 1:length(ColumnNames_R)
        if strcmp(ColumnNames_R{1,aa},'Rest') == true
            Alpha_R_pVal{1,aa} = {' '};
        else
            Alpha_R_pVal{1,aa} = ['p < ' num2str(alphaStats.Coefficients.pValue(aa,1))];
        end
    end
    % beta-band R
    for aa = 1:length(ColumnNames_R)
        Beta_R_MeanStD{1,aa} = [num2str(round(data.CorrCoef.(ColumnNames_R{1,aa}).betaBandPower.meanR,2)) ' +/- ' num2str(round(data.CorrCoef.(ColumnNames_R{1,aa}).betaBandPower.stdR,2))]; %#ok<*AGROW>
    end
    % beta-band R p-values
    for aa = 1:length(ColumnNames_R)
        if strcmp(ColumnNames_R{1,aa},'Rest') == true
            Beta_R_pVal{1,aa} = {' '};
        else
            Beta_R_pVal{1,aa} = ['p < ' num2str(betaStats.Coefficients.pValue(aa,1))];
        end
    end
    %% save table data
    if isfield(AnalysisResults,'CorrCoef') == false
        AnalysisResults.CorrCoef = [];
    end
    if isfield(AnalysisResults.CorrCoef,'deltaBandPower') == false
        AnalysisResults.CorrCoef.columnNames = ColumnNames_R;
        AnalysisResults.CorrCoef.deltaBandPower.meanStD = Delta_R_MeanStD;
        AnalysisResults.CorrCoef.deltaBandPower.p = Delta_R_pVal;
        AnalysisResults.CorrCoef.thetaBandPower.meanStD = Theta_R_MeanStD;
        AnalysisResults.CorrCoef.thetaBandPower.p = Theta_R_pVal;
        AnalysisResults.CorrCoef.alphaBandPower.meanStD = Alpha_R_MeanStD;
        AnalysisResults.CorrCoef.alphaBandPower.p = Alpha_R_pVal;
        AnalysisResults.CorrCoef.betaBandPower.meanStD = Beta_R_MeanStD;
        AnalysisResults.CorrCoef.betaBandPower.p = Beta_R_pVal;
        cd(rootFolder)
        save('AnalysisResults.mat','AnalysisResults')
    end
end

end
