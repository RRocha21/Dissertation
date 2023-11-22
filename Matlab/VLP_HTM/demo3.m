% DEMO3 Interactive demo showing noise effects
% 
%   Displays a set of emitters at the ceiling and the value of the detected
%   power by a meridian/parallel sensor. The optical power received at each
%   photodiode is represented by the length of the vector in its position.
%
%   The value of the received power at each photodiode is a stochastic
%   variable. Every time the user presses the key [ENTER], a new value for
%   the stochastic variable is extracted and the plot is created. 
% 

% Prepare the workspace

clear all;
close all;

% add the path to the projective geometry functions
addpath('..\projgeom\');

% Define the model default values

%% Create the light emitters

% Emitters
n_Emitters = 8;         % Number of emitters
Pb = 0.5 ;                % Transmitted power
Ps = 0.0025;
m = 4;                  % Lambertian mode number

Emitters = newEmitters(n_Emitters,Pb,Ps,m);

% Considering a room with 3mx3mx2m (WxLxH).

Em_Base_HTM = Trans3(1.5,1.5,2)*RotX3(pi);      % Base HTM at the center of the ceiling. 

for i=1:n_Emitters
  Emitters(i).HTM = Em_Base_HTM*RotZ3(i*(2*pi)/n_Emitters)*...
    Trans3(0.25,0,0)*RotY3(pi/8);
end


% Plot the emitters position
if(isgraphics(1))
    clf(1)
else
    figure(1)
end
PlotHTMArray(Emitters);
axis([-0.5 3.5 -0.5 3.5 0 2.5]);
view(3);
grid on


%% Create the receivers


% Receivers:
Np = 10;                 % Number of parallels in the sensor
Nm = 3;                 % Number of meridians in the sensor
n_Receivers = Np*Nm;    % Number of receivers
Ar = 1e-6;              % Active receiving area
Ts = 1;                 % Optical filter gain
n = 1;                  % Receiver's internal refractive index
Psi = pi/4;             % Hemi-Fov
R = 1;                  % Receiver's responsivity

% Create the receiver structure:
Receivers = newReceivers(n_Receivers,Ar, Ts, n, Psi, R);
% Receivers are organized in Parallel and Meridians arragement of photo
% detectors, with Nm Meridians and 3 Parallels, in a sphere with
% radius=0.25
PDSensor = vlpCreateSensorParMer(Receivers, Np, Nm, 0.25,pi/8);

% The sensor is initially placed at point (X,Y) = (0.5,3)
PDSensor = vlpMoveSensor(PDSensor,Trans3(1.5,3,0));


hold on;
PlotHTMArray(PDSensor);
view(3);
axis('equal');
figure(1)

%% setup the values for computing received indication

% Quantities required for computation
%       Bw -      Bandwidth of receiver circuit
%       Z -       Vector with the transimpedance feedback resistors
%       s_i -     Vector with the operational amplifiers current PSD
%       s_v -     Vector with the operational amplifiers voltage PSD
%       Z_p -     Vector with the photo-diode equivalent impedances
%       Theta -   Thermodynamic temperature of feedback resistor, in Kelvin

Bw = 10e4;      % Bandwidth= 10kHz
Theta = 273+30;   % Feedback resistor at 30 degrees C

% Vector of ones for the receivers
nRec_v = ones(n_Receivers,1); 

s_i = 1.3e-15*nRec_v;    % Current noise "plateau" at 1.3 fA/sqrt(Hz)
s_v = 4.8e-9*nRec_v;     % Voltage noise "plateau" at 4.8 nV/sqrt(Hz)
Z = 1e6*nRec_v;          % Feedback resistors = 1M
Z_p = 100e6*nRec_v;      % PD equivalent impedace = 100 MOhm

%%  Compute received indication (mean and noise / variance)
[ Y nu ] = vlpRecIndication( Emitters, PDSensor, Bw, Z, s_i, s_v, Z_p, Theta );

%% Plot received indication


figure(2)
PlotHTMArray(Emitters);
axis([-0.5 3.5 -0.5 3.5 0 2.5]);
view(3);
grid on

Nu = repmat(nu,1,n_Emitters);

while(1)
  % Compute an estimate
  s = sqrt(Nu).*randn(size(Y));
  Ystar = Y + s;
  
  % Update total received power in the Receivers
  % Assuming that the signals received from the different Emitters are
  % uncorrelated
  Pr_v = sqrt(sum((Ystar.*Ystar),2))
  for i = 1:n_Receivers
    PDSensor(i).Pr = Pr_v(i);
  end
  
  % Plot the receivers' indications
  hx = PlotHTMArrayPr(PDSensor);
  
  resp = input('[ENTER] to continue, any value to stop...','s');
  if numel(resp) ~= 0
    display('Leaving...');
    break;
  end
  
  delete(hx)
  
end
