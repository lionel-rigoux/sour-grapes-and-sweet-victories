function [  ] = SG_plotPairingV2V3( iSubject )

data = SG_load_data;
nSubject = length(data);
data = data(setdiff(1:nSubject,SG_exclude())); % remove outliers
version = vertcat(data.version);
idx_version = str2num(version(:,2));
idx_version(idx_version>1) = 5-idx_version(idx_version>1);


temp = [data(iSubject).rating(1,:); data(iSubject).target]';
pairing = sortrows(temp, 1);


plot(pairing(:, 2),'.-','Color',[.7 0 0]);
hold on;
plot(pairing(:, 3),'.-','Color',[0 0 1]);
xlim([0 90]);
ylim([0.2 1.2]);
g=gca;

g.XLabel.String = 'item number' ;
g.YLabel.String = 'target force (%Fmax)' ;

g.YTick = 0:.2:1.2;
g.XTick = [1 30 60 90];

 pretty.plot('../figures/pairing',[9 8])