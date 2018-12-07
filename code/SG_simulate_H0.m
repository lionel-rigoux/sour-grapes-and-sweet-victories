function data = SG_simulate_H0(dummy_subject)

rng('shuffle');

% ===
inG.run_options.dynamics      = 0 ;
inG.run_options.choiceUpdate  = 0 ; 
inG.run_options.successUpdate = 0 ; 
inG.run_options.forceUpdate   = 0 ; 
inG.run_options.driftUpdate   = 0 ; 

inG.phi = dummy_subject.labeller;

l=load('../data/diamond.mat');
diamond = l.diamond;

u(1,:) = 1:90 ; % item idx 

u(2,:) = diamond ;
u(3,:) = diamond ;

if randn > 0
    shu1 = randperm(numel(diamond));
    shu2 = randperm(numel(diamond));
    u(2,:) = u(2,shu1) ;
    u(3,:) = u(3,shu2) ;
end
u(4:15,:) = nan ;

y = nan(9,90) ;

%%
% == generate first round
for t=1:90
    gx(:,t) = SG_g_model([],dummy_subject.phi,u(:,t),inG) ;
end

% == store data
% 1st rating
y(1:3,:) = gx(1:3,:) + dummy_subject.sig_r*randn(3,90); 
% 1st choice
y(4:5,:) = +(gx(4:5,:) > rand(2,90)) ; 
% 1st success
y(6:7,:) = y(4:5,:) .* (gx(6:7,:) > rand(2,90)) ; 
% 1st force
y(8:9,:) = y(6:7,:) .* (gx(8:9,:) + dummy_subject.sig_f*randn(2,90)) ;



%% checks

y(1:3,:) = min(max(y(1:3,:),0),100);
y(8:9,:) = max(y(8:9,:),0);

%% Save

data.dummy_subject = dummy_subject;

% target
data.target = u(2:3,:);
% ratings
data.rating = y(1:3,:); 
%choice
data.choice = y(4:5,:);
%choice
data.success = y(6:7,:);
%choice
data.force_max = y(8:9,:);       
    
