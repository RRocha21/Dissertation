function plot3Drefaxis(K)
% PLOT3DREFAXIS Plots the referential basis defined by homogeneous transformation matrix K.
%
%   Plot3dRefAxis(K) plots the 3 base vectors (x, y, z) of the
%   transformation defined by HTM K in a 3D space. x and y axis are printed
%   in blue; z axis is printed in red.
%
%   For better visualization, axis('equal') should be enforced. 

s='b';

% Stores the current hold state
holdstate=ishold;

% Draw the 3 vectors
for i=1:3
  if i==3
    s='r';
  end
  h = quiver3(K(1,4),K(2,4),K(3,4),K(1,i),K(2,i),K(3,i),s);
  set(h,'Linewidth',1);
  % Force hold for j and k vectors
  hold on
end


% restore hold state
if holdstate==1
  hold on
else
  hold off
end
 
return;