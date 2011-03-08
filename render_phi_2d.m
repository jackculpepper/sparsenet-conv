function array = render_phi_2d(phi, m)

[N J R] = size(phi);

Nsz = sqrt(N);

buf=1;

n = J/m;



array = -ones(buf+m*(Nsz+buf),buf+n*((Nsz+1)*R+buf));

k = 1;

for i = 1:m
    for j = 1:n

        phi_k = squeeze(phi(:,k,:));
        array_k = zeros(Nsz, Nsz + 1, R);
        array_k(:,1:Nsz,:) = reshape(phi_k, Nsz, Nsz, R);
        array_k = reshape(array_k, Nsz, (Nsz+1)*R);

        clim = max(abs(phi_k(:)));

        array(buf+(i-1)*(Nsz+buf)+[1:Nsz],buf+(j-1)*((Nsz+1)*R+buf)+[1:(Nsz+1)*R]) = array_k/clim;

        k = k+1;
    end
end

