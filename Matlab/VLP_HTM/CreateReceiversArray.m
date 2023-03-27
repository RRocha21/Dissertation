function [ Receivers ] = CreateReceiversArray( nx, ny, Ar, Ts, n, Psi, R, Lx, Ly )
%CREATERECEIVERSARRAY Creates a regularly spaced array of nx x ny receivers in a area of Lx x Ly
%
%   Receivers = CreateReceiversArray( nx, ny, Ar, Ts, n, Psi, Lx, Ly )
%
%   nx, ny      - dimension (in number) of the array on x and y directions
%   Ar          - receiver's sensing area
%   Ts          - receiver filter gain
%   n           - receiver's internal refractive index
%   Psi         - Hemi-FOV
%   Lx, Ly      - physical dimensions (length and width) of the array.

n_Receivers = nx * ny;

Receivers = newReceivers(n_Receivers, Ar, Ts, n, Psi, R);

% Base position is at (0,0,0), looking up (no change in the axis
% orientation)
HTM_R_base = Trans3(0,0,0);

xvals = (1/(2*nx):1/nx:1)*Lx;

yvals = (1/(2*ny):1/ny:1)*Ly;

for ix = 1:nx
    for iy = 1:ny
        % Compute receiver HTM
        ri = iy + ny*(ix-1);
        Receivers(ri).HTM = Trans3(xvals(ix),yvals(iy),0)*HTM_R_base;
    end
end

end

