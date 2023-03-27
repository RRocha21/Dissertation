% Demonstrates the usage of HTM based VLP code
% 
% The script will create an array of emitters and a VLP sensor.
%
% It then plots the received intensity with the sensor at different
% location in the room's floor.

%% Prepare the workspace

% add the path to the projective geometry functions
addpath('..\projgeom\');

% Define the model default values

% Emitters
n_Emitters = 3;         % Number of emitters
Pb = 1 ;                % Transmitted power
m = 5 ;                 % Lambertian mode number

% Receivers:
Np = 5;                % Number of parallels in the sensor
Nm = 6;                % Number of meridians in the sensor
n_Receivers = Np*Nm;    % Number of receivers
Ar = 0.01;              % Active receiving area
Ts = 1;                 % Optical filter gain
n = 1;                  % Receiver's internal refractive index
R = 1;                  % Receiver's responsivity
Psi = pi/4;             % Hemi-Fov



%% Create and populate data structures

% Create the emitters array:
Emitters = newEmitters(n_Emitters,Pb,0,m);

% Create the receiver structure:
Receivers = newReceivers(n_Receivers,Ar, Ts, n, Psi, R);

%% Place emitters and receivers in 3D space

% Considering a room with 3mx3mx2m (WxLxH).

% Emitters are placed at the ceiling, looking down and in a circle of
% radius=0.5m

Em_Base_HTM = Trans3(1.5,1.5,2)*RotX3(pi);      % Base HTM at the center of the ceiling. 

Emitters(1).HTM = Em_Base_HTM*Trans3(0.5,0,0);
Emitters(2).HTM = Em_Base_HTM*RotZ3(2*pi/3)*Trans3(0.5,0,0);
Emitters(3).HTM = Em_Base_HTM*RotZ3(4*pi/3)*Trans3(0.5,0,0);

% Receivers are organized in Parallel and Meridians arragement of photo
% detectors, with Nm Meridians and 3 Parallels, in a sphere with
% radius=0.25
PDSensor = vlpCreateSensorParMer(Receivers, Np, Nm, 0.25);

% The sensor is initially placed at point (X,Y) = (0.5,3)
PDSensor = vlpMoveSensor(PDSensor,Trans3(0.5,3,0));

%% Compute A, B and F matrices

A = Receiver2A(PDSensor);
B = Emitter2B(Emitters);
F = EmitRec2F(Emitters, PDSensor);

%% Compute the received power

Pt_v = [Emitters.Pb]';
Pr = A*F*B*Pt_v;

% Get the max value. It will be used for scaling the received power
% graphics
MaxPr0 = max(Pr);

% Update the PDSensor received power
for i=1:numel(PDSensor)
    PDSensor(i).Pr = Pr(i)
end

k = 0.2;

%% Plot Emitters and receivers

% Plot the emitters and receivers position
if(isgraphics(1))
    clf(1)
else
    figure(1)
end
figure(1)
PlotHTMArray(Emitters);
PlotHTMArray(PDSensor);
view(3)
axis 'equal'
grid on
% Adjust the point of view
view(-38,8);

% Plot with received power intensity
if(isgraphics(2))
    clf(2)
else
    figure(2)
end
figure(2)
PlotHTMArray(Emitters);
PlotHTMArrayPr(PDSensor,k);
view(3)
axis 'equal'
grid on

% Move the sensor, compute new received power and plot received power
% intensity
for position=1:3
    PDSensor = vlpMoveSensor(PDSensor,Trans3(1,-1,0));
    % Recompute the F matrix
    F = EmitRec2F(Emitters, PDSensor);
    
    % Compute received power
    Pt_v = [Emitters.Pb]';
    Pr = A*F*B*Pt_v;

    % Get the new max valuefor scaling the received power plot
    MaxPr = max(Pr);

    % Update the PDSensor received power
    for i=1:numel(PDSensor)
        PDSensor(i).Pr = Pr(i);
    end
    
    % Plot the receiver power intensities, scaled
    PlotHTMArrayPr(PDSensor,k*MaxPr/MaxPr0);

end
% Adjust the view in figure 2
view(-54,12);
