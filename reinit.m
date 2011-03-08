
phi = randn(N,J,R);

% renormalize
for j = 1:J
    phi(:,j,:) = phi(:,j,:) / sqrt(sum(sum(phi(:,j,:).^2)));
end

update = 1;

