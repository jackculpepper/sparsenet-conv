function [f,g] = objfun_a_conv(a0,I,phi,lambda);

[N J R] = size(phi);
 
S = size(I,2);

a = reshape(a0, J, S+R-1);
 
EI = zeros(N,S);
for t = 1:R
    EI = EI + phi(:,:,R-t+1)*a(:,t:t+S-1);
end

E = I - EI;

f_residual = 0.5*sum(E(:).^2);
f_sparse = lambda*sum(abs(a(:)));

%fprintf('f_residual %.4f f_sparse %.4f\n', f_residual, f_sparse);

f = f_residual + f_sparse;

da = zeros(size(a));
for t = 1:R
    srt = R+1-t;
    fin = S+R-t;

    da(:,srt:fin) = da(:,srt:fin) - phi(:,:,t)'*E;
end


if 0
    figure(8);
    imagesc(a); colorbar;
    drawnow

    figure(11); clf;
        
    X_n = reshape(I, S, N);
    EI_n = reshape(EI, S, N);
    E_n = reshape(E, S, N);

    mn = min([I(:) ; EI(:) ; E(:)]);
    mx = max([I(:) ; EI(:) ; E(:)]);
    for n = 1:N
        subp(N,1,n);
        plot(1:S,X_n(:,n),'b-', ...
             1:S,EI_n(:,n),'g-.', ...
             1:S,E_n(:,n),'r-');
        axis([1 S mn mx]);
        legend('Source', 'Estimate', 'Error');
        title(sprintf('Source %d', n));
    end
end


da = da + lambda*sign(a);

g = da(:);

