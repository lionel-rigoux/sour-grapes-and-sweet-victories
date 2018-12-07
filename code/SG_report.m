function  SG_report(grand_summary)

% report subject's analysis
% =========================================================================

effect_list = {'dynamics', 'choiceUpdate', 'successUpdate', 'forceUpdate', 'driftUpdate'};


fprintf('\n =========================================================================================\n')
fprintf('  SUBJECT ANALYSIS\n')
fprintf(' =========================================================================================\n\n')


fprintf('%+16s | amplitude \t |   p \t   |  h  |   Ef   |  xp   |  H \t |\n','effect')
fprintf('   -----------------------------------------------------------------------\n')


for iE = 1:numel(effect_list)
    effect = effect_list{iE};

    % display results
    matches=regexp(effect,'(?<effect>.*)Update','names');
    if ~isempty(matches)
       name_effect = [matches.effect '_effect'];
    end
    try
          value = grand_summary.subject.BMA.effects.(name_effect);
          p = grand_summary.subject.BMA.significance.(name_effect);
          h=p<.05; 
    end


    ep = grand_summary.subject.MC.(effect).ep;
    Ef = grand_summary.subject.MC.(effect).Ef;
    winner = find(ep==max(ep)); 
    
    if ~isempty(matches)
    fprintf('%+16s | %+4.3f \t | %5.4f  |  %d  |  %3.2f  | %3.2f  | H%d \t |\n', ...
            effect,   value   ,   p       , h , Ef(winner)       ,  ep(winner)       ,winner-1) ;
    else
       fprintf('%+16s | \t \t | \t   |     |  %3.2f  | %3.2f  | H%d \t |\n', ...
            effect,                             Ef(winner)       ,  ep(winner)       ,winner-1) ;
    end
end
fprintf('   -----------------------------------------------------------------------\n')

return
% report bootstrap's analysis
% =========================================================================

effect_list = {'dynamics', 'choiceUpdate', 'successUpdate', 'forceUpdate', 'driftUpdate'};


fprintf('\n =========================================================================================\n')
fprintf('  BOOTSTRAP ANALYSIS\n')
fprintf(' =========================================================================================\n\n')


fprintf('%+16s | amplitude \t   |  \t p \t |  h \t |   Ef \t | \txp\t|\n','factor')
fprintf('   --------------------------------------------------------------------------------------\n')

clear ep Ef value p h 
bootstrap_BMA = [grand_summary.bootstrap.all.BMA];
bootstrap_MC = [grand_summary.bootstrap.all.MC];
N=numel(bootstrap_MC);
for iE = 1:numel(effect_list)
    effect = effect_list{iE};

    % display results
    matches=regexp(effect,'(?<effect>.*)Update','names');
    if ~isempty(matches)
       name_effect = [matches.effect '_effect'];
    end
    try
          tmp = struct.extract([bootstrap_BMA.effects],name_effect);
          value.m = mean(tmp);
          value.s = std(tmp);
          tmp = struct.extract([bootstrap_BMA.significance],name_effect);
          p.m = mean(tmp);
          p.s = std(tmp);
          h=mean(tmp<.05); 
    end


    tmp = 1-struct.extract([bootstrap_MC.(effect)],'ep');
    ep.m = mean(tmp);
    ep.s = std(tmp);
    tmp = 1-struct.extract([bootstrap_MC.(effect)],'Ef');
    tmp=reshape(tmp,numel(tmp)/N,N)';
    tmp=tmp(:,1);
    Ef.m = mean(tmp);
    Ef.s = std(tmp);

    
    if ~isempty(matches)
    fprintf('%+16s | %+4.3f (%+4.3f) | %3.2f (%3.2f) |  %3.2f |  %3.2f (%3.2f)  | %3.2f (%3.2f)  |\n', ...
            effect,   value.m, value.s  ,   p.m, p.s       , h       , Ef.m(1), Ef.s(1)  ,  ep.m(1), ep.s(1)   ) ;
    else
    fprintf('%+16s | \t\t   | \t\t | \t |  %3.2f (%3.2f)  | %3.2f (%3.2f)  |\n', ...
            effect,        Ef.m(1), Ef.s(1)  ,  ep.m(1), ep.s(1)   ) ;
    end
end
fprintf('   --------------------------------------------------------------------------------------\n\n')

