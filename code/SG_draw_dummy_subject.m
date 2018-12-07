function [dummy_subject] = SG_draw_dummy_subject(N,restricted,idx)
% =======================================================================

[summary_subjects,results_subjects]=SG_analyse('subjects',restricted,idx);
labeller = results_subjects(1).out.options.inG.phi;

% =======================================================================
% extract observation parameters
BMA_posteriors = [summary_subjects.BMA.subject.posterior];
phi = [BMA_posteriors.muPhi] ;

% reorder hidden values to insure consistency accross subject
for iS= 1:numel(idx), phi(1:90,iS) = sort(phi(1:90,iS)); end

% store 2 first moments
group_avg.muPhi = mean(phi,2);
group_avg.SigmaPhi = cov(phi');

% =======================================================================
% extract hyperparameters

a_sigma = vertcat(BMA_posteriors.a_sigma);
b_sigma = vertcat(BMA_posteriors.b_sigma);

% compute average moments
sigma_m = mean(a_sigma./b_sigma) ;
sigma_v = mean(a_sigma./b_sigma.^2) ;

% translate into gamma parameters
group_avg.b_sigma = sigma_m ./ sigma_v;
group_avg.a_sigma = sigma_m .* group_avg.b_sigma;


for iS=1:N
% =======================================================================
% draw random parameter vector
phi = mvnrnd(group_avg.muPhi,group_avg.SigmaPhi) ;

% check value constitencies
values = sort(phi(labeller.value0));
values(values <  0 ) =  0  ;
values(values > 100) = 100 ;
phi(labeller.value0) = values ;

% switch off cognitive dissonance effect
phi(labeller.choice_effect ) = 0 ; 
phi(labeller.success_effect) = 0 ; 
phi(labeller.force_effect  ) = 0 ; 

% draw measurment noise
prec = gamrnd(group_avg.a_sigma,1./group_avg.b_sigma) ;
sigma = 1./sqrt(prec);

% =======================================================================
% store all results
dummy_subject(iS).phi = phi ;
dummy_subject(iS).sig_r = sigma(1) ;
dummy_subject(iS).sig_f = sigma(2) ;
dummy_subject(iS).labeller = labeller ;


end
