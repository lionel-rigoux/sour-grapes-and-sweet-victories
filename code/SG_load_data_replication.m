function [results]=load_data_replication(version)

% Define the directory in which data could be found and get subject list
datadir = sprintf('../data/replication_%s/',version);

subjectList = dir([datadir filesep 'sub*']);
nSubject = length(subjectList);


nRating = 3;
nForce = 2;
nItem = 150;

for iSubject=1:nSubject
     
    %% Keep subject name and iSubject
    results(iSubject).subjectName = subjectList(iSubject).name;
    results(iSubject).subject = iSubject ;
    
    %% Load and organize rating data
    tempListFile = dir([datadir filesep subjectList(iSubject).name filesep 'value*' ]); % Get file list for that subject

    % Get data
    for iFile = 1:nRating
        temp = load([datadir filesep subjectList(iSubject).name filesep tempListFile(iFile).name]);
        allItemRating.allRating(iFile, temp.tr.itemid)   = temp.tr.value;
        allItemRating.allOrder(iFile, temp.tr.itemid)    = 1:length(temp.tr.value);
        allItemRating.allRTrating(iFile, temp.tr.itemid) = temp.tm.rtvalue;
    end
%    results(iSubject).allItemRating = allItemRating;
     
    %% Get calibration data
    tempListFile = dir([datadir filesep subjectList(iSubject).name filesep 'calmains1*' ]); % Get file list for that subject
    temp = load([datadir filesep subjectList(iSubject).name filesep tempListFile(1).name]);
    Fmax = temp.tr.fmax(1);
    
    %% Load and organize force data
    tempListFile = dir([datadir filesep subjectList(iSubject).name filesep 'effpair*' ]); % Get file list for that subject
    
    % Initialize the structure
    allItemForce.allAcceptOrNot   = NaN(nForce, nItem);
    allItemForce.allChoice        = NaN(nForce, nItem);
    allItemForce.allSuccess       = NaN(nForce, nItem);
    allItemForce.allForcePeak     = NaN(nForce, nItem);
    allItemForce.allForceSum      = NaN(nForce, nItem);
    allItemForce.allForcePeakOrth = NaN(nForce, nItem);
    allItemForce.allForceSumOrth  = NaN(nForce, nItem);
    allItemForce.allOrder         = NaN(nForce, nItem);
    allItemForce.target           = NaN(nForce, nItem);
    allItemForce.fatigue          = NaN(nForce, nItem);
    allItemForce.allRTeffort      = NaN(nForce, nItem);
    
    % Get data
    for iFile = 1:nForce
        temp = load([datadir filesep subjectList(iSubject).name filesep tempListFile(iFile).name]);
        
        % trial details
        allItemForce.allOrder(iFile, temp.tr.ID)     = 1:length(temp.tr.acceptornot);
        allItemForce.target(iFile, temp.tr.ID)       = temp.tr.forceline/100;
        
        % did the subject actively clicked the button
        allItemForce.allAcceptOrNot(iFile, temp.tr.ID) = temp.tr.acceptornot | temp.tr.success; 
        
        % did the subject reached the target
        allItemForce.allSuccess(iFile, temp.tr.ID)     = temp.tr.success;
        
        % old stle choice
        switch version
          case 'v2'
                allItemForce.allChoice(iFile, temp.tr.ID) = (temp.tr.acceptornot | temp.tr.success) ;% & (max(temp.gr.grip)>0.20) ;
          case 'v3'
                allItemForce.allChoice(iFile, temp.tr.ID) = (temp.tr.acceptornot | temp.tr.success) & (max(temp.gr.grip)>0.20) ;
        end
        
        % did the subject give up
        allItemForce.allSkip(iFile, temp.tr.ID) = temp.tr.skip; 
        
        % force exerted 
        allItemForce.allForcePeak(iFile, temp.tr.ID) = max(temp.gr.grip);
        allItemForce.allForceSum(iFile, temp.tr.ID)  = nansum(temp.gr.grip); 
        allItemForce.allChoice(iFile,isnan(allItemForce.allForcePeak(iFile,:))) = NaN;
        
        % Duration of presentation
        endChoiceTime = temp.tm.feedback;
        endChoiceTime(endChoiceTime==0) = temp.tm.choice_made(endChoiceTime==0);
        allItemForce.allRTeffort(iFile, temp.tr.ID) = endChoiceTime - temp.tm.choice_onset;
           
        % force orthogonalized wrt to success
        temp=[ones(nItem, 1) allItemForce.allSuccess(iFile,:)' allItemForce.allForcePeak(iFile,:)'];
        temp=spm_orth(temp(allItemForce.allChoice(iFile,:)==1,:));
        allItemForce.allForcePeakOrth(iFile, allItemForce.allChoice(iFile,:)==1) = temp(:, end);
        temp=[ones(nItem, 1) allItemForce.allSuccess(iFile,:)' allItemForce.allForceSum(iFile,:)'];
        temp=spm_orth(temp(allItemForce.allChoice(iFile,:)==1,:));
        allItemForce.allForceSumOrth(iFile, allItemForce.allChoice(iFile,:)==1) = temp(:, end);
        
    end
    isNan = isnan(allItemForce.allOrder(1,:));
        
    % compute cumulative time of exposition
    allItemRating.cumulativeExpositionTimeDuringRating(1,:) = 0 * allItemRating.allRTrating(1,:);
    allItemForce.cumulativeExpositionTimeDuringEffort(1,:)  = allItemRating.allRTrating(1,:);
    allItemRating.cumulativeExpositionTimeDuringRating(2,:) = allItemForce.cumulativeExpositionTimeDuringEffort(1,:)  + allItemForce.allRTeffort(1,:);
    allItemForce.cumulativeExpositionTimeDuringEffort(2,:)  = allItemRating.cumulativeExpositionTimeDuringRating(2,:) + allItemRating.allRTrating(2,:);
    allItemRating.cumulativeExpositionTimeDuringRating(3,:) = allItemForce.cumulativeExpositionTimeDuringEffort(2,:)  + allItemForce.allRTeffort(2,:);
    
    
    %% Store keeping old names and format for compatibility
    results(iSubject).rating	     = allItemRating.allRating(:,isNan==0);
    results(iSubject).target	     = allItemForce.target(:,isNan==0);
    results(iSubject).force_max	     = allItemForce.allForcePeak(:,isNan==0);
    results(iSubject).force_max_ort  = allItemForce.allForcePeakOrth(:,isNan==0);
    results(iSubject).force_tot	     = allItemForce.allForceSum(:,isNan==0);
    results(iSubject).force_tot_ort  = allItemForce.allForceSumOrth(:,isNan==0);
    results(iSubject).choice	     = allItemForce.allChoice(:,isNan==0);
    results(iSubject).success	     = allItemForce.allSuccess(:,isNan==0);
    results(iSubject).order	         = allItemForce.allOrder(:,isNan==0);
    results(iSubject).RTeffort	     = allItemForce.allRTeffort(:,isNan==0);
    results(iSubject).RTrating	     = allItemRating.allRTrating(:,isNan==0);
    results(iSubject).cumulativeExpositionTimeDuringRating = allItemRating.cumulativeExpositionTimeDuringRating(:,isNan==0);
    results(iSubject).cumulativeExpositionTimeDuringEffort = allItemForce.cumulativeExpositionTimeDuringEffort(:,isNan==0);
    
    %% Store all results including rating-only items
    results(iSubject).compatibility = struct;
    results(iSubject).compatibility.allItemRating = allItemRating;
    results(iSubject).compatibility.allItemForce = allItemForce;
    
end

