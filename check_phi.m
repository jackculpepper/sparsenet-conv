
randn('seed',1);

N = 2;
S = 5;
J = 4;
R = 3;
P = S+R-1;

a = randn(J,P);

phi = randn(N,J,R);

x0 = randn(N,S);

tic
checkgrad('objfun_phi', phi(:), 0.01, x0, a)
toc

