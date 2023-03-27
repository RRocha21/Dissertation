function [ Receivers ] = CreateReceiversArray2( n_Receivers, Ar, Ts, n, Psi, R, Lx, Ly )
%CREATERECEIVERSARRAY2 Creates a regularly spaced array of n_Receivers receivers in a area of Lx x Ly
%
%   Receivers = CreateReceiversArray( n_Receivers, Ar, Ts, n, Psi, Lx, Ly )
%
%   n_Receivers - number of receivers
%   Ar          - receiver's sensing area
%   Ts          - receiver filter gain
%   n           - 
%   Psi         - Hemi-FOV
%   Lx, Ly      - physical dimensions (length and width) of the array.

[ nx, ny ] = factorise2(n_Receivers);

Receivers = CreateReceiversArray( nx, ny, Ar, Ts, n, Psi, R, Lx, Ly );