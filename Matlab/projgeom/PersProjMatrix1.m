function P = PersProjMatrix1(f,u0,v0)
% PERSPROJMATRIX1 Computes the Perspective Projection Matrix from camera parameters
%   function P = ProjPersMatrix1(f,u0,v0)
%
%   Computes the Perspective Projection Matrix from the focal distance and
%   the coordinates of the focal point in retinal plane.
%   f      : focal distance
%   u0, v0 : coordinates of focal point in retinal plane.
%
% If u0 and v0 are ommitted, they are considered to be null.

if (nargin == 1) 
  u0 = 0;
  v0 = 0;
 end


P = [-f  0  u0  0
      0 -f  v0  0 
      0  0  1   0];

return;