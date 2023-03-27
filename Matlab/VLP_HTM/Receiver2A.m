function [ A ] = Receiver2A ( Receivers )
% RECEIVER2A Computes the A matrix from an array of receivers struct data
% A Receiver2A ( Receivers ) 
%
% A: matrix with receiver data
% a_{ij} = A_{r,i} T_{s,i} \frac{n_i^2}{\sin^2(\Psi_{c,i})}, i=j

% Av is a vector with the a_j terms
Av = [Receivers(:).Ar].*[Receivers(:).Ts].*([Receivers(:).n]./sin([Receivers(:).Psi])).^2;

% Compute the diagonal matrix with receiver data. 
%
% When there are many receivers, the direct use of diag(Av) generates an
% excessively large matrix:
% A = diag(Av);
% Better use a sparse matrix:
mv = numel(Av);
A = sparse(1:mv,1:mv,Av);

end

