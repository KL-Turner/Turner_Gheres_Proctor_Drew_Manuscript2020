animalIDs = {'T121','T122','T123'};
rootFolder = cd;
for aa = 1:length(animalIDs)
    animalID = animalIDs{1,aa};
    animalDir = [rootFolder '\' animalID '\Bilateral Imaging\'];
    cd(animalDir)
    StageTwoProcessing_IOS_Manuscript2020()
    cd(rootFolder)
end