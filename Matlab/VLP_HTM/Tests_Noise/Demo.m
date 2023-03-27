%% General conditions:
interactive = 1;
usegraphics = 1;

% when rectifyIndication==1, the transimpedance
% circuit will rectify the results, eliminating
% negative results.
rectifyIndication = 1;    

% Define the model default values

% Room dimensions
W = 4;
L = 4;
H = 2.5;

% Steps for travelling the room
Wstep = W/10;
Lstep = L/10;

% Number of repetitions
Nrep = 5;


%% Define experiment conditions

% Emitters
n_Emitters = 2;         % Number of emitters
Pb = 0.5 ;                % Transmitted power
Ps = 0.025;


% Half-power angles
HPA_v = [ 60 45 ];

% Lambertian mode number
m_v =  -log(2) ./ log(cosd(HPA_v));                  

% Receivers:

% Sensor configuration in meridians and parallels
NmNp = ...
  [32 8
  48 12 
  64 16];

Psi_v = [pi/18 pi/12 ];             % Hemi-Fov
Ar = 1e-6;              % Active receiving area
Ts = 1;                 % Optical filter gain
n = 1;                  % Receiver's internal refractive index
R = 1;                  % Receiver's responsivity

validReadingThreshold = 8;


