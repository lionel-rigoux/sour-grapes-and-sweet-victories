function gx=SG_g_model(~,P,u_t,inG)
%% ___________________________________________________________________________
% model of behaviour

% = inputs
% *************************************************************************
item_idx  = u_t(1);
target    = u_t(2:3);

y_choice  = u_t(4:5);
y_success = u_t(6:7);
y_force   = u_t(8:9);

o_choice  = u_t(10:11);
o_success = u_t(12:13);
o_force   = u_t(14:15);

run_options = inG.run_options;

% = parameters
% *************************************************************************
% + ratings
value0          = P(inG.phi.value0(item_idx));
% + effects
choice_effect   = P(inG.phi.choice_effect);
success_effect  = P(inG.phi.success_effect);
force_effect    = P(inG.phi.force_effect);
drift_effect    = P(inG.phi.drift_effect);
% + choices
choice_rho      = P(inG.phi.choice_rho);
choice_eta      = P(inG.phi.choice_eta);
u_rest          = P(inG.phi.choice_uRest);
choice_beta     = exp(P(inG.phi.choice_beta));
% + success
suc_0           = P(inG.phi.success_0);
success_eta     = P(inG.phi.success_eta);
success_rho     = P(inG.phi.success_rho);
success_beta    = exp(P(inG.phi.success_beta));
% + force
force_margin    = P(inG.phi.force_margin);
force_rho       = P(inG.phi.force_rho);
force_rate      = P(inG.phi.force_rate);


% = hiden values and predictors
% *************************************************************************

% $$ first part
value = value0 ;

ratings   = zeros(3,1);
choices   = zeros(2,1);
successes = zeros(2,1);
forces    = zeros(2,1);

% + initial rating
ratings(1) = value;

for i=1:2 % for each 'session'
    
    if run_options.dynamics == 3
        value_force = value;
    else
        value_force = value0;
    end
    
    incentive = value/100;
    incentive_force = value_force/100;
    
    % + choice
    utility = choice_rho*incentive + choice_eta*target(i) - u_rest;
    choices(i) = sgm(utility/choice_beta);
    
     % + successes
    intention = suc_0 + success_eta*target(i) + success_rho*incentive;
    successes(i) =  sgm(intention/success_beta);
    
    % + force
    forces(i) = force_margin + force_rate*target(i) + force_rho*incentive_force;  
    if y_choice(i)==0 || y_success(i) == 0
        forces(i) = 0;
    end
          
    effect = choice_effect *o_choice(i)                         ...
           + success_effect *o_success(i) * (y_choice(i) >0)    ...
           + force_effect   *o_force(i)   * (y_success(i)>0) ;  
        
     drift =    drift_effect * run_options.driftUpdate  ; 

    % dynamics = 1 : local update / dynamics = 2,3 : cumulative
    if run_options.dynamics == 0
        % do nothing
    elseif run_options.dynamics == 1
        % drift is alyas there
        value0 = value0 + drift ;
        % update only affects next trail
        value  = value0 + effect ;
    else
        % update is permanent
        value  = value  + effect + drift ;
    end
    
    % + rating
    ratings(i+1) = value;
    
end

% = storage
% *************************************************************************
gx = zeros(7,1);
gx(1:3) = ratings;
gx(4:5) = choices;
gx(6:7) = successes;
gx(8:9) = forces ;

end