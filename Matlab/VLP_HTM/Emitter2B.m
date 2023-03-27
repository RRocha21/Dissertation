function [ B ] = Emitter2B( Emitters )
%EMITTER2B    Compute B matrix from emitters data
%   B = Emitter2B(Emitters) is a diagonal matrix with emitter data. Emitters
%   is a struct array with the emitters description
% 
%   B: matrix with emitter data
%   $b_{ij} = \frac{m_j+1}{2\pi} ~ \delta_{ij}$ 

% Bv is a vector with the b_ij elements
Bv = ([Emitters(:).m] + 1)/(2*pi);

nv = numel(Bv);

% B is a diagonal matrix, where the diagonal elements are the elements of
% Bv
%
% The sparse matrix is preferred for large numbers of emitters
% B = diag(Bv);
B = sparse(1:nv,1:nv,Bv);

end

