function  [BMA] = SG_report_H(results,H)

options = [results(1,:).run_options];
models_H_idx = find(ismember([options.dynamics],[0 H])) ;

results = results(:,models_H_idx);

for iS=1:size(results,1)
    [BMA.subject(iS).posterior] = VBA_BMA({results(iS,:).posterior},[results(iS,:).F]);
    [BMA.subject(iS).effects]   =  priorPrettifyer(results(1,1).out.options.inG.phi,BMA.subject(iS).posterior.muPhi);
end

parameters_names = {'choice_effect','success_effect','force_effect','drift_effect','choice_rho', 'success_rho','force_rho'} ;

ste = @(x) std(x)/sqrt(numel(x));

for iF = 1:numel(parameters_names)
    try
        eff = struct.extract([BMA.subject.effects],parameters_names{iF});
        [~,p]=ttest(eff);
        BMA.effectsBySubject.(parameters_names{iF}) = eff;
        BMA.effects.(parameters_names{iF}) = mean(eff);
        BMA.effects_ste.(parameters_names{iF}) = ste(eff);
        BMA.significance.(parameters_names{iF}) = p;
    end
end

FF = reshape([results.F],size(results,1),numel(models_H_idx))';

% model comparison
test_list = {'dynamics', 'choiceUpdate', 'successUpdate', 'forceUpdate', 'driftUpdate'};
for iT = 1:numel(test_list)
    s=struct.getFamilies([results(1,:).run_options],test_list{iT});
    s.verbose=0;
    s.DisplayWin=0;
    [~,o]=VBA_groupBMC(FF,s);
    MC.(test_list{iT}).Ef = o.families.Ef;
    MC.(test_list{iT}).ep = o.families.ep;
end


effect_list = {'dynamics', 'choiceUpdate', 'successUpdate', 'forceUpdate', 'driftUpdate'};


fprintf('\n =========================================================================================\n')
fprintf('  SUBJECT ANALYSIS\n')
fprintf(' =========================================================================================\n\n')


fprintf('%+16s | amplitude \t   |   p    |  h  |   Ef   |  xp   |  H  |\n','effect')
fprintf('   -----------------------------------------------------------------------\n')


for iE = 1:numel(effect_list)
    effect = effect_list{iE};

    % display results
    matches=regexp(effect,'(?<effect>.*)Update','names');
    if ~isempty(matches)
       name_effect = [matches.effect '_effect'];
    end
    try
          value = BMA.effects.(name_effect);
          value_ste = BMA.effects_ste.(name_effect);
          p = BMA.significance.(name_effect);
          h = p<.05; 
    end


    ep = MC.(effect).ep;
    Ef = MC.(effect).Ef;
    winner = find(ep==max(ep)); 
    
    if ~isempty(matches)
    fprintf('%+16s | %+4.3f (%+4.3f) | %5.4f |  %d  |  %3.2f  | %3.2f  | H%d  |\n', ...
            effect,   value  , value_ste ,   p       , h , Ef(winner)       ,  ep(winner)       ,winner-1) ;
    else
       fprintf('%+16s | \t\t   | \t    |     |  %3.2f  | %3.2f  | H%d  |\n', ...
            effect,                             Ef(winner)       ,  ep(winner)       ,winner-1) ;
    end
end
fprintf('   -----------------------------------------------------------------------\n\n')


%%

if ~results(1).run_options.restricted 
    

effect_list = {'choice_rho', 'success_rho','force_rho'};


fprintf('\n =========================================================================================\n')
fprintf('  SUBJECT ANALYSIS\n')
fprintf(' =========================================================================================\n\n')


fprintf('%+16s | amplitude \t   |   p    |  h  |   Ef   |  xp   |  H  |\n','effect')
fprintf('   -----------------------------------------------------------------------\n')


for iE = 1:numel(effect_list)
    effect = effect_list{iE};

    % display results
    name_effect = effect;
    try
          value = BMA.effects.(name_effect);
          value_ste = BMA.effects_ste.(name_effect);
          p = BMA.significance.(name_effect);
          h = p<.05; 
    end
  
    fprintf('%+16s | %+4.3f (%+4.3f) | %5.4f |  %d  |\n', ...
            effect,   value  , value_ste ,   p       , h ) ;
   
end
fprintf('   -----------------------------------------------------------------------\n\n')

end
