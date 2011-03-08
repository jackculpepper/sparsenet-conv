% read_chunk.m - function to read a movie chunk
%
% function F = read_chunk(dataroot,i,imsz,imszt)

function F = read_chunk(dataroot,i,imsz,imszt)

filename = sprintf('%s/chunk%d',dataroot,i);
fid = fopen(filename,'r','b');
F = reshape(fread(fid,imsz*imsz*imszt,'float'),imsz,imsz,imszt);
fclose(fid);
