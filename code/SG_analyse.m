function [summary,results]=SG_analyse(data_type,restricted,subject_list)

%  load all data
% *************************************************************************

switch data_type
    case 'subjects'
        data_dir = dir(sprintf('../results/subjects/data_s*_r%d.mat',restricted));
    case 'bootstrap'
        data_dir = [];
        for iS=1:numel(subject_list)
            data_dir = [data_dir; dir(sprintf('../results/bootstrap/data_s%03d*.mat',subject_list(iS))) ] ;
        end
end

for i=1:numel(data_dir)
    l=load(sprintf('../results/%s/%s',data_type,data_dir(i).name));
    results_all(i) = l.results;
end

nSujets = numel(unique(struct.extract([results_all.run_options],'iSuj')));

% reshape
results_all = struct.sort(results_all,{'iSuj'});
results = reshape(results_all,numel(results_all)/nSujets,nSujets)' ;

if strcmp(data_type,'subjects') & exist('subject_list','var')
    results = results(subject_list,:);
end

%  summarize effects
% *************************************************************************

for iVer = 1:size(results,2) % for each model
    summary.version(iVer).run_options = results(1,iVer).run_options ;
    results_version = results(:,iVer);
    posteriors = [results_version.posterior];
    avg_post =  mean([posteriors.muPhi],2);
    summary.version(iVer).effects = priorPrettifyer(results(1,iVer).out.options.inG.phi,avg_post);
    
    parameters_names = fieldnames(summary.version(iVer).effects);
    for iF = 1:numel(parameters_names)
        [~,p]=ttest(struct.extract([results(:,iVer).effects],parameters_names{iF}));
        summary.version(iVer).significance.(parameters_names{iF}) = p;
    end
    
    summary.FF(iVer,:) = [results(:,iVer).F] ;
end




% model comparison
test_list = {'dynamics','choiceUpdate','successUpdate','forceUpdate','driftUpdate'};
for iT = 1:numel(test_list)
    s=struct.getFamilies([results(1,:).run_options],test_list{iT});
    s.verbose=0;
    s.DisplayWin=0;
    [~,o]=VBA_groupBMC(summary.FF,s);
    summary.MC.(test_list{iT}).Ef = o.families.Ef;
    summary.MC.(test_list{iT}).ep = o.families.ep;
end


% BMA approach

for iS=1:size(results,1)
    [summary.BMA.subject(iS).posterior] = VBA_BMA({results(iS,:).posterior},[results(iS,:).F]);
    [summary.BMA.subject(iS).effects]   =  priorPrettifyer(results(1,1).out.options.inG.phi,summary.BMA.subject(iS).posterior.muPhi);
end

for iF = 1:numel(parameters_names)
    eff = struct.extract([summary.BMA.subject.effects],parameters_names{iF});
    [~,p]=ttest(eff);
    summary.BMA.effects.(parameters_names{iF}) = mean(eff);
    summary.BMA.significance.(parameters_names{iF}) = p;
end
