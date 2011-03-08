
randn('seed',1);

N = 2;
S = 7;
J = 3;
R = 4;
P = S+R-1;

lambda = 10;

a = randn(J,P);
phi = randn(N,J,R);
x = randn(N,S);

tic
checkgrad('objfun_a_conv', a(:), 0.01, x, phi, lambda)
toc


if 0

    for p = 1:P
        a = zeros(J,P);
        a(1,p) = 1;


        EI1 = zeros(N,S);
        for t = 1:R
            EIt = phi_r(:,:,t)*a;

            srt = R+1-t;
            fin = R+S-t;
    
            EI1 = EI1 + EIt(:,srt:fin);
        end

        figure(11); colormap(gray);
        imagesc(EI1, [mn mx]);

        EI2 = Theta * a(:);
        figure(14); colormap(gray);
        imagesc(reshape(EI2, S, N)', [mn mx]);

        drawnow
        pause
    end
end


