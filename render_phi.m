function array = render_phi(phi, m)

[N J R] = size(phi);

buf=1;

n = J/m;

array = -ones(buf+m*(N+buf),buf+n*(R+buf));

k = 1;

for i = 1:m
    for j = 1:n
        %bf = flipud(squeeze(phi(:,k,:)));
        bf = squeeze(phi(:,k,:));
        clim = max(abs(bf(:)));

        array(buf+(i-1)*(N+buf)+[1:N],buf+(j-1)*(R+buf)+[1:R]) = bf/clim;

        k = k+1;
    end
end

