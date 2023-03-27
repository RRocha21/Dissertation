function M = RotZ3(gamma)
% ROTZ3 Rotation of an angle gamma around Z axis.
%   M = RotZ3(gamma)
%
%   Rotation angle is defined in a counterclockwise direction when looking
%   towards the origin, i.e., following the right hand screw rule. 
%   (Weisstein, Eric W. "Rotation Matrix." From
%   MathWorld--A Wolfram Web Resource. http://mathworld.wolfram.com/RotationMatrix.html)

M = [ cos(gamma)    -sin(gamma)     0       0
      sin(gamma)     cos(gamma)     0       0
           0             0          1       0
           0             0          0       1 ];
 return
 