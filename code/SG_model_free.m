function [results, accuracy, delta]=SG_model_free(data)

warning off

% =========================================================================
% effect of ratings on force behaviour
% =========================================================================

fprintf('\n =========================================================================================\n')
fprintf('  RATING => FORCE\n')
fprintf(' =========================================================================================\n\n')

% reshaped data into structure
for iS=1:numel(data)
    
    t=table(  ...
        vec(data(iS).target') , ...
        vec(data(iS).rating(1:2,:)'/100) , ...
        vec(data(iS).choice') , ...
        vec(data(iS).success'),  ...
        vec(data(iS).force_max') , ...
        'VariableNames',{'target','rating','choice','success','force'});
    t(isnan(t.force),:) = [];
    
    t.target = zscore(t.target);
    t.rating = zscore(t.rating);
    m.c=fitglme(t                ,'choice  ~ target + rating  ','Distribution','binomial');
    
    t=t(t.choice>0,:);
    t.target = zscore(t.target);
    t.rating = zscore(t.rating);
    m.s=fitglme(t  ,'success ~ target + rating  ','Distribution','binomial');
    
    t=t(t.success>0,:);
    t.target = zscore(t.target);
    t.rating = zscore(t.rating);
    t.force = zscore(t.force);
    m.f=fitglme(t(t.success>0,:) ,'force   ~ target + rating  ') ;
    
    effect.rating.onChoice(iS) = m.c.Coefficients.Estimate(3);
    effect.target.onChoice(iS) = m.c.Coefficients.Estimate(2);
    
    accuracy.choice(iS)=balanced_accuracy(m.c.predict,m.c.response);
    
    effect.rating.onSuccess(iS) = m.s.Coefficients.Estimate(3);
    effect.target.onSuccess(iS) = m.s.Coefficients.Estimate(2);
    
    accuracy.success(iS)=balanced_accuracy(m.s.predict,m.s.response);
    
    effect.rating.onForce(iS) = m.f.Coefficients.Estimate(3);
    effect.target.onForce(iS) = m.f.Coefficients.Estimate(2);
    
    accuracy.force(iS)= m.f.Rsquared.Ordinary;
    
    
end

% exclude badly conditioned subject

% do stats
[~, p.rating.onChoice  ] = ttest([effect.rating.onChoice]) ;
[~, p.target.onChoice  ] = ttest([effect.target.onChoice]) ;
[~, p.rating.onSuccess ] = ttest([effect.rating.onSuccess]) ;
[~, p.target.onSuccess ] = ttest([effect.target.onSuccess]) ;
[~, p.rating.onForce   ] = ttest([effect.rating.onForce]) ;
[~, p.target.onForce   ] = ttest([effect.target.onForce]) ;

ste = @(x) std(x)/sqrt(numel(x));

fprintf(' # choice  // \t rating: %+03.2f (%03.2f) [p = %04.3f] \n\t\t target: %+03.2f (%03.2f) [p = %04.3f]\n', ...
    mean(effect.rating.onChoice), ste(effect.rating.onChoice) , p.rating.onChoice, ...
    mean(effect.target.onChoice), ste(effect.target.onChoice) , p.target.onChoice  ...
    );
fprintf('              \t accuracy: %+03.2f (%03.2f)\n\n',mean( accuracy.choice), ste(accuracy.choice) );

fprintf(' # success // \t rating: %+03.2f (%03.2f) [p = %04.3f] \n\t\t target: %+03.2f (%03.2f) [p = %04.3f]\n', ...
    mean(effect.rating.onSuccess), ste(effect.rating.onSuccess) , p.rating.onSuccess, ...
    mean(effect.target.onSuccess), ste(effect.target.onSuccess) , p.target.onSuccess  ...
    );
fprintf('              \t accuracy: %+03.2f (%03.2f)\n\n',mean( accuracy.success), ste(accuracy.success) );

fprintf(' # force   // \t rating: %+03.2f (%03.2f) [p = %04.3f] \n\t\t target: %+03.2f (%03.2f) [p = %04.3f]\n', ...
    mean(effect.rating.onForce), ste(effect.rating.onForce) , p.rating.onForce, ...
    mean(effect.target.onForce), ste(effect.target.onForce) , p.target.onForce  ...
    );
fprintf('              \t Rsquared: %+03.2f (%03.2f)\n\n',mean( accuracy.force), ste(accuracy.force) );

% =========================================================================
% effect of force behaviour on ratings
% =========================================================================

fprintf('\n =========================================================================================\n')
fprintf('  FORCE => RATING \n')
fprintf(' =========================================================================================\n\n')

% reshaped data into structure
t_all=table;
for iS=1:numel(data)
    
    ratings = reshape(zscore(vec(data(iS).rating)),3,90);
    
    t=table(  ...
        iS*ones(180,1), ...
        vec(ratings(2:3,:)')-vec(ratings(1:2,:)') , ...
        vec(data(iS).choice') , ...
        vec(data(iS).success'),  ...
        vec(data(iS).force_max') , ...
        'VariableNames',{'subject','delta_rating','choice','success','force'});
    
    t(isnan(t.force),:) = [];
    
    t.choice = zscore(2*t.choice -1) ;
    t.success(t.choice<=0) = nan;
    t.success = nanzscore(t.success);
    t.success(isnan(t.success)) = 0;
    
    t.force(t.success<=0) = nan;
    t.force = nanzscore(t.force);
    t.force(isnan(t.force)) = 0;
    
    m.r=fitglme(t               ,'delta_rating  ~ 1 + choice + success + force ');
    
    
    accuracy.onRating(iS) = m.r.Rsquared.Ordinary;
    
    effect.repet.onRating(iS) = m.r.Coefficients.Estimate(1);
    
    for iC = 2:numel(m.r.CoefficientNames)
        effect.(m.r.CoefficientNames{iC}).onRating(iS) = m.r.Coefficients.Estimate(iC);
    end
    
    t_all = [t_all; t];
    
    
end

% do stats
[~, p.choice.onRating  ] = ttest([effect.choice.onRating]) ;
[~, p.success.onRating  ] = ttest([effect.success.onRating]) ;
[~, p.force.onRating ] = ttest([effect.force.onRating]) ;
[~, p.repet.onRating ] = ttest([effect.repet.onRating]) ;

fprintf(' # ratings // \t choice: %+03.2f (%03.2f) [p = %04.3f] \n\t\t sucess: %+03.2f (%03.2f) [p = %04.3f] \n\t\t force : %+03.2f (%03.2f) [p = %04.3f]\n \t\t drift : %+03.2f (%03.2f) [p = %04.3f]\n', ...
    mean(effect.choice.onRating), ste(effect.choice.onRating) , p.choice.onRating, ...
    mean(effect.success.onRating), ste(effect.success.onRating) , p.success.onRating, ...
    mean(effect.force.onRating), ste(effect.force.onRating) , p.force.onRating ,...
    mean(effect.repet.onRating), ste(effect.repet.onRating) , p.repet.onRating ...
    );

fprintf('             \t fit: %04.3f (%04.3f) \n\n', mean(accuracy.onRating), ste(accuracy.onRating) );


% =========================================================================
% effect of force behaviour on ratings
% Control for time of exposure
% =========================================================================

fprintf('\n =========================================================================================\n')
fprintf('  FORCE => RATING \n')
fprintf('  Control for time of exposure \n')
fprintf(' =========================================================================================\n\n')

% reshaped data into structure
t_all=table;
for iS=1:numel(data)
    
    ratings = reshape(zscore(vec(data(iS).rating)),3,90);
    
    t=table(  ...
        iS*ones(180,1), ...
        vec(ratings(2:3,:)')-vec(ratings(1:2,:)') , ...
        vec(data(iS).choice') , ...
        vec(data(iS).success'),  ...
        vec(data(iS).force_max') , ...
        vec(data(iS).cumulativeExpositionTimeDuringRating(2:3,:)'), ...
        'VariableNames',{'subject','delta_rating','choice','success','force', 'exposition'});
    
    t(isnan(t.force),:) = [];
    
    t.choice = zscore(2*t.choice -1) ;
    t.success(t.choice<=0) = nan;
    t.success = nanzscore(t.success);
    t.success(isnan(t.success)) = 0;
    
    t.force(t.success<=0) = nan;
    t.force = nanzscore(t.force);
    t.force(isnan(t.force)) = 0;
    
    t.exposition = zscore(t.exposition);
    
    m.r=fitglme(t               ,'delta_rating  ~ 1 + choice + success + force + exposition ');
    
    
    accuracy.onRatingControlForExposition(iS) = m.r.Rsquared.Ordinary;
    
    effect.repet.onRatingControlForExposition(iS) = m.r.Coefficients.Estimate(1);
    
    for iC = 2:numel(m.r.CoefficientNames)
        effect.(m.r.CoefficientNames{iC}).onRatingControlForExposition(iS) = m.r.Coefficients.Estimate(iC);
    end
    
    t_all = [t_all; t];
    
    
end

% do stats
[~, p.choice.onRatingControlForExposition  ] = ttest([effect.choice.onRatingControlForExposition]) ;
[~, p.success.onRatingControlForExposition  ] = ttest([effect.success.onRatingControlForExposition]) ;
[~, p.force.onRatingControlForExposition ] = ttest([effect.force.onRatingControlForExposition]) ;
[~, p.repet.onRatingControlForExposition ] = ttest([effect.repet.onRatingControlForExposition]) ;
[~, p.exposition.onRatingControlForExposition ] = ttest([effect.exposition.onRatingControlForExposition]) ;

fprintf(' # ratings // \t choice: %+03.2f (%03.2f) [p = %04.3f] \n\t\t sucess: %+03.2f (%03.2f) [p = %04.3f] \n\t\t force : %+03.2f (%03.2f) [p = %04.3f]\n \t\t drift : %+03.2f (%03.2f) [p = %04.3f] \n\t\t exposition: %+03.2f (%03.2f) [p = %04.3f]\n', ...
    mean(effect.choice.onRatingControlForExposition), ste(effect.choice.onRatingControlForExposition) , p.choice.onRatingControlForExposition, ...
    mean(effect.success.onRatingControlForExposition), ste(effect.success.onRatingControlForExposition) , p.success.onRatingControlForExposition, ...
    mean(effect.force.onRatingControlForExposition), ste(effect.force.onRatingControlForExposition) , p.force.onRatingControlForExposition ,...
    mean(effect.repet.onRatingControlForExposition), ste(effect.repet.onRatingControlForExposition) , p.repet.onRatingControlForExposition ,...
    mean(effect.exposition.onRatingControlForExposition), ste(effect.exposition.onRatingControlForExposition) , p.exposition.onRatingControlForExposition ...
    );

fprintf('             \t fit: %04.3f (%04.3f) \n\n', mean(accuracy.onRatingControlForExposition), ste(accuracy.onRatingControlForExposition) );


% =========================================================================
% effect of first session on second session
% =========================================================================

fprintf('\n =========================================================================================\n')
fprintf('  DELTA RATING 1 => FORCE 2 \n')
fprintf(' =========================================================================================\n\n')

% reshaped data into structure
t_all=table;
for iS=1:numel(data)
    
    choosen = +(data(iS).choice(2,:)==1 & data(iS).choice(1,:)==1)';
    successful =  +(data(iS).success(2,:)==1 & data(iS).success(1,:)==1)';
    
    t=table(  ...
        iS*ones(90,1), ...
        choosen, ...
        successful, ...
        data(iS).target(2,:)'-data(iS).target(1,:)' , ...
        vec(data(iS).rating(2,:)')-vec(data(iS).rating(1,:)') , ...
        vec(data(iS).choice(2,:)')-vec(data(iS).choice(1,:)') , ...
        vec(data(iS).success(2,:)')-vec(data(iS).success(1,:)') , ...
        vec(data(iS).force_max(2,:)')-vec(data(iS).force_max(1,:)') , ...
        vec(data(iS).choice(2,:)') , ...
        vec(data(iS).success(2,:)') , ...
        vec(data(iS).force_max(2,:)') , ...
        'VariableNames',{'subject','choosen','successful','delta_target','delta_rating','delta_choice','delta_success','delta_force','choice','success','force'});
    
    t(isnan(t.force),:) = [];
    t.version = str2num(data(iS).version(2)) * ones(height(t), 1);
    
    %     t.delta_rating = zscore(t.delta_rating);
    
    %    t.delta_success(~t.choosen) = nan;
    %    t.delta_force(~t.successful) = nan;
    %
    %     t.delta_choice = nanzscore(t.delta_choice);
    %     t.delta_sucess = nanzscore(t.delta_success);
    %     t.delta_force = nanzscore(t.delta_force);
    
    if all(t.delta_target == 0)
        
        m.deltaChoice=fitglme(t               ,'delta_choice  ~ 1 + delta_rating ');
        effect.deltaRating.onDeltaChoice(iS) = m.deltaChoice.Coefficients.Estimate(2);
        
        m.deltaSuccess=fitglme(t               ,'delta_success  ~ 1 + delta_rating ');
        effect.deltaRating.onDeltaSuccess(iS) = m.deltaSuccess.Coefficients.Estimate(2);
        
        m.deltaForce=fitglme(t               ,'delta_force  ~ 1 + delta_rating ');
        effect.deltaRating.onDeltaForce(iS) = m.deltaForce.Coefficients.Estimate(2);
        
    else
        
        m.deltaChoice=fitglme(t               ,'delta_choice  ~ 1 + delta_rating + delta_target');
        effect.deltaRating.onDeltaChoice(iS) = m.deltaChoice.Coefficients.Estimate(3);
        
        m.deltaSuccess=fitglme(t               ,'delta_success  ~ 1 + delta_rating + delta_target');
        effect.deltaRating.onDeltaSuccess(iS) = m.deltaSuccess.Coefficients.Estimate(3);
        
        m.deltaForce=fitglme(t               ,'delta_force  ~ 1 + delta_rating + delta_target');
        effect.deltaRating.onDeltaForce(iS) = m.deltaForce.Coefficients.Estimate(3);
        
        
        mm = fitglme(t, 'delta_choice  ~ 1 + delta_target');
        t.delta_choice = mm.residuals;
        mm = fitglme(t, 'delta_success  ~ 1 + delta_target');
        t.delta_success = mm.residuals;
        mm = fitglme(t, 'delta_force  ~ 1 + delta_target');
        t.delta_force = mm.residuals;
        
    end
    t_all = [t_all; t];
    
    %
    
    
    
end

cType = 'Pearson';
delta= t_all;

[effect.delta_rating.onSecond_choice,p.delta_rating.onSecond_choice]=corr(t_all.delta_choice, t_all.delta_rating,'Type',cType,'rows','complete');
[effect.delta_rating.onSecond_success,p.delta_rating.onSecond_success]=corr( t_all.delta_success,t_all.delta_rating,'Type',cType,'rows','complete');
[effect.delta_rating.onSecond_force,p.delta_rating.onSecond_force]=corr(t_all.delta_force, t_all.delta_rating,'Type',cType,'rows','complete');


fprintf(' # choice   // \t delta_rating: rho=%+04.3f [p = %04.3f]\n\n', ...
    effect.delta_rating.onSecond_choice  , p.delta_rating.onSecond_choice   ...
    );
fprintf(' # success  // \t delta_rating: rho=%+04.3f [p = %04.3f]\n\n', ...
    effect.delta_rating.onSecond_success  , p.delta_rating.onSecond_success   ...
    );

fprintf(' # force    // \t delta_rating: rho=%+04.3f [p = %04.3f]\n\n', ...
    effect.delta_rating.onSecond_force  , p.delta_rating.onSecond_force   ...
    );




%%
%results.m=m;
results.effect=effect;
results.p=p;

end

