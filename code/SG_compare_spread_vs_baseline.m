function SG_compare_spread_vs_baseline()

data = SG_load_data;
nSubject = length(data);
data = data(setdiff(1:nSubject,SG_exclude())); % remove outliers

version = vertcat(data.version);
idx_version = str2num(version(:,2));
idx_version(idx_version>1) = 5-idx_version(idx_version>1);

data=data(idx_version ~= 1);


t_all=table;
for iS=1:numel(data)

    choice = 2*data(iS).compatibility.allItemForce.allChoice-1;
    isExcluded = isnan(choice(1,:));
    ratings = reshape(zscore(vec(data(iS).compatibility.allItemRating.allRating)),3,150);
    [~,order, rank]=my_sort(ratings(1,:));
    temp = sort(rank(isExcluded==1));
    rankToExclude = temp([1:15 (end-14):end]);
    toExclude =  repmat(ismember(rank, rankToExclude), 2, 1);

    choice(isnan(choice)) = 0;
    success = 2*data(iS).compatibility.allItemForce.allSuccess-1;
    force = data(iS).compatibility.allItemForce.allForcePeak;

    t=table(  ...
        iS*ones(300,1), ...
        vec(ratings(2:3,:)')-vec(ratings(1:2,:)') , ...
        vec(choice') , ...
        vec(success'),  ...
        vec(force') , ...
        vec(toExclude'), ...
        'VariableNames',{'subject','delta_rating','choice','success','force', 'toExclude'});

    t= t(t.toExclude == 0,:);

    t.success(t.choice<=0) = nan;
    t.success = nanzscore(t.success);
    t.success(isnan(t.success)) = 0;

    t.choice = zscore(2*t.choice -1) ;

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

    delta_rating_spread_vs_baseline(iS,:) = tapply(t.delta_rating, {t.choice}, @mean);
end

% do stats

[~, p.choice.chosenVSBaseline  ] = ttest(delta_rating_spread_vs_baseline(:, 2), delta_rating_spread_vs_baseline(:, 3));
[~, p.choice.unchosenVSBaseline  ] = ttest(delta_rating_spread_vs_baseline(:, 1), delta_rating_spread_vs_baseline(:, 2));
[~, p.choice.asymmetricSpread  ] = ttest(delta_rating_spread_vs_baseline(:, 1)-delta_rating_spread_vs_baseline(:, 2), delta_rating_spread_vs_baseline(:, 2)-delta_rating_spread_vs_baseline(:, 3));

sem = @(x) std(x)/sqrt(numel(x));

 fprintf(' # ratings // \t chosen: %+03.2f (%03.2f) \n\t\t baseline: %+03.2f (%03.2f)  \n\t\t unchosen : %+03.2f (%03.2f) ]\n \t\t chosenVSBaseline : [p = %04.3f] \n\t\t unchosenVSBaseline : [p = %04.3f]  \n\t\t asymmetricSpread : [p = %04.3f] \n', ...
     mean(delta_rating_spread_vs_baseline(:, 3)), sem(delta_rating_spread_vs_baseline(:, 3)), ...
     mean(delta_rating_spread_vs_baseline(:, 2)), sem(delta_rating_spread_vs_baseline(:, 2)), ...
     mean(delta_rating_spread_vs_baseline(:, 1)), sem(delta_rating_spread_vs_baseline(:, 1)), ...
     p.choice.chosenVSBaseline, ...
     p.choice.unchosenVSBaseline, ...
     p.choice.asymmetricSpread);

end

function [ orderedVector, sortIndex, rank ] = my_sort( varargin )
%% Use sort function to return rank of elements on top of usual outputs of sort

[orderedVector, sortIndex]= sort(varargin{:});
rank = 1:length(sortIndex);
rank(sortIndex) = rank;

end
