% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%  predict ratings, choices and success evolution as a function of choices 
%  and successes plus a constant drift
% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

function results = SG_invert(data,run_options) 
%% IN:
% + data: 
%       data structure (see SG_load_data for details)
% + run_options:
%       structure that defines the inverted model. Fieleds are:
%       * dynamics:
%           1 -> local update
%           2 -> update ratings only
%           3 -> update ratings AND force values
%       * choiceUpdate:
%           0, 1 -> determines if choices affect the item value
%       * successUpdate:
%           0, 1 -> determines if success affect the item value
%       * forceUpdate:
%           0, 1 -> determines if force affect the item value
%       * driftUpdate:
%           0, 1 -> determines if a constant drift affect the item value
%%

% *************************************************************************
% check inputs
if nargin<2
    run_options = struct();
end
run_options=VBA_check_struct(run_options, ... % full model by default
    'dynamics'      , 3  , ...
    'choiceUpdate'  , 1  , ...
    'successUpdate' , 1  , ...
    'forceUpdate'   , 1  , ...
    'driftUpdate'   , 1  , ...   
    'restricted'    , 0    ...
    );
 
% *************************************************************************
% inversion
 
    
    [posterior,out] = SG_invert_sub(data,run_options);
  

    results              = struct();
    results.data         = data;
    results.run_options  = run_options;
    results.posterior    = posterior;
    results.out          = out;
    results.F            = out.F ;
    results.effects      = priorPrettifyer(out.options.inG.phi,posterior.muPhi);
    results.hyper.rating = posterior.b_sigma(1)./posterior.a_sigma(1) ;
    results.hyper.force  = posterior.b_sigma(2)./posterior.a_sigma(2) ;
         
    
end
%% ___________________________________________________________________________
% inversion routine: compute the posterior given a subject-wise set of 
% data (results) and a vector of parameters flags (switches)

function [posterior,out]=SG_invert_sub(data,run_options)
   
   % prepare data
   % ----------------------------------------------------------------------
   
   % rating
   rating = data.rating;
   
   % choice
   choice = data.choice ;
   
   % success
   success = data.success;
   success(choice==0) = NaN;
   
   % force  
   force = data.force_max; % data.force_tot
   force(choice==0 | success==0) = NaN;
   
   % observations
   y = [rating; 
        choice;
        success;
        force];
    
   % prepare inputs
   % ----------------------------------------------------------------------
   
   % choice
   % transform choice data into +1/-1 regressors (unchose/chosen)
   choice_orth = 2*choice-1; 
   
   % success
   % transform success data into +1/0/-1 regressors (failes/unchose/success) 
   success_orth = 2*success-1;
   success_orth(choice==0) = 0;
   
   % force
   % force is orthogonalized and normalized
   force_orth = reshape(nanzscore(vec(force)),2,90);
   force_orth(isnan(force_orth)) = 0;
   
   % inputs
   % task
   u( 1    ,:) = 1:90         ;  % item number (for indexing hidden value estimate) 
   u( 2: 3 ,:) = data.target  ;  % required force
   % observed behaviour
   u( 4: 5 ,:) = choice       ;                  
   u( 6: 7 ,:) = success      ;  
   u( 8: 9 ,:) = force        ;  
   % orthogonalized regressors
   u(10:11 ,:) = choice_orth  ;         
   u(12:13 ,:) = success_orth ;   
   u(14:15 ,:) = force_orth   ;  
   

   % model definition   
   % ----------------------------------------------------------------------
   options.f_fname =  [];
   options.g_fname =  @SG_g_model;
  
   %priors
   [priors.muPhi,priors.SigmaPhi, phi] = priorUglyfier(...
       'value0'         , 50*ones(1,90), 850*ones(1,90), ...
       ...
       'choice_effect'  , 0       , 2 * run_options.choiceUpdate    , ...
       'success_effect' , 0       , 2 * run_options.successUpdate   , ...
       'force_effect'   , 0       , 2 * run_options.forceUpdate     , ...
       'drift_effect'   , 0       , 2 * run_options.driftUpdate     , ...
       ...
       'choice_rho'     , 0       , 5   , ... 
       'choice_eta'     , 0       , 5   , ... 
       'choice_uRest'   , 0       , 5   , ...
       'choice_beta'    , log(1)  , 0   , ...
       ...
       'success_rho'    , 0       , 5   , ...  
       'success_eta'    , 0       , 5   , ...  
       'success_0'      , 0       , 5   , ...
       'success_beta'   , log(1)  , 0   , ...
       ...
       'force_margin'   , 0       , 0.5 , ...  
       'force_rho'      , 0       , 5   , ...  
       'force_rate'     , 1       , 5     ...  
       );  
   
    [a(1),b(1)]=getHyperpriors(y(1:3,:), 0.70, 0.95);
    [a(2),b(2)]=getHyperpriors(y(8:9,:), 0.85, 0.95);
   
   priors.a_sigma=a;
   priors.b_sigma=b;
       
   if run_options.restricted
       idx = phi.choice_rho : phi.force_rate;
       priors.SigmaPhi(idx,idx)=0;
   end
   
   options.priors = priors;    
    
   % dimensions
   options.dim = struct( ...
            'n'         , 0                   ,...   % static           
            'p'         , 9                   ,...   % 3 sessions of ratings + 2 choices + 2 success + 2 forces               
            'n_theta'   , 0                   ,...   % static             
            'n_phi'     , numel(priors.muPhi) ,...   % initial values + update parameters       
            'n_t'       , 90                   ...   % items   
    );
          
   % fancy options
   options.verbose         = 0;  % Command windows outputs ?
   options.DisplayWin      = 0;  % Show the results ?
   
   % multisource
   % + ratings
   options.sources(1).type = 0;
   options.sources(1).out = 1:3; 
   % + choice
   options.sources(2).type = 1;
   options.sources(2).out = 4:5;
   % + success
   options.sources(3).type = 1;
   options.sources(3).out = 6:7;
   % + force
   options.sources(4).type = 0;
   options.sources(4).out = 8:9;
   
   % pass on options
   options.inG.phi = phi;
   options.inG.run_options = run_options;
   
   options.isYout = isnan(y);
   
   % restrict to ratings
   if run_options.restricted
       options.isYout(4:end,:) = 1;
   end
   
   % model inversion  
   [posterior,out] = VBA_NLStateSpaceModel(y,u,options.f_fname,options.g_fname,options.dim,options);
     
end





