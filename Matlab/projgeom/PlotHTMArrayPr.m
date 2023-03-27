function h = PlotHTMArrayPr( HTMarray , varargin )
%PLOTHTMARRAYPR Plots the intensity perceived in an HTMarray
%   h = PLOTHTMARRAYPR(HTMarray) 
%   h = PLOTHTMARRAYPR(HTMarray, d) 
%   h = PLOTHTMARRAYPR(HTMarray, d, c) 
%
%   PLOTHTMARRAYPR plots received power Pr as a vector aligned with the z
%   axis of the respective HTM array. The intensity vectors are scaled for
%   a max size of d, which defaults to 1, if not provided. The vectors are
%   plotted in red, unless a different color code is given in c.
%
%   HTMarray is a struct array where the struct contains a field, called
%   HTM, a 4x4 array representing a Homogeneous Transformation Matrix.
%   
%   The function returns a handler to the newly created graphics

%   pf@ua.pt

% d is the default max size for the intensity vector. 
d = 1; 
if (nargin>=2)
    % max size of vector explicitely defined
    d = varargin{1};
end

% Default color is red.
c = 'r';
if (nargin>=3)
    % max size of vector explicitely defined
    c = varargin{1};
end

% Store the current hold state
holdstate = ishold;

% and force hold on
hold on;

% Get the maximum value of Pr to normalize the plot
M = max([HTMarray.Pr]);

% Start with empty origin and displacement vectors (for quiver3)
orig = [];
disp = [];

for e = HTMarray
    
    % Get the origin point of the HTM
    orig = [orig e.HTM(1:3,4)];
    
    % Get displacement
    % Displacement is scaled with the received power and the max size for
    % the intensity vector
    disp = [disp e.HTM(1:3,3)*e.Pr/M*d];

end

% Plot the vectors
h = quiver3(orig(1,:), orig(2,:), orig(3,:), disp(1,:), disp(2,:), disp(3,:),0,c);


end

