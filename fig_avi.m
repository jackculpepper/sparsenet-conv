
paramstr = 'polytrode_highpass_P434_J=025_R=051_N=051_20100224T202543';
paramstr = 'polytrode_highpass_P434_J=025_R=051_N=051_20100225T193400';

eval(sprintf('load state/%s/params.mat', paramstr));

outfile = sprintf('state/%s/bf.avi',paramstr);
infile = sprintf('state/%s/bf_up=%%06d.png',paramstr);

mx = floor(update/1000)*1000+1

%saveavi(outfile, infile, 1, 1000, 35401);
saveavi(outfile, infile, 1, 1000, mx);

