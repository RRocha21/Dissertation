close all;
clear all;
clc;

% add the path to the projective geometry functions
addpath('../../ProjGeom');
addpath('..');
addpath('../Classes')

%%room dimensions
H=2;

%% Emitters
n_Emitters = 3;         % Number of emitters
Pt = 1;                % Transmitted power
m = 5 ;                 % Lambertian mode number

%% Receivers:
Np = 1;                 % Number of parallels in the sensor
Nm = 3;                 % Number of meridians in the sensor

n_Receivers = Np*Nm;    % Number of receivers

%default receiver parameters
Ar = 0.01;              % Active receiving area
Ts = 1;                 % Optical filter gain
n = 1;                  % Receiver's internal refractive index
Psi = pi/10;             % Hemi-Fov
R= 1;

%% Create and populate data structures

% Create the emitters array:
lamps = Emitter.create_emitter(n_Emitters,Pt, m);

% Create the receiver structure:
robot = Receiver.create_receiver(n_Receivers, Ar, Ts, n, Psi,R);

%place sensors in the correct spot arround origin
robot.sensor = vlpCreateSensorParMer(robot.sensor , Np, Nm, 0.05,0,pi/4);
%robot.sensor = robot.sensor_structure;

ref= robot.sensor(1);

%%
figure;
% view(3);
axis 'equal';
grid on;

k=0.5;



%% Place emitters and receivers in 3D space
% Considering a room with 3mx3mx2m (WxLxH).

% Emitters are placed at the ceiling, looking down and in a circle of
% radius=0.5m
for i= 1: numel(lamps)
   % Base HTM at the center of the ceiling.
   lamps(i).HTM =Trans3(1,1,2) * RotX3(pi);       
end

lamps(1).HTM = lamps(1).HTM*Trans3(2,0,0);
lamps(2).HTM = lamps(2).HTM*RotZ3(120*pi/180)*Trans3(2,0,0);
lamps(3).HTM = lamps(3).HTM*RotZ3(-120*pi/180)*Trans3(2,0,0);

%display sensor and emitters
PlotHTMArray(lamps);

%%
%calculate power received
PDarray = get_power_received(robot, lamps);

%display power received in sensor
PlotHTMArrayPr(PDarray,k,'r');%k*MaxPr/MaxPr0,'g');
robot.plotBaseHTM();

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555
%move sensor
robot.base_HTM =robot.base_HTM * Trans3(1,1,0);
% robot.base_HTM =robot.base_HTM * RotZ3(10*pi/180);

%calculate power received
% PDarray = get_power_received(robot, lamps);
[vector PDarray] = robot.get_vector_to_emitter(lamps);

%display power received in sensor
 PlotHTMArrayPr(PDarray,k,'b');%k*MaxPr/MaxPr0,'g'); %%plot received power
                                                        % on photodiodes
robot.plotBaseHTM();


% % % %%% plot pratical values of vector to emitter

%%%plot direct vector robot-emitter
% temp1 = [lamps.HTM]
% temp1=temp1(1:3,4:4:end)
% vector2 = (repmat(robot.base_HTM(1:3,4),1,3)-temp1(1:3,:));
% 
% vector=vector2;

hold on
x=[lamps(:).HTM];

for i =1:numel(lamps)
    vector_norm(:,i) = -vector(:,i)./norm(vector(:,i))
    
    quiver3(robot.base_HTM(1,4),robot.base_HTM(2,4),robot.base_HTM(3,4),...
        vector_norm(1,i),vector_norm(2,i),vector_norm(3,i),'c')
    
    
    angle = atan2(norm(cross(vector_norm(:,i),x(1:3,3+4*(i-1)))), ...
        dot(vector_norm(:,i),x(1:3,3+4*(i-1))))
    
    
    
    radius(i) = tan(angle)*H
    viscircles(x(1:2,4*i)',radius(i),'Color','g');
end

% % % %%%plot direct vector robot-emitter
% % % temp1 = [lamps.HTM]
% % % temp1=temp1(1:3,4:4:end)
% % % vector2 = (repmat(robot.base_HTM(1:3,4),1,3)-temp1(1:3,:));
% % % % % d_vector
% % % 
% % % hold on
% % % x=[lamps(:).HTM];
% % % 
% % % for i =1:numel(lamps)
% % %     vector_norm2(:,i) = vector2(:,i)./norm(vector2(:,i))
% % %     
% % %     quiver3(robot.base_HTM(1,4),robot.base_HTM(2,4),robot.base_HTM(3,4),...
% % %         vector_norm2(1,i),vector_norm2(2,i),vector_norm2(3,i),'k')
% % % %     
% % % %     radius2(i) = norm(cross(vector_norm2(:,i), x(1:3,3+4*(i-1))))
% % % %     
% % % %     
% % % 
% % %     angle = atan2(norm(cross(vector_norm2(:,i),x(1:3,3+4*(i-1)))),...
% % %         dot(vector_norm2(:,i),x(1:3,3+4*(i-1))))
% % % 
% % %     radius2(i) = tan(angle)*H
% % %     viscircles(x(1:2,4*i)',radius2(i),'Color','b');
% % % end



% % % % %% %%%%%%%%%%%%%%%%%%%%%%%5
% % % % %move sensor
% % % % robot.base_HTM = robot.base_HTM * Trans3(2,2,0.5);
% % % % robot.base_HTM = robot.base_HTM * RotX3(pi/4);
% % % % 
% % % % %calculate power received
% % % % % PDarray = get_power_received(robot, lamps);
% % % % 
% % % % [vector PDarray] = robot.get_vector_to_emitter(lamps);
% % % % 
% % % % %display power received in sensor
% % % % PlotHTMArrayPr(PDarray,k,'g');%k*MaxPr/MaxPr0,'g');
% % % % robot.plotBaseHTM()

% quiver3(robot.base_HTM(1,4),robot.base_HTM(2,4),robot.base_HTM(3,4),R(1,1), R(2,1), R(3,1));




