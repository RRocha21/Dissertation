function [ a , b ] = factorise2( n )
%FACTORISE2 Computes two factors that, multiplied, result in n
%

% Factorize n...
f = factor(n);


% and aggregate the result in two terms:
% - one with the odd terms of f
a = prod(f(1:2:numel(f)));
% - the other with the even terms
b = prod(f(2:2:numel(f)));


end

