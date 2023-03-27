%% Sample code to demonstrate H0_ER function usage

% This code uses the Projective Geometry functions.

addpath('../ProjGeom/');

% Set emitter position at (0,0,1), pointing down
HTM_E = Trans3(0,0,1);
HTM_E(3,3) = -1;


% Set receiver position at (0,0,0), looking up.
HTM_R = Trans3(0,0,0);

%% Simplest form (g and T are not specificed, default to 1)
% Compute the channel gain H(0)
%
% Other parameters: 
% - m (Lambertian mode number) = 1
% - Ar (receiver area) = 1 cm² 
% g (receiver gain) and T (filter) default to 1. 
m=1;
Ar = 1e-4;
H0_ER(HTM_E, HTM_R, m, Ar)

%% Same as above, g is specificied as rect(). Defines a FOV

% H0_ER(HTM_E, HTM_R, m, Ar, @g)
% Deprecated; H0_ER does not use function pointers

% Move to a region where emitter is outside the FOV. Output should be zero

HTM_R = Trans3(0,5,0);
% H0_ER(HTM_E, HTM_R, m, Ar, @g)
% Deprecated; H0_ER does not use function pointers

% Calling H0_ER with a explicit FOV
FOV = pi/6;
H0_ER(HTM_E, HTM_R, m, Ar, FOV)

% Moving the receiver to a position where emitter is in the FOV
HTM_R = Trans3(0,0,0);
H0_ER(HTM_E, HTM_R, m, Ar, FOV)
