clear

randn('seed',1);
rand('seed',1);

N = 64;		% number of sources
S = 64;		% time points in original sources 
J = 96;		% number of basis functions for source generation
R = 50;		% number of time points in basis functions generating sources

P = S+R-1;	% number of selection locations for source generation

Jrows = 48;

save_every = 200;
display_every = 100;
reload_every = 20;

dataid = 'auditorydata3';
dataid = 'polytrode_highpass_P436';
dataid = 'zebramovie';
srate = 15;

datatype = 'vid075';

switch datatype
    case 'vid075'
        data_root = '../data/vid075-whiteframes';
        data_root = '../data/vid075-chunks';
        num_chunks = 56;

        Nsz = sqrt(N);

        Fr = 128;
        Fc = 128;
        Ft = 64;

        buff = 4;

        topmargin = 15;
end

mintype_inf = 'minFunc';
mintype_inf = 'minimize';
mintype_inf = 'mintotol';
%mintype_inf = 'gd';

mintype_lrn = 'minimize';
lrn_searches = 3;
mintype_lrn = 'gd';

lambda = 0.7;

gamma = 0.001;
gamma = 0;

eta = 0.01;

eta_up = 1.01;
eta_down = 0.99;
eta_log = [];

target_angle = 0.05;
target_angle = 0.01;


paramstr = sprintf('%s_J=%03d_R=%03d_N=%03d_%s', ...
                   dataid, J, R, N, datestr(now,30));


reinit


num_trials = 1000;

for q = 1:20
    sparsenet
    phi = timeshift_phi(phi);
end

for q = 1:20
    sparsenet
    phi = timeshift_phi(phi);
    target_angle = target_angle * 0.9;
end

sparsenet

