function P = PersProjMatrix(alpha_u, alpha_v, u0,v0)
% PERSPROJMATRIX Computes the Perspective Projection Matrix from camera parameters
% P = PersProjMatrix(alpha_u, alpha_v, u0,v0)
%
%   Computes the Perspective Projection Matrix based on length of the focal
%   distance expressed in horizontal and vertical pixels.
%
%    alpha_u, alpha_v : size of focal distance in horizontal and vertical
%                       pixels, repectively
%    u0, v0           : coordinates of focal point in retinal plane
%
%   If u0 and v0 are ommitted, they are considered to be null.

if (nargin == 2) 
  u0 = 0;
  v0 = 0;
 end


P = [alpha_u    0       u0  0
        0     alpha_v   v0  0 
        0       0       1   0];

return;