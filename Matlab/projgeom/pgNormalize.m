function [ Mn ] = pgNormalize( M )
% PGNORMALIZE Normalize a vector or an array in homogeneous coordinates
%   Mn = pgNormalize( M )
%
%   The vector or array M contains one or more points, one per column. 
%   Normalization corresponds to scale all elements of each point, such
%   that the last coordinate is 1. 

nlines = size(M,1);

Mnl = repmat(M(nlines,:),nlines,1);
Mn = M ./ Mnl;

end

