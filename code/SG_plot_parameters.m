function SG_plot_parameters(grand_summary)



%% model based

subplot(1,2,1);
p.restricted=SG_plot_null_distrib_sub(grand_summary.restricted);
ylabel('posterior b value')
%tt_type(3)=text(.5,-4,'BMA H0-H2');
%tt_type(4)=text(.5,-4.66,'(ratings only)');
title('A')

subplot(1,2,2);
ylabel('posterior b value')
%tt_type(5)=text(.5,-4,'BMA H0-H3');
%tt_type(6)=text(.5,-4.66,'(all behaviors)');
p.full=SG_plot_null_distrib_sub(grand_summary.full);
title('B')

% [tt_type.FontSize] = deal(12);
% [tt_type.FontWeight] = deal('bold');

%% save



pretty.plot('../figures/parameters',2*[9 4]);

end

function p=SG_plot_null_distrib_sub(grand_summary_sub)



hold on;
set(gca,'DrawMode','normal');

% plot subject effects

BMA_sub=[grand_summary_sub.subject.BMA.subject.effects] ;


effect_distrib = [ ...
    struct.extract(BMA_sub,'choice_effect') ...
    struct.extract(BMA_sub,'success_effect') ...
    struct.extract(BMA_sub,'force_effect')  ...
    struct.extract(BMA_sub,'drift_effect')  ...
    ] ;
mean(effect_distrib)
%errorbar(1:4,mean(effect_distrib),std(effect_distrib)/sqrt(18),'LineStyle','none','Color',[.1 .1 .1]);

%    bar(1,mean(effect_distrib(:,1)),'FaceColor',SG_color('choice'))
%    bar(2,mean(effect_distrib(:,2)),'FaceColor',SG_color('success'))
%    bar(3,mean(effect_distrib(:,3)),'FaceColor',SG_color('force'))
%    bar(4,mean(effect_distrib(:,4)),'FaceColor',SG_color('drift'))

% compute null distribution

BMA_boot = [grand_summary_sub.bootstrap.all.BMA];
BMA_boot_eff = [BMA_boot.effects];


null_distrib = [ ...
    struct.extract(BMA_boot_eff,'choice_effect') ...
    struct.extract(BMA_boot_eff,'success_effect') ...
    struct.extract(BMA_boot_eff,'force_effect')  ...
    struct.extract(BMA_boot_eff,'drift_effect')  ...
    ] ;


pct = prctile(null_distrib,[2.5 97.5]);

colors = {'choice','success','force','drift'};
nSub = size(effect_distrib,1);

markerSize = 12;
for i=1:4
    isOutbound = (effect_distrib(:,i) < pct(1,i)) | (effect_distrib(:,i) > pct(2,i)) ;
    nOut = sum(isOutbound);
    scatter( i*ones(nOut,1)+.7*(rand(nOut,1)-.5)      , effect_distrib(find(isOutbound),i), ...
             markerSize, ...
             'filled', ...
             'MarkerFaceColor',SG_color(colors{i}), ...
             'MarkerEdgeColor',SG_color(colors{i})-.1) ;
    scatter( i*ones(nSub-nOut,1)+.7*(rand(nSub-nOut,1)-.5), ...
       effect_distrib(find(~isOutbound),i), ...
            markerSize, ...
             'filled', ...
             'MarkerFaceColor','none', ...
             'MarkerEdgeColor',SG_color(colors{i})) ;
end
    




% 
% boxPlot(null_distrib,...
%     'limit',[0,100],...
%     'theme','colorall',...
%     'notch',true,...
%     'showScatter',true,...
%     'scaleWidth',true,...
%     'style','hierarchy',...
%     'groupWidth',.9,...
%     'scatterMarker','.',...
%     'xSpacing','x');

h=violin(null_distrib, ...
    'facecolor',SG_color('null'), ...
    'edgecolor','none', ...
    'facealpha',.75, ...
    'mc','', ...
    'medc',''...
);
legend off;
box off



% boxPlot(effect_distrib,...
%     'limit',[0,100],...
%     'boxAlpha',0, ...
%     'notch',false,...
%     'showScatter',true,...
%     'scaleWidth',true,...
%     'style','hierarchy',...
%     'groupWidth',.9,...
%     'scatterMarker','.',...
%     'xSpacing','x');
% 
% 

ylim([-12.5 12])
set(gca,'Xlim', [.3 4.7], ...
        'XTick',1:4,'XTickLabel',{'C','S','F','T'})
set(gca,'YTick',-12:4:12)

hold off;

%effect_sign = 2*(mean(effect_distrib) > mean(null_distrib))-1;

N = size(null_distrib,1) ;


parfor iB=1:N
    
   BMA_boot_sub = [BMA_boot(iB).subject.effects];
   null_distrib_iB = [ ...
    struct.extract(BMA_boot_sub,'choice_effect') ...
    struct.extract(BMA_boot_sub,'success_effect') ...
    struct.extract(BMA_boot_sub,'force_effect')  ...
    struct.extract(BMA_boot_sub,'drift_effect')  ...
    ] ;
for iE =1:4
    [~,p(iB,iE),~, stat]=ttest2(effect_distrib(:,iE),null_distrib_iB(:,iE),'Vartype','unequal');
    tvalue(iB,iE) = stat.tstat;
end
end


% add stars

a=gca;
pp = [grand_summary_sub.subject.BMA.significance.choice_effect, ...
      grand_summary_sub.subject.BMA.significance.success_effect, ...
      grand_summary_sub.subject.BMA.significance.force_effect, ...
      grand_summary_sub.subject.BMA.significance.drift_effect ] ;

 for i=1:4
        betas.m(i) = mean(effect_distrib(:,i)) ;
        betas.s(i) = std(effect_distrib(:,i))/sqrt(nSub) ;
        
       if pp(i) <= 0.05
       tt=text(i,-11,pretty.star(pp(i)));
       
       tt.FontSize = 12;
       tt.FontWeight = 'bold';
       tt.HorizontalAlignment = 'center';
       end
end

xlabel('factor')

p=mean(p)

end

function x = comp_percentile(datas,value)
    perc = prctile(datas,1:100);
    [c index] = min(abs(perc'-value));
    x = index+1;
end
