function SG_plot_sanity_checks(data)


LineStyle_list = {':','--','-'};
    
n_bins_target = 5;
n_bins_value = 3;

% plot target*rating => force
% ===================================================================

figure;
% avg across experience

t_all = table;
for iS=1:numel(data)
    
    data(iS).force_max(data(iS).success==0)=nan;
    data(iS).success(data(iS).choice==0)=nan;
    
    t=table(  ...
        iS*ones(180,1) , ...
        vec(data(iS).target') , ...
        repmat(zscore(mean(data(iS).rating))',2,1) , ...
        vec(data(iS).choice') , ...
        vec(data(iS).success'),  ...
        vec(data(iS).force_max') , ...
        'VariableNames',{'subject','target','rating','choice','success','force'});
    
    [~,~,t.target_bin]=histcounts(t.target,n_bins_target) ;
    [~,~,t.rating_bin]=histcounts(t.rating,n_bins_value) ;
    
    t_all = [t_all; ...
        varfun(@nanmean,t,'InputVariables',{'choice','success','force'},'GroupingVariables',{'target_bin','rating_bin'})];
end




t_group = grpstats(t_all,{'target_bin','rating_bin'},{'nanmean','nanstd'});

for iT = 1:n_bins_target
    for iR = 1:n_bins_value
        idx = t_group.target_bin==iT & t_group.rating_bin==iR ;
        t_sub = t_group(idx,:);
        
        if ~isempty(t_sub)
            choice.m(iT,iR) = t_sub.nanmean_nanmean_choice ;
            choice.s(iT,iR) = t_sub.nanstd_nanmean_choice ;
            
            success.m(iT,iR) = t_sub.nanmean_nanmean_success ;
            success.s(iT,iR) = t_sub.nanstd_nanmean_success ;
            
            force.m(iT,iR) = t_sub.nanmean_nanmean_force ;
            force.s(iT,iR) = t_sub.nanstd_nanmean_force ;
        else
            choice.m(iT,iR) = nan ;
            choice.s(iT,iR) = nan ;
            
            success.m(iT,iR) = nan ;
            success.s(iT,iR) = nan ;
            
            force.m(iT,iR) = nan ;
            force.s(iT,iR) = nan ;
            
        end
        
        XX(iT,iR) = iT;
        YY(iT,iR) = iR;
        
    end
end


a1=subplot('Position',[.1 .25 .22 .65]);
h=plot(choice.m);
hold on
he=errorbar(choice.m,choice.s/sqrt(numel(data)));
for i=1:n_bins_value
    h(i).Color = min(max(SG_color('choice') * (1+(n_bins_value-i)/4),[0 0 0]),[1 1 1]);
    h(i).LineStyle = LineStyle_list{i};
    he(i).Color = h(i).Color;
end
xlim([.7 n_bins_target+.3])
ylim([-.05 1.0])
set(gca, ...
    'XTick',1:n_bins_target, ...
    'YTick',0:.2:1, ...
    'YTickLabel',{'0.0','0.2','0.4','0.6','0.8','1.0'} ...
)
xlabel('target level (bin)')

ylabel('P(choice)')
title('A');


a2=subplot('Position',a1.Position+[.32 0 0 0]);
h=plot(success.m);
hold on
he=errorbar(success.m,success.s/sqrt(numel(data)));
for i=1:n_bins_value
    h(i).Color = min(max(SG_color('success') * (1+(n_bins_value-i)/4),[0 0 0]),[1 1 1]);
    h(i).LineStyle = LineStyle_list{i};
    he(i).Color = h(i).Color;
end
ylabel('P(success)')
xlim([.7 n_bins_target+.3])
ylim([-.05 1.0])
set(gca, ...
    'XTick',1:n_bins_target, ...
    'YTick',0:.2:1, ...
    'YTickLabel',{'0.0','0.2','0.4','0.6','0.8','1.0'} ...
)
xlabel('target level (bin)')

title('B');

a3=subplot('Position',a2.Position+[.32 0 0 0]);
h=plot(force.m);
hold on
he=errorbar(force.m,force.s/sqrt(numel(data)));
for i=1:n_bins_value
    h(i).Color = min(max(SG_color('force') * (1+(n_bins_value-i)/4),[0 0 0]),[1 1 1]);
    h(i).LineStyle = LineStyle_list{i};
    he(i).Color = h(i).Color;
end
ylabel('exerted force (%F_{max})')
xlim([.7 n_bins_target+.3])
ylim([.25 1.3])
title('C');
set(gca, ...
    'XTick',1:n_bins_target, ...
    'YTickLabel',{'0.3','0.5','0.7','0.9','1.1','1.3'}, ... 
    'YTick',.3:.2:1.3  ...
)
xlabel('target level (bin)')


pretty.plot('../figures/sanity_checks',2*[12 4]);


end

