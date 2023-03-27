function [ irrad_angle, incid_angle, r ] = irradIncid( H_E, H_R )
% IRRADINCID Computes the irradiation and incidence angles
%   [ irrad_angle, incid_angle, r ] = irradIncid( H_E, H_R )
%
%   Computes the irradiation and incidence angles for a light source and a
%   receiver, where H_E and H_R are the Homogeneous Transformation Matrices
%   describing, respectively, the emitter and receiver position and
%   orientation. Both emitter and receiver main axes are aligned with z
%   axis.
%
%   r is the distance from emitter to receiver.

% Compute the vector from Emitter to Receiver

l = H_R(1:3,4) - H_E(1:3,4);
r = norm(l);

% Extract the coordinates of the z axis versor in both HTM:
k_E = H_E(1:3,3);
k_R = H_R(1:3,3);

% Compute the irradiance angle
irrad_angle = acos(dot(k_E,l)/(norm(k_E)*r));

% and the incidence angle. In this case, the vector direction is reversed. 
incid_angle = acos(dot(k_R,-l)/(norm(k_R)*r));


end

