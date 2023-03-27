function M = RotX3(alpha)
% ROTX3 Rotation of an angle alpha around X axis.
%   M = RotX3(alpha)
%
%   Rotation angle is defined in a counterclockwise direction when looking
%   towards the origin, i.e., following the right hand screw rule. 
%   (Weisstein, Eric W. "Rotation Matrix." From
%   MathWorld--A Wolfram Web Resource. http://mathworld.wolfram.com/RotationMatrix.html)

M = [1        0          0        0
     0    cos(alpha) -sin(alpha)  0
     0    sin(alpha)  cos(alpha)  0
     0        0           0       1];
 return
 