function PlotHTMArray( HTMarray )
%PLOTHTMARRAY Plots the HTMs in a struct array
%   PLOTHTMARRAY(HTMarray) plots the HTM in the struct array HTMarray.
%
%   HTMarray is a struct array where the struct contains a field, called
%   HTM, a 4x4 array representing a Homogeneous Transformation Matrix.
%   
%   X and y axes are plotted in blue; z axis is plotted in red.
%
%   See also PLOT3DREFAXIS

%   pf@ua.pt

% hh is an array with all HTMs, side by side
hh = [HTMarray.HTM];

% Get the position vectors, corresponding to HTM(1:3,4)
% p is a matrix where each column is the respective position vector
p = hh(1:3,4:4:size(hh,2));

% Get the x, y and z coords of the reference frame axes associated to the
% HTMs
x = hh(1:3,1:4:size(hh,2));
y = hh(1:3,2:4:size(hh,2));
z = hh(1:3,3:4:size(hh,2));

hold on

% Plot the x and y axes vectors
quiver3(p(1,:),p(2,:),p(3,:),x(1,:),x(2,:),x(3,:),0,'b')
quiver3(p(1,:),p(2,:),p(3,:),y(1,:),y(2,:),y(3,:),0,'b')

% Plot the z axis vectors
quiver3(p(1,:),p(2,:),p(3,:),z(1,:),z(2,:),z(3,:),0,'r')

end

