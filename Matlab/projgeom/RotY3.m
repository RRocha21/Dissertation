function M = RotY3(beta)
% ROTY3 Rotation of an angle beta around Y axis.
%   M = RotY3(beta)
%
%   Rotation angle is defined in a counterclockwise direction when looking
%   towards the origin, i.e., following the right hand screw rule. 
%   (Weisstein, Eric W. "Rotation Matrix." From
%   MathWorld--A Wolfram Web Resource. http://mathworld.wolfram.com/RotationMatrix.html)

M = [ cos(beta)      0         sin(beta)    0
         0           1             0        0
     -sin(beta)      0         cos(beta)    0
         0           0             0        1 ];
 return
 