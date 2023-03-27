
% Plot radiation graph from Lambertian source using H0_ER
%
%   Plot of intensity as a function of irradiance angle (angle with the
%   emitter axis) for a Lambertian emitter of order m


addpath('./../../projgeom/');

% Define base values

% - m (Lambertian mode number)
% - Ar (receiver area) 
m = 1;
Ar = 1e-4;

% Emitter position and orientation: 
% Emiiter in the origin, aligned with x axis
HTM_E = RotY3(pi/2);

%% Compute the values

% Receiver initial position:
% at (1,0,0), directed towards the origin
HTM_R_base = Trans3(1,0,0)*RotY3(-pi/2);


angles = linspace(0, 2*pi);
p_r = zeros(size(angles));

% Iterate over angle values
for i = 1:numel(angles)
    % Compute receiver position and orientation
    HTM_R = RotZ3(angles(i)) * HTM_R_base;
    % Compute received power
    p_r(i) = H0_ER(HTM_E, HTM_R, m, Ar);
end



%% Show the results
figure(1)
h = polar(angles,p_r);
t = sprintf('Polar plot, m=%d',m);
title(t);
figure(gcf);
