function new_phi = timeshift_phi(phi)

[N J R] = size(phi);

center = 'mass';

mid = ceil(R/2);

new_phi = zeros(size(phi));

for j = 1:J
    switch center
        case 'mass'
            den = sum(sum(abs(phi(:,j,:))));
            ind = ceil(  sum([1:R]'.*squeeze(sum(abs(phi(:,j,:)), 1))) / den );
    end
    delta = mid - ind;
    if delta <= 0
        new_phi(:,j,1:end+delta) = phi(:,j,1-delta:end);
    elseif delta > 0
        new_phi(:,j,1+delta:end) = phi(:,j,1:end-delta);
    end
end