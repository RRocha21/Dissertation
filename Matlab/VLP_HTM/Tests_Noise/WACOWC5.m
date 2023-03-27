
% General conditions:
interactive = 0;
usegraphics = 0;

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
Wstep = W/25;
Lstep = L/25;

% Number of repetitions
Nrep = 5;


%% Define experiment conditions

% Emitters
n_Emitters = 2;         % Number of emitters
Pb = 0.5 ;                % Transmitted power
Ps = 0.025;


% Half-power angles
HPA_v = [ 60 ];

% Lambertian mode number
m_v =  -log(2) ./ log(cosd(HPA_v));                  

% Receivers:

% Sensor configuration in meridians and parallels
NmNp = ...
  [12 3
  16 4
  20 5
  24 6
  28 7
  32 8
  36 9
  40 10
  44 11
  48 12
  52 13
  56 14
  60 15];

Psi_v = [1 1.25 1.5 1.75 2 2.25 2.5 2.75 3 3.5 4 4.5 5];             % Hemi-Fov
Ar = 1e-6;              % Active receiving area
Ts = 1;                 % Optical filter gain
n = 1;                  % Receiver's internal refractive index
R = 1;                  % Receiver's responsivity

validReadingThreshold = -Inf;

Psi_mode = 2;         % Use FOVmax = 2*FOVmin
