function [results]=load_data_v1()

% addpath(genpath('~/Code/VBA-toolbox'))
% addpath(genpath('~/Code/army-knife'))

% load raw data
load('../data/replication_v1/rv_fv1.mat')
load('../data/replication_v1/forceprop.mat')

for s=1:18 % lop over subjects
    
    % initialize matrices
    ratings_s    = zeros(120,3);
    RT_ratings_s = zeros(120,3);
    forces_max_s = zeros(120,2);
    forces_tot_s = zeros(120,2);
    forces_dur_s = zeros(120,2);
    forces_tot_orth_s = zeros(120,2);
    targets_s = zeros(120,2);
    choices_s = zeros(120,2);
    success_s = zeros(120,2);
    order_s = zeros(90,2);
    fatigue_s = zeros(120,2);
    
    %%
    Fmax(Fmax>1.5)=NaN;
    
    % rearrange data by item index
    for i=1:3
        ratings_s(rating_item(:,s,i),i)    = ratings(:,s,i);
        RT_ratings_s(rating_item(:,s,i),i) = rtvalue(:,s,i);
    end
    
    for i=1:2
        
        targets_s(force_item(:,s,i),i) = force_level(:,s,i);
        forces_max_s(force_item(:,s,i),i) = Fmax(:,s,i);
        forces_tot_s(force_item(:,s,i),i) = Ftot(:,s,i);
        forces_dur_s(force_item(:,s,i),i) = Fdur(:,s,i)/32;
        choices_s(:,i) = +(forces_max_s(:,i) > .2);
        success_s(force_item(:,s,i),i) = success(:,s,i);
        [~,order_temp] =  sort(force_item(:,s,i)) ;
        order_s(:,i) = (i-1)+order_temp/90 ;
        fatigue_s(force_item(:,s,i),i) = cumsum(maxF(:,s,i)) ;
        % force orthogonalized wrt to success
        choices_temp = choices_s(:,i);
        success_temp = success_s(:,i);

        F_temp       = forces_max_s(:,i) ;
        nanidx = find(~isnan(F_temp));
        
        orth_temp = spm_orth([ones(numel(choices_temp(nanidx)),1) choices_temp(nanidx) success_temp(nanidx) F_temp(nanidx)]);
        F_orth_temp = orth_temp(:,end);
        forces_max_orth_s(nanidx,i) = F_orth_temp;
        F_temp       = forces_tot_s(:,i) ;
        orth_temp = spm_orth([ones(numel(choices_temp),1) choices_temp success_temp F_temp]);
        F_orth_temp = orth_temp(:,end);
        forces_tot_orth_s(:,i) = F_orth_temp;
    end
    fatigue_s(:,2) = fatigue_s(:,2) + max(fatigue_s(:,1));
    
    % find items to keep
    used = sort(rating_item(find(rating_used(:,s,1)==1),s,1));
    
    % save results
    results(s).subjectName = ['s_' num2str(s)];
    results(s).subject	= s ;
    results(s).rating	= ratings_s(used,:)' ;
    results(s).target	= repmat(targets_s(used,1)',2,1) ;
    results(s).force_max	 = forces_max_s(used,:)' ;
    results(s).force_max_ort = forces_max_orth_s(used,:)' ;
    results(s).force_tot	 = forces_tot_s(used,:)' ;
    results(s).force_tot_ort = forces_tot_orth_s(used,:)' ;
    results(s).choice	= choices_s(used,:)' ;
    results(s).success	= success_s(used,:)' ;
    results(s).order	= order_s' ;
    results(s).RTeffort	    = forces_dur_s(used,:)' ;
    results(s).RTrating	    = RT_ratings_s(used,:)' ;
    results(s).cumulativeExpositionTimeDuringRating(1,:) = 0 * results(s).RTrating(1,:);
    results(s).cumulativeExpositionTimeDuringEffort(1,:) = results(s).RTrating(1,:);
    results(s).cumulativeExpositionTimeDuringRating(2,:) = results(s).cumulativeExpositionTimeDuringEffort(1,:) + results(s).RTeffort(1,:);
    results(s).cumulativeExpositionTimeDuringEffort(2,:) = results(s).cumulativeExpositionTimeDuringRating(2,:) + results(s).RTrating(2,:);
    results(s).cumulativeExpositionTimeDuringRating(3,:) = results(s).cumulativeExpositionTimeDuringEffort(2,:) + results(s).RTeffort(2,:);
    results(s).compatibility = struct;
%     results(s).fatigue  = fatigue_s(used,:)' ;
     
end

