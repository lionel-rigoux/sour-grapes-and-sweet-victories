data = SG_load_data();


%% model based effects
   
for iSub = 1:numel(data)
     parfor iMod = 1:30
         SG_invert_subjects(iSub,iMod,0,1);
     end
     parfor iMod = 1:44
         SG_invert_subjects(iSub,iMod,0,0);
     end
end

%% show results

idx_good = setdiff(1:numel(data), SG_exclude());

% summarise
[grand_summary.restricted.subject, grand_summary.restricted.results]=SG_analyse('subjects',1,idx_good);
[grand_summary.full.subject, grand_summary.full.results]=SG_analyse('subjects',0,idx_good);
 
% show effects
grand_summary.full.subject.BMA.effects % average parameters
grand_summary.full.subject.BMA.significance % corresponding pvalue (t-test grp level)

SG_report(grand_summary.full)

%% model free

results=SG_plot_model_free(data(idx_good));
SG_plot_sanity_checks(data(idx_good));


%% bootstrap
N = 100 ;


SG_simulate_bootstrap(N,1,idx_good) ;
SG_simulate_bootstrap(N,0,idx_good) ;

pool_1 = factorial_struct('s',1:N,'k',1:30);
parfor i=1:numel(pool_1)
        SG_invert_subjects(pool_1(i).s,pool_1(i).k,true,1)
end
clear pool_1

pool_0 = factorial_struct('s',1:N,'k',1:44);
parfor i=1:numel(pool_0)
        SG_invert_subjects(pool_0(i).s,pool_0(i).k,true,0)
end
clear pool_0

grand_summary.restricted.bootstrap = SG_analyse_bootstrap(N,1) ;
grand_summary.full.bootstrap = SG_analyse_bootstrap(N,0) ;

%% Parameters

SG_plot_parameters(grand_summary);