function [ H ] = pg2DcomputeProjTransf( M,m )
% PG2DCOMPUTEPROJTRANSF Computes the Projective Transformation Matrix given 4 pairs of points
%   [ H ] = pg2DcomputeProjTransf( M,m ) 
%
%   pg2DcomputeProjTransf computes the Projective Transformation Matrix H
%   from a set of 4 pairs of points. M is the array with the 4 object
%   points, m is the array with the 4 images. 
%
%   Each point corresponds to a column in M or m, in homogeneous
%   coordinates. M and m are related by m = H*M.
%
%   See: Faugeras, O. (2001). Three-dimensional computer vision: a
%   geometric viewpoint (4. print). Cambridge, Mass.: MIT Press.



% The matrix H contains 8 independent terms, h11, h12, ... , h32 (h33 = 1)
% Each pair of points provides 2 independent equations in the system
% A*h = b
% where the A and b terms are obtained from expanding
% m = H*M
% as a set of equations on the elements of H (h11, h12, h13, ...) where
% h33=1. 

if size(m) ~= size(M)
    error('matrices are of different size!')
end

% The equation system was derived considering the points in the afine plane
% (x3=1)
M = pgNormalize(M);
m = pgNormalize(m);

% Initialize A and b
A = zeros(8);
b = zeros(8,1);

% for all columns, i.e., for all pair of points in (M,m)
for i = 1:4
    % Each pair of points in M and m provides 2 independent equantions
    tmpA = [ M(1,i) M(2,i) 1      0     0    0 -M(1,i)*m(1,i) -M(2,i)*m(1,i) ;
                0      0   0   M(1,i) M(2,i) 1 -M(1,i)*m(2,i) -M(2,i)*m(2,i) ];
    
    A(2*i-1:2*i,:) = tmpA;
    
    b(2*i-1:2*i) = [ m(1,i); m(2,i) ];
end

size(A)
size(b)

% Compute the 8 independent h terms
% h = A^(-1)*b;
h = linsolve(A,b);

% Create H
H = ones(3);

% Assign the h terms to h. The assignment is first by column, then by line,
% so the resulting matrix needs to be transposed
H(1:8) = h(:);
H = H';
end

