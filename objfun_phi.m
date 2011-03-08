function [f,g] = objfun_phi(phi0, I, a);


[J,P] = size(a);
[N,S] = size(I);
R = length(phi0(:)) / (N*J);

phi = reshape(phi0, N, J, R);

EI = zeros(N,S);
for t = 1:R
    EIt = phi(:,:,t)*a;

    srt = R+1-t;
    fin = R+S-t;

    EI = EI + EIt(:,srt:fin);
end

E = I - EI;

f = 0.5*sum(E(:).^2);

dphi = zeros(size(phi));
for t = 1:R
    srt = R+1-t;
    fin = R+S-t;

    dphi(:,:,t) = dphi(:,:,t) - E*a(:,srt:fin)';
end

g = dphi(:);

