function [ F ] = EmitRec2F( Emitters, Receivers )
%EMITREC2F Compute the F matrix from emitter and receiver data.
% 
% Emitter and receiver data are stored in struct arrays.

% Extract the position and orientation vectors from the HTMs

%% Extract the arrays with position and orientation vectors for emitters and receivers

% Input: 
%
% - Emitters: an array of Emitters struct 
% - Receivers: an array of Receivers struct

n_Emitters = numel(Emitters);

% Extract the HTMs from the struct array
HTM_E = [ Emitters.HTM ];

% and reshape in a 3-D array
HTM_E = reshape(HTM_E,4,4,n_Emitters);

% p_E holds the position vectors of the emitters
%
% One of the dimensions is superfluous. Remove it with squeeze()
p_E = squeeze(HTM_E(1:3,4,:));

% n_E holds the orientation vectors of the emitters
n_E = squeeze(HTM_E(1:3,3,:));


n_Receivers = numel(Receivers);

% Extract the HTMs from the structure array:
HTM_R = [ Receivers.HTM ];

% and reshape in a 3-D array
HTM_R = reshape(HTM_R,4,4,n_Receivers);

% Get the position vectors for receivers
p_R = squeeze(HTM_R(1:3,4,:));

% n_R holds the orientation vectors of the receivers
n_R = squeeze(HTM_R(1:3,3,:));


%% Compute the distance matrix

% Matrix with the receivers position 
%
% The position vector of receivers should be replicated along the columns
% (3rd coord of the 3D matrix).
Mp_R = repmat(p_R,[1 1 n_Emitters]);

% Matrix with the receivers orientation 
%
% The orientation vector of receivers should be replicated along the columns
% (3rd coord of the 3D matrix).
Mn_R = repmat(n_R,[1 1 n_Emitters]);


% Matrix with the emitters position
%
% The position vector of emitters should be replicated along the lines
% (2nd coord of the 3D matrix).
Mp_E = repmat(p_E,[1 1 n_Receivers]);
Mp_E = permute(Mp_E, [1 3 2]);

% Matrix with the emitters orientation
%
% The orientation vector of emitters should be replicated along the lines
% (2nd coord of the 3D matrix).
Mn_E = repmat(n_E,[1 1 n_Receivers]);
Mn_E = permute(Mn_E, [1 3 2]);


% Compute the difference matrix
% Delta(1:3,i,j) is the vector from the i-th receiver to the j-th emitter
Delta = Mp_E - Mp_R;

% Compute the matrix with the distances
% Dist(i,j) contains the distance from the i-th receiver to the j-th
% emitter
DistSquared = dot(Delta,Delta);
Dist = sqrt(DistSquared);


% u is the matrix with the versors of the directions from Receivers to
% Emitters
%
% u(:,i,j) contains the versor of the direction from the i-th receiver to
% the j-th emitter
DistRep = repmat(Dist,[3 1 1]);
u = Delta ./ DistRep;

%% Compute the terms for the final result

% Mm is the matrix with the m_j terms for the exponent of the Lambertian
% model
mv = [ Emitters.m ];
Mm = repmat(mv,[n_Receivers 1]);

F2 = squeeze(dot(Mn_E,-u)).^Mm;

F3 = squeeze(dot(Mn_R,u));

F4 = 1./squeeze(DistSquared);

Psiv = [ Receivers.Psi ]';
McPsi = cos(repmat(Psiv,[1 n_Emitters ]));

F = (F3 > McPsi).*F2.*F3.*F4;


end

