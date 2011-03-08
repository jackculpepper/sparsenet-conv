
for t = 1:num_trials

    %% select data
    switch datatype
        case 'vid075'
            if reload_every == 1 || mod(update, reload_every) == 1 || update == 1
                % choose a movie for this batch
                j = ceil(num_chunks*rand);
                data = read_chunk(data_root, j, Fc, Ft);
                fprintf('loading chunk %d\n', j);
            end

            X = zeros(N,S);
            f = 1 + ceil((Ft - S)*rand);

            r = topmargin+buff+ceil((Fr-Nsz-(topmargin+2*buff))*rand);
            c =           buff+ceil((Fc-Nsz-           2*buff) *rand);

            X = reshape(data(r:r+Nsz-1,c:c+Nsz-1,f:f+S-1), N, S);

            %% subtract the mean and stretch to unit variance
            X = X - mean(X(:));
            X = X / std(X(:));
    end


    %% compute the map estimate
    tic

    a0 = zeros(J, P);
    switch mintype_inf
        case 'minimize'
            a1 = minimize(a0(:), 'objfun_a_conv', 10, X, phi, lambda);
            a1 = reshape(a1,J,P);
        case 'mintotol'
            a1 = mintotol(a0(:), 'objfun_a_conv', 100, 0.01, X, phi, lambda);
            a1 = reshape(a1,J,P);
    end

    time_inf = toc;


    %% reconstruct
    EI = zeros(N,S);
    for r = 1:R
        EIr = phi(:,:,r)*a1;

        srt = R+1-r;
        fin = R+S-r;

        EI = EI + EIr(:,srt:fin);
    end

    %% compute snr
    E = X - EI;
    snr = 10 * log10 ( sum(X(:).^2) / sum(E(:).^2) );

    switch mintype_lrn
        case 'minimize'
            [obj0,g] = objfun_phi(phi(:), X, a1, gamma, EI, dphi);

            phi1 = minimize(phi(:), 'objfun_phi', lrn_searches, X, a1, gamma, EI, dphi);
            phi1 = reshape(phi1,N,J,R);

            [obj1,g] = objfun_phi(phi1(:), X, a1, gamma, EI, dphi);

            phi = phi1;

        case 'gd'

            [obj0,g] = objfun_phi(phi(:), X, a1);
            dphi = reshape(g, N, J, R);

            phi1 = phi - eta * dphi;

            [obj1,g] = objfun_phi(phi1(:), X, a1);
            
            % pursue a constant change in angle
            angle_phi = acos(phi1(:)' * phi(:) / sqrt(sum(phi1(:).^2)) / sqrt(sum(phi(:).^2)));
            if angle_phi < target_angle
                eta = eta*eta_up;
            else
                eta = eta*eta_down;
            end


            if obj1 > obj0
                fprintf('objective function increased\n');
            else
                phi = phi1;
            end
    end


    %% truncate the log
    eta_log = eta_log(1:update-1);
    %% append
    eta_log = [ eta_log ; eta ];

    %% renormalize basis functions to have unit length
    for j = 1:J
        phi(:,j,:) = phi(:,j,:) / sqrt(sum(sum(phi(:,j,:).^2)));
    end

    %% compute the objective function after renormalization
    [obj2,g] = objfun_phi(phi(:), X, a1);
    
    fprintf('%s up %06d', paramstr, update);
    fprintf(' obj0 %.4f obj1 %.4f obj2 %.4f ang %.4f', ...
            obj0, obj1, obj2, angle_phi);
    fprintf(' snr %.4f eta %.8f inf %.4f\n', snr, eta, time_inf);

    if display_every == 1 || mod(t,display_every) == 1

        %% display image, reconstruction, error
        switch datatype
            case 'vid075'
                figure(10); clf; colormap(gray);

                %% reformat for displaying a sequence of 2d frames
                Xs  = zeros(Nsz, Nsz+1, S);
                Xs(:,1:Nsz,:) = reshape(X, Nsz, Nsz, S);
                Xs = reshape(Xs, Nsz, (Nsz+1)*S);
                EIs = zeros(Nsz, Nsz+1, S);
                EIs(:,1:Nsz,:) = reshape(EI, Nsz, Nsz, S);
                EIs = reshape(EIs, Nsz, (Nsz+1)*S);
                Es = Xs - EIs;

                mn = min([Xs(:) ; EIs(:) ; Es(:)]);
                mx = max([Xs(:) ; EIs(:) ; Es(:)]);

                subp(3,1,1); imagesc(Xs, [mn mx]); axis image off;
                subp(3,1,2); imagesc(EIs, [mn mx]); axis image off;
                subp(3,1,3); imagesc(Es, [mn mx]); axis image off;

            otherwise
                figure(10); clf;

                mn = min([X(:) ; EI(:) ; E(:)]);
                mx = max([X(:) ; EI(:) ; E(:)]);

                subp(3,1,1); imagesc(X, [mn mx]); axis image off; colorbar;
                subp(3,1,2); imagesc(EI, [mn mx]); axis image off; colorbar;
                subp(3,1,3); imagesc(E, [mn mx]); axis image off; colorbar;
        end

        %% display coefficients
        figure(6); imagesc(a1);

        %% display basis functions
        switch datatype
            case 'vid075'
                %% render as sequence of 2d frames
                array = render_phi_2d(phi, Jrows);
            otherwise
                array = render_phi(phi, Jrows);
        end

        figure(7); imagesc(array); axis image off; colormap(gray);

        %% plot our dynamic eta
        figure(8);
        plot(eta_log)

        drawnow;
    end

    
    if (save_every == 1 || mod(update,save_every) == 1)

        %% make the output directory
        [sucess,msg,msgid] = mkdir(sprintf('state/%s', paramstr));

        %% write the basis functions as a png
        %% max(abs(array)) <= 1 and there are 64 entries in a colormap, so..
        imwrite((array+1)*32, colormap, ...
            sprintf('state/%s/bf_up=%06d.png',paramstr,update), ...
            'png');
    
        %% save the basis functions as a matlab variable
        eval(sprintf('save state/%s/phi.mat phi', paramstr));

        %% save all other useful parameters to a separate matlab file
        saveparamscmd = sprintf('save state/%s/params.mat', paramstr);
        saveparamscmd = sprintf('%s lambda', saveparamscmd);
        saveparamscmd = sprintf('%s gamma', saveparamscmd);
        saveparamscmd = sprintf('%s eta', saveparamscmd);
        saveparamscmd = sprintf('%s eta_up', saveparamscmd);
        saveparamscmd = sprintf('%s eta_down', saveparamscmd);
        saveparamscmd = sprintf('%s eta_log', saveparamscmd);
        saveparamscmd = sprintf('%s J', saveparamscmd);
        saveparamscmd = sprintf('%s R', saveparamscmd);
        saveparamscmd = sprintf('%s datatype', saveparamscmd);
        saveparamscmd = sprintf('%s mintype_inf', saveparamscmd);
        saveparamscmd = sprintf('%s mintype_lrn', saveparamscmd);
        saveparamscmd = sprintf('%s update', saveparamscmd);
        saveparamscmd = sprintf('%s reload_every', saveparamscmd);
        eval(saveparamscmd);

        %% save the coefficient and image/reconstruction/error figures
        saveas(6, sprintf('state/%s/activation.png', paramstr));
        saveas(10, sprintf('state/%s/reconstruction.png', paramstr));
    end


    update = update + 1;
end

