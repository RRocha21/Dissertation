% Animated demo of HTM based VLP simulation code
% 
% The script will create an array of emitters and a VLP sensor.
%
% It then plots the received intensity at the sensor as the sensor travels
% accross the room space.
% 


%% Prepare the workspace

% add the path to the projective geometry functions
addpath('..\projgeom\');

% Define the model default values

% Emitters
n_Emitters = 1;         % Number of emitters
Pt = 1 ;                % Transmitted power
m = 4;                  % Lambertian mode number

% Receivers:
Np = 5;                 % Number of parallels in the sensor
Nm = 6;                 % Number of meridians in the sensor
n_Receivers = Np*Nm;    % Number of receivers
Ar = 0.01;              % Active receiving area
Ts = 1;                 % Optical filter gain
n = 1;                  % Receiver's internal refractive index
Psi = pi/2;             % Hemi-Fov
R = 1;                  % Receiver's responsivity



%% Create and populate data structures

% Create the emitters array:
Emitters = newEmitters(n_Emitters,Pt,Pt,m);

% Create the receiver structure:
Receivers = newReceivers(n_Receivers,Ar, Ts, n, Psi, R);

%% Place emitters and receivers in 3D space

% Considering a room with 3mx3mx2m (WxLxH).

% Emitters are placed at the ceiling, looking down and in a circle of
% radius=0.5m

Em_Base_HTM = Trans3(1.5,1.5,2)*RotX3(pi);      % Base HTM at the center of the ceiling. 

Emitters(1).HTM = Em_Base_HTM*Trans3(0.5,0,0);
% Emitters(2).HTM = Em_Base_HTM*RotZ3(pi/2)*Trans3(0.5,0,0);
% Emitters(3).HTM = Em_Base_HTM*RotZ3(pi)*Trans3(0.5,0,0);
% Emitters(4).HTM = Em_Base_HTM*RotZ3(3*pi/2)*Trans3(0.5,0,0);

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
    PDSensor(i).Pr = Pr(i);
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
hx = PlotHTMArrayPr(PDSensor,k);
view(3)
axis 'equal'
axis([-0.5 3.5 -0.5 3.5 0 2])
grid on
view(-54,12);

%% Animate plot

% Move the sensor, compute new received power and plot received power
% intensity
for position=1:60
    PDSensor = vlpMoveSensor(PDSensor,Trans3(0.05,-0.05,0));
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
    
    pause(.1)
    figure(2)
    delete(hx)
    % Plot the receiver power intensities, scaled
    hx = PlotHTMArrayPr(PDSensor,k*MaxPr/MaxPr0);

end
