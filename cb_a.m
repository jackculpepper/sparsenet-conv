function [stop,user_data] = cb_a(x,iter,state,user_data,opts)

flag_debug = 0;

switch state
    case 'init'
        user_data.f = zeros(1,opts.maxits);
        user_data.x = zeros(length(x),opts.maxits);
        user_data.its = 0;
    case 'iter'
        user_data.f(iter.it) = iter.f;
        user_data.x(:,iter.it) = x;
        user_data.its = user_data.its + 1;

        if flag_debug
            sfigure(5);
            bar(user_data.x(:,iter.it));
            axis tight;
            drawnow;
        end

        fprintf('\rIteration %4d\tf: %-8.6g', iter.it, iter.f);
    case 'done'
        user_data.f = user_data.f(1:user_data.its);
        user_data.x = user_data.x(:,1:user_data.its);

        fprintf('\r');
end

stop = 0;

