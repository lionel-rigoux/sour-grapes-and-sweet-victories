function [results, grand_summary]=SG_report_version(v)

if nargin == 0
    for i=1:3
        fprintf('\n#########################################################################################\n');
        fprintf(' VERSION %d\n', i);
        fprintf('#########################################################################################\n');

        [results.version(i), grand_summary.version(i)]=SG_report_version(i);
    end
    
    fprintf('\n#########################################################################################\n');
    fprintf(' ALL\n');
    fprintf('#########################################################################################\n');

    [results.all, grand_summary.all]=SG_report_version(1:3);
    return
end
        
    
data = SG_load_data();

%% find subjects

version = vertcat(data.version);
version = str2num(version(:,2));

idx_good = setdiff(find(ismember(version,v)), SG_exclude());

%% model free

results=SG_plot_model_free(data(idx_good));
SG_plot_sanity_checks(data(idx_good));

%% model based

% summarise
[grand_summary.restricted.subject, grand_summary.restricted.results]=SG_analyse('subjects',1,idx_good);
[grand_summary.full.subject, grand_summary.full.results]=SG_analyse('subjects',0,idx_good);
 
% show effects
grand_summary.full.subject.BMA.effects % average parameters
grand_summary.full.subject.BMA.significance % corresponding pvalue (t-test grp level)

SG_report(grand_summary.full)

