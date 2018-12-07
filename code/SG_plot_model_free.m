function results=SG_plot_model_free(data,split)

if nargin == 1
    split = true;
end

if split
    f_force_on_ratings = figure ;
    f_ratings_on_force = figure ;
else
    f_all = figure ;
end
%

margin_left = .07;
plot_width  = .16;

% plot force => delta-rating
% ===================================================================
if split
    figure(f_ratings_on_force)
else
    figure(f_all)
end

t_all = table;
for iS=1:numel(data)
    
    data(iS).force_max_n = data(iS).force_max;
    data(iS).success_n = data(iS).success;
    data(iS).force_max_n(data(iS).success==0)=nan;
    data(iS).success_n(data(iS).choice==0)=nan;
    data(iS).repetition=[ones(1, 90); 2*ones(1, 90)];
    data(iS).zrating = reshape(zscore(vec(data(iS).rating')),90,3)';
    
    
    t=table(  ...
        iS*ones(180,1) , ...
        repmat(data(iS).target',2,1) , ...
        vec(data(iS).zrating(2:3,:)'-data(iS).zrating(1:2,:)') , ...
        vec(data(iS).choice') , ...
        vec(data(iS).success'),  ...
        vec(data(iS).force_max') , ...
        vec(data(iS).repetition') , ...
        'VariableNames',{'subject','target','delta_rating','choice','success','force', 'repetition'});
    
    [~,~,t.force_bin]=histcounts(t.force,2) ;
    
    
    t_all = [t_all; ...
        varfun(@nanmean,t,'InputVariables',{'delta_rating'},'GroupingVariables',{'subject','choice','success','force_bin', 'repetition'})];
end



limits = [-1.25 1.35];
for iRepetition = 1:2
    
    if split
        offset = (iRepetition-1)*.46;
    else
        offset = (iRepetition==2)*.68; 
    end
    
    %% choice
    t_choice = t_all;
    t_choice = grpstats(t_choice,{'subject','choice', 'repetition'},{'nanmean','nanstd'});
    t_choice = t_choice(t_choice.repetition==iRepetition,:);
    
    if split
        subplot('Position',[margin_left .60-offset plot_width .34]);
    else
        subplot('Position',[margin_left+offset .72 .2 .25]);
    end
    boxplot(t_choice.nanmean_nanmean_delta_rating,t_choice.choice,'Colors',SG_color('choice'),'Widths',.8,'Whisker',8);
    xlabel(['choice (C' num2str(iRepetition) ')'])
    ylabel(['\Delta rating (R' num2str(iRepetition+1) ' - R' num2str(iRepetition) ')'])
    set(gca,'YTick',-1.2:.4:1.3)
    ylim(limits)
    if iRepetition==1, title('A'); else, title('B'); end
    
%     % stats
%     mmm = fitlme(t_choice,'nanmean_nanmean_delta_rating ~ choice + (1|subject)');
%     [~,~,ss]=fixedEffects(mmm);
%     text (mean (xlim ()), 1, pretty.star(ss.pValue(end)));
%     
    %% success
    t_success = t_all(t_all.choice>0,:);
    t_success = grpstats(t_success,{'subject','success', 'repetition'},{'nanmean','nanstd'});
    t_success = t_success(t_success.repetition==iRepetition,:);

    if split
        subplot('Position',[2*margin_left+plot_width .60-offset plot_width .34]);
    else
        subplot('Position',[margin_left+offset .39 .2 .25]);
    end
    boxplot(t_success.nanmean_nanmean_delta_rating,t_success.success,'Colors',SG_color('success'),'Widths',.8,'Whisker',8);
    xlabel(['success (S' num2str(iRepetition) ')'])
    ylabel(['\Delta rating (R' num2str(iRepetition+1) ' - R' num2str(iRepetition) ')'])
    set(gca,'YTick',-1.2:.4:1.3)
    ylim(limits)
    
%      % stats
%     mmm = fitlme(t_success,'nanmean_nanmean_delta_rating ~ success + (1|subject)');
%     [~,~,ss]=fixedEffects(mmm);
%     text (mean (xlim ()), 1, pretty.star(ss.pValue(end)));

    %% force
    t_force = t_all(t_all.success>0 & t_all.force_bin > 0 ,:);
    %t_all(t_all.force_bin == 0,:) = [];
    t_force = grpstats(t_force,{'subject','force_bin', 'repetition'},{'nanmean','nanstd'});
    t_force=t_force(t_force.repetition==iRepetition,:);

    if split
        subplot('Position',[3*margin_left+2*plot_width .60-offset plot_width .34]);
    else
        subplot('Position',[margin_left+offset .06 .2 .25]);
    end
    boxplot(t_force.nanmean_nanmean_delta_rating,t_force.force_bin,'Colors',SG_color('force'),'Widths',.8,'Whisker',8);
    xlabel(['force (F' num2str(iRepetition) ')'])
    set(gca,'XTickLabel',{'L','H'})
    ylabel(['\Delta rating (R' num2str(iRepetition+1) ' - R' num2str(iRepetition) ')'])
    set(gca,'YTick',-1.2:.4:1.3)
    ylim(limits)
%     
%       % stats
%     mmm = fitlme(t_force,'nanmean_nanmean_delta_rating ~ force_bin + (1|subject)');
%     [~,~,ss]=fixedEffects(mmm);
%     text (mean (xlim ()), 1, pretty.star(ss.pValue(end)));


end

  % repetition
    t_repet = t_all;
    t_repet = grpstats(t_repet,{'subject', 'repetition'},{'nanmean','nanstd'});

    if split
        %f_repet = figure
        subplot('Position',[4*margin_left+3*plot_width .60 plot_width .34]);
    else
        f_repet = figure
        %subplot('Position',[margin_left+offset .06 .2 .25]);
    end
    boxplot(t_repet.nanmean_nanmean_delta_rating,t_repet.repetition,'Colors',SG_color('drift'),'Widths',.8,'Whisker',8);
    xlabel(['  task repetition (T)'])
    set(gca,'XTickLabel',{'1','2'})
    ylabel(['\Delta rating (R[T+1] - R[T])'])
    set(gca,'YTick',-1.2:.4:1.3)
    ylim(limits)
 title('C');

    
 % regression  
a1=subplot('Position',[4*margin_left+3*plot_width+.02 .60-offset plot_width-.02 .34]);
hold on;

 results=SG_model_free(data) ;

betas.m(1) = mean(results.effect.choice.onRating);
betas.s(1) = std(results.effect.choice.onRating)/sqrt(numel(data));
betas.m(2) = mean(results.effect.success.onRating);
betas.s(2) = std(results.effect.success.onRating)/sqrt(numel(data));
betas.m(3) = mean(results.effect.force.onRating);
betas.s(3) = std(results.effect.force.onRating)/sqrt(numel(data));
betas.m(4) = mean(results.effect.repet.onRating);
betas.s(4) = std(results.effect.repet.onRating)/sqrt(numel(data));

errorbar(1:4,betas.m, betas.s,'Color',[.1 .1 .1]);
bar(1,betas.m(1),'FaceColor',SG_color('choice'))
bar(2,betas.m(2),'FaceColor',SG_color('success'))
bar(3,betas.m(3),'FaceColor',SG_color('force'))
bar(4,betas.m(4),'FaceColor',SG_color('drift'))

pp = [results.p.choice.onRating;
    results.p.success.onRating;
    results.p.force.onRating;
    results.p.repet.onRating];

for i=1:4
    yy = betas.m(i) + 1.1*sign(betas.m(i))*betas.s(i);
    yy = yy + sign(yy) * .02*(a1.YLim(2) - a1.YLim(1));
    if pp(i) <= 0.05
    tt=text(i+.015,yy,pretty.star(pp(i)));
    
    tt.FontSize = 12;
    tt.FontWeight = 'bold';
    tt.HorizontalAlignment = 'center';
    end
end


xlabel('factor')
ylabel('\beta estimate (ratings)')
set(gca,...
    'Xlim', [.3 4.7], ...
    'XTick',1:4, ...
    'XTickLabel',{'C','S','F','T'} ,...
    'YLim', [-.04 .12] , ...
    'YTick',-.04:.04:.12 ...
    )
title('D');

% plot delta-rating => force
% ===================================================================
if split
    figure(f_force_on_ratings)
else
    figure(f_all)
end

n_bins_target = 5;

t_all = table;
for iS=1:numel(data)
    
        ratings = reshape(zscore(vec(data(iS).rating)),3,90);

    data(iS).force_max(data(iS).success==0)=nan;
    data(iS).success(data(iS).choice==0)=nan;
        
    choosen = +(data(iS).choice(2,:)==1 & data(iS).choice(1,:)==1)';
    successful =  +(data(iS).success(2,:)==1 & data(iS).success(1,:)==1)';

    t=table(  ...
        iS*ones(90,1) , ...
        choosen, ...
        successful, ...
        data(iS).target(2,:)'-data(iS).target(1,:)' , ...
        data(iS).rating(2,:)'-data(iS).rating(1,:)' , ...
        data(iS).choice(2,:)'-data(iS).choice(1,:)' , ...
        data(iS).success(2,:)'-data(iS).success(1,:)',  ...
        data(iS).force_max(2,:)'-data(iS).force_max(1,:)' , ...
        'VariableNames',{'subject','choosen','successful','delta_target','delta_rating','delta_choice','delta_success','delta_force'});
   
     t.delta_rating = zscore(t.delta_rating);
    [~,~,t.delta_rating_bin]=histcounts(t.delta_rating,n_bins_target) ;

        
    t.delta_success(~t.choosen) = nan;
    t.delta_force(~t.successful) = nan;
    
    t.delta_choice = nanzscore(t.delta_choice);
    t.delta_sucess = nanzscore(t.delta_success);
    t.delta_force = nanzscore(t.delta_force);
    
    t_all = [t_all; ...
        varfun(@nanmean,t,'InputVariables',{'delta_target','delta_choice','delta_success','delta_force'},'GroupingVariables',{'subject','delta_rating_bin'})];
end

t_group = grpstats(t_all,{'delta_rating_bin'},{'nanmean','nanstd'});

if split
    a1=subplot('Position',[.10 .20 .23 .70]);
else
    a1=subplot('Position',[.38 .72 .28 .25]);
end
my_error_line(t_group.nanmean_nanmean_delta_choice,t_group.nanstd_nanmean_delta_choice/sqrt(numel(data)),SG_color('choice'))
ylabel('\Delta choice (C2 - C1)')
ylim([-.107 .15])
a1.YTick      = -.10:.05:.15 ;
a1.YTickLabelMode = 'auto' ;
title('A');

if split
    a2=subplot('Position',[.44 .20 .23 .70]);
else
    a2=subplot('Position',[.38 .39 .28 .25]);
end
my_error_line(t_group.nanmean_nanmean_delta_success,t_group.nanstd_nanmean_delta_success/sqrt(numel(data)),SG_color('success'))
ylabel('\Delta success (S2 - S1)')
ylim([-.105 .15])
a2.YTick      = -.10:.05:.15 ;
a2.YTickLabelMode = 'auto' ;
title('B');

if split
    a3=subplot('Position',[.78 .20 .22 .70]);
else
    a3=subplot('Position',[.38 .06 .28 .25]);
end
my_error_line(t_group.nanmean_nanmean_delta_force,t_group.nanstd_nanmean_delta_force/sqrt(numel(data)),SG_color('force'))
ylabel('\Delta force (F2 - F1)')
ylim([-.41 .4])
a3.YTick      = -.4:.2:.4 ;
a3.YTickLabelMode = 'auto' ;
title('C');

% save
% ===================================================================

if split
    figure(f_force_on_ratings)
    pretty.plot('../figures/model_free_force_on_ratings',2*[12 4]);
    figure(f_ratings_on_force)
    pretty.plot('../figures/model_free_ratings_on_force',2*[16 8]);
else
    figure(f_all)
    pretty.plot('../figures/model_free',2*[12 15]);
end

end


function my_error_line(m,s,color)
hold on
[n_bin]=size(m,1);

hl=plot(1:n_bin,m);
he=errorbar(1:n_bin,m,s);
zlabel('force')
xlabel('\Delta rating (R2 - R1)')

hl.Color = color;
he.Color = color;
xlim([.6 n_bin+.4])
%ylim([-.3 .1])

set(gca,...
    'XTickMode','manual', ...
    'XTick', [1 n_bin/2+.5 n_bin ], ...
    'XTickLabel',{'-','0','+'} , ...
    'YTickMode','manual', ...
    'YTick', -.3:.05:.1 , ...
    'YTickLabel',{'-0.30','-0.25','-0.20','-0.15','-0.05','0.00','0.05','0.10'} ...
    );

end

function copyplot(a,f,p)

ax1=subplot(p);
pos=get(ax1,'Position');
delete(ax1);
hax2=copyobj(a,f);
set(hax2, 'Position', pos);
   
end
