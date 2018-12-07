load ../data/diamond.mat
plot(diamond,'.-','Color',[.7 0 0])


xlim([0 90])
g=gca;

g.XLabel.String = 'item number' ;
g.YLabel.String = 'target force (%MVC)' ;

g.YTick = 0:.2:1.2;
g.XTick = [1 30 60 90];

pretty.plot('../figures/diamond',[9 8])