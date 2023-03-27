% DEFINESPACE Define variables for the simulation space

addpath('./../../projgeom/');

%% Define base values

% Room dimensions
Lx = 3;
Ly = 3;
Lz = 2; 


% Floor grid
%dx = 0.05;
%dy = 0.05; 

xvals = 0:dx:Lx;
yvals = 0:dy:Ly;

nx = numel(xvals);
ny = numel(yvals);

