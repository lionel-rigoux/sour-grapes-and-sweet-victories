function SG_simulate_bootstrap(N,restricted,idx)

if nargin==0
    N = 100 ;
end

[dummy_subject] = SG_draw_dummy_subject(N,restricted,idx);

system('mkdir -p ../results/bootstrap/');
for i=1:N
    data = SG_simulate_H0(dummy_subject(i));
    save(sprintf('../results/bootstrap/data_dummy_s%03d_r%d.mat',i,restricted),'data');
end

