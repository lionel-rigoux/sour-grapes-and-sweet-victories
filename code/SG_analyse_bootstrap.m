function summary=SG_analyse_bootstrap(N,restricted)

if nargin==0
    N = 1000 ;
end

%nDS = numel(dir(sprintf('../results/bootstrap/data*_r%d.mat',restricted)))/45 ;
nDS = 100;%
%effect_types = {'dynamics','choiceUpdate','successUpdate','forceUpdate'};

% for each random group
parfor iB=1:N
    
    rng('shuffle');
        
    % draw 18 random subjects
    dummy_group = randperm(nDS,18);
    
    %load data
    [summary_group]=SG_analyse('bootstrap',restricted,dummy_group);
  
    summary_sub(iB) = summary_group  ;
     
end

summary.all = summary_sub;

% for iT=1:numel(effect_types)
%     
%     MC = [summary_sub.MC];
%     
%     Ef = struct.extract([MC.(effect_types{iT})],'Ef');
%     xp = struct.extract([MC.(effect_types{iT})],'xp');
%     
%     summary.(effect_types{iT}).Ef_mean = mean(Ef);
%     summary.(effect_types{iT}).Ef_std  = std(Ef);
%     
%     summary.(effect_types{iT}).xp_mean = mean(xp);
%     summary.(effect_types{iT}).xp_std  = std(xp);
%     
% end
% 
% effect_param = fields(summary_sub(1).BMA.significance);
% for iT=1:numel(effect_param)
%         BMA = [summary_sub.BMA];
% 
%     pp = struct.extract([BMA.significance],effect_param{iT}) ;
%     summary.(effect_param{iT}).p_mean = mean(pp);
%     summary.(effect_param{iT}).p_std  = std(pp);
%     
%     val = struct.extract([BMA.effects],effect_param{iT}) ;
%     summary.(effect_param{iT}).val_mean = mean(val);
%     summary.(effect_param{iT}).val_std  = std(val);
% end




