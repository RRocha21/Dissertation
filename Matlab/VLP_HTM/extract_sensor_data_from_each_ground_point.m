%% test_robot_location
clear
close
clc

% % nonoise =1
load('Clustering\epsilon_minPts_matrix_62_exp_4.mat')

% add the path to the projective geometry functions
addpath('./../../projgeom/');
addpath('/');
addpath('Tests_Noise\')

addpath('Clustering\')

xloc =rand()*(params.W)
yloc =  rand()*params.L

Nm = params.Nm;
Np = params.Np;

Psi=params.Psi;


%% Create the light emitters

Emitters = newEmitters(params.n_Emitters,params.Pb,params.Ps,params.m);

% Emitter location in xy plane
locEm = [ 0 0 params.H ];
Em_Base_HTM = Trans3( locEm' )*RotX3(pi);      % Base HTM at (0,0), on the ceiling.

delta_W = params.W/(params.n_W+1);
delta_L = params.L/(params.n_L+1);
for i=1:params.n_W
    for j = 1:params.n_L
        Emitters(j+(i-1)*params.n_L).HTM = Trans3(i*delta_W,j*delta_L,0)*Em_Base_HTM;
    end
end

% % % % % if usegraphics
% % % % %
% % % % %     % Plot the emitters position
% % % % %     if(isgraphics(1))
% % % % %         clf(1)
% % % % %     else
% % % % %         figure(1)
% % % % %     end
% % % % %
% % % % %     PlotHTMArray(Emitters);
% % % % %     axis([-0.5 W+0.5 -0.5 L+0.5 0 H+0.5]);
% % % % %     view(3);
% % % % %     grid on
% % % % % end

%% Create the receivers

n_Receivers = params.Np*params.Nm;    % Number of receivers

% Default values
Ar = 1e-6;              % Active receiving area
Ts = 1;                 % Optical filter gain
n = 1;                  % Receiver's internal refractive index
R = 1;                  % Receiver's responsivity

% Create the receiver structure:
Receivers = newReceivers(n_Receivers,Ar, Ts, n, Psi, R);
% Receivers are organized in Parallel and Meridians arragement of photo
% detectors, with Nm Meridians and 3 Parallels, in a sphere with
% radius SR
SR = 0.05;
PDSensor = vlpCreateSensorParMer(Receivers, params.Np, params.Nm, SR, pi/8);


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


%% Experiment cycle for a set of parameters

% tempSensor will be modified when travelling the room floor
tempSensor = PDSensor;
step=0.1;
nPoints= (params.W/step)+1;

for xloc = linspace(0,4,nPoints)%0:0.05:params.W
    for yloc =linspace(0,4,nPoints)% 0:0.05:params.L
        
        display(['X = ' num2str(xloc/step) '-- Y = ' num2str(yloc/step) ])
        % Move the sensor
        % Apply the transformation to every HTM in the sensors
        for i = 1:numel(tempSensor)
            tempSensor(i).HTM = Trans3(xloc,yloc,0)*PDSensor(i).HTM;
        end
        
        
        %  Compute received indication (mean and noise / variance)
        [ Y, nu ] = vlpRecIndication( Emitters, tempSensor, Bw, Z, s_i, s_v, Z_p, Theta );
        Nu = repmat(nu,1,params.n_Emitters);
        
        % Initialize arrays for storing the experiment error values
        locerrorv = [];
        locaNrep = [];
        radii_export = [];
        %         raderrorv = [];
        
        % Iterate
        for counter = 1:params.Nrep
            
            s = sqrt(Nu).*randn(size(Y));
            Ynoise = Y + s;
            
            % If variable nonoise exists and if it is set, shut down noise
            if exist('nonoise')
                if nonoise
                    Ynoise = Y;
                end
            end
            
            % If rectifyIndication is active, negative values are clipped
            % at zero:
            if params.rectifyIndication
                Ynoise = max(Y+s,zeros(size(Y)));
            end
            
            % Check for valid reading for photodiode
            % *1 to convert to double
            validReading = (Ynoise >  params.validReadingThreshold.*sqrt(Nu))*1;
            
            
            % Get a matrix with all HTMs, side-by-side
            x = [tempSensor.HTM];
            E = x(1:3,3:4:end);
            
            % Mvec is a matrix with the vectors pointing to the light sources
            filtered_Ynoise = Ynoise.*validReading;
            
            Mvec = E*filtered_Ynoise;
            % Normalize Mvec
            Mvec = Mvec./repmat(sqrt(sum(Mvec.^2)),3,1);
            
            % The angle with the vertical is given by acos(kz*Mvec),
            % where kz = [0 0 1] (a vector pointing up). The internal
            % product is simply the third line of Mvec, the norm of both
            % vectors being 1 (Mvec has been normalized), so the
            % expression can be simplified.
            vangles = acos(Mvec(3,:));
            
            % Compute the distances to light sources in the xy plane
            %             if validReading
            radii = params.H*tan(vangles);
            %             else
            %               radii = NaN;
            %             end
            
            % recP holds the total power received from each emitter
            recP = sqrt(sum(Ynoise.*Ynoise));
            
            % Criteria for accepting the location data
            accepted=zeros(1,params.n_Emitters);
            mrecP = mean(recP);
            while(sum(accepted) <4)
                accepted = recP > mrecP;
                mrecP = 0.98*mrecP;
            end
            
            
            ground(round(xloc/step)+1,round(yloc/step)+1).Y_data = Y;
            ground(round(xloc/step)+1,round(yloc/step)+1).Ynoise_data = Ynoise;
            ground(round(xloc/step)+1,round(yloc/step)+1).Yfiltered_data = filtered_Ynoise;
            ground(round(xloc/step)+1,round(yloc/step)+1).x = xloc;
            ground(round(xloc/step)+1,round(yloc/step)+1).y = yloc;
% % %             [ location ] = trilateration_group_em( Emitters(accepted), radii(accepted) );
% % %             
% % %             %     % Get the emitters position
% % %             %     temp = [Emitters.HTM];
% % %             %     posEm = temp(1:2,4:4:end);
% % %             %     %Consider only accepted positions
% % %             %     posEm_ac = posEm(:,accepted);
% % %             %
% % %             %     % Consider only accepted radii
% % %             %     radii_ac = radii(accepted);
% % %             %
% % %             %     Xx = posEm_ac(1,:);
% % %             %     Yy = posEm_ac(2,:);
% % %             %
% % %             %     A=[ Xx(2:end)'-Xx(1) Yy(2:end)'-Yy(1)];
% % %             %     B=0.5*((radii_ac(1)^2-radii_ac(2:end)'.^2) + (Xx(2:end)'.^2+Yy(2:end)'.^2) - (Xx(1)^2 + Yy(1)^2));
% % %             %
% % %             %     location = (A'*A)^(-1)*A'*B;
% % %             %
% % %             
% % %             %     % Compute the true value for radii
% % %             %     delta = posEm - repmat([xloc;yloc],1,params.n_Emitters);
% % %             %     trueradii = sqrt(sum(delta.^2));
% % %             %
% % %             % Compute errors
% % %             % Receiver location:
% % %             RecXYLoc = [xloc ; yloc ];
% % %             
% % %             % Error on estimation of emitter localization in xy plane
% % %             locerror = norm( RecXYLoc - location );
% % %             locerrorv = [ locerrorv locerror ];
% % %             
% % %             locaNrep= [ locaNrep location];
% % %             emitters_export = Emitters(accepted);
% % %             radii_export = radii(accepted);%[radii_export; radii_ac];
% % %             
        end
        
% % %         estimatedLocation = mean(locaNrep');
% % %         % error=norm(estimatedLocation-[xloc yloc])
% % %         
% % %         %% combination of Ng emitter selected
% % %         
% % %         Ng=3;
% % %         
% % %         % create combinations of selected emmiters and radius
% % %         %generate the combination of N
% % %         combi= nchoosek([1:numel(emitters_export)],Ng);
% % %         
% % %         %locations generated by the emitters group into groups of Ng elements
% % %         loc_combinations=[];
% % %         
% % %         % Calculate an estimate for each group of photodiodes
% % %         for i =1:size(combi,1)
% % %             radii = radii_export(combi(i,:));
% % %             
% % %             location = trilateration_group_em(emitters_export(combi(i,:)), radii);
% % %             
% % %             loc_combinations = [loc_combinations location];
% % %         end
% % %         loc_combinations= loc_combinations';
% % %         
% % %         %% data cleanUp
% % %         % [locations_clean]= clean( loc_combinations );
% % %         
% % %         % remove inf and nan from the data
% % %         loc_combinations(find(loc_combinations==Inf))=[];
% % %         loc_combinations(isnan(loc_combinations)==1)=[];
% % %         % reshape (the remove operation alters the shape of the coordinates)
% % %         locations_clean=reshape(loc_combinations,numel(loc_combinations)/2,2);
% % %         
% % %         % % %
% % %         % % % %% Outlier detection
% % %         % % % addpath('Outlier')
% % %         % % %
% % %         % % % M=50;  %(2:any integer)
% % %         % % %
% % %         % % %
% % %         % % % % grid formation where the actual location is only for illustration in
% % %         % % % % the figure
% % %         % % % [cell_w, cell_l,cell,M ]= partitioning( locations_clean,estimatedLocation,M );
% % %         % % % axis([0 4 0 4]);
% % %         % % % grid on
% % %         % % % % cell specifications and cluster initialization
% % %         % % % [ cell,locations_clean,T,m,cell_out] = CellDensity( cell, locations_clean,M, cell_w,cell_l );
% % %         % % %
% % %         % % % %% DBSCAN
% % %         % % %
% % %         % % %
% % %         % % % %% load coordinates from the data file
% % %         % % %
% % %         % % % coordinates=[];
% % %         % % % for index=1:numel(cell_out)
% % %         % % %     coordinates=[coordinates; cell_out(index).loc];
% % %         % % % end
% % %         
% % %         coordinates = locations_clean;
% % %         
% % %         
% % %         %% Run DBSCAN Clustering Algorithm
% % %         %interpolate data for epsilon and minPts
% % %         epsilon = interp2(x_data,y_data,epsilon_matrix,estimatedLocation(1),estimatedLocation(2),'linear');
% % %         minPts = 3;% round(interp2(x_data,y_data,minPts_matrix,estimatedLocation(1),estimatedLocation(2)))
% % %         
% % %         IDX=DBSCAN(coordinates,epsilon,minPts);
% % %         
% % % %         %% Plot Results
% % % %         figure
% % % %         PlotClusterinResult(coordinates, IDX);
% % % %         title(['DBSCAN Clustering (\epsilon = ' num2str(epsilon) ', MinPts = ' num2str(minPts) ')']);
% % % %         
% % % %         hold on
% % % %         %plot real location for comparison
% % % %         plot(estimatedLocation(1), estimatedLocation(2),'*m')
% % % %         plot(xloc, yloc,'og');
% % % %         axis([0 4 0 4])
% % % %         
% % % %         % mean(coordinates(logical(IDX),:)) %average position of all the clusters
% % % %         
% % %         
% % %         %% Select the largest cluster
% % %         now=0;
% % %         largest=0;
% % %         largest_index=0;
% % %         
% % %         smallest_error = inf;
% % %         smallest_error_index=0;
% % %         
% % %         
% % %         for clu_index = 1:max(IDX)
% % %             now = sum(IDX==clu_index);
% % %             
% % %             if(now>largest)
% % %                 largest=now;
% % %                 largest_index=clu_index;
% % %             end
% % %             
% % %             temp_error=norm(mean(coordinates(logical(IDX==clu_index),:))-[xloc yloc]);
% % %             if(temp_error < smallest_error)
% % %                 smallest_error=temp_error;
% % %                 smallest_error_index=clu_index;
% % %             end
% % %         end
% % %         
% % %         % display the index of the largest cluster and it's error
% % %         % largest_index;
% % %         largest_cluster_error=norm(mean(coordinates(logical(IDX==largest_index),:))-estimatedLocation);
% % %         
% % %         % smallest error of the clustering
% % %         % smallest_error_index;
% % %         % smallest_error
% % %         smallest_error_cluster_pos=mean(coordinates(logical(IDX==smallest_error_index),:));
% % %         
% % %         % display(['medio clusters: ' num2str(mean(coordinates(logical(IDX),:)))]); %average position of all the clusters
% % %         % display(['medio menor error a estimativa:' num2str(smallest_error_cluster_pos)])
% % %         % % display(['medio maior cluster:' num2str(mean(coordinates(logical(IDX==largest_index),:)))])
% % %         %
% % %         % display(['Estimativa loca trilat:' num2str(estimatedLocation)]);
% % %         % display(['Real loc:' num2str([xloc yloc])])
% % % % %         smallest_pos = mean(coordinates(logical(IDX==smallest_error_index),:));
% % %         
% % %         error_clustering = norm(mean(coordinates(logical(IDX==smallest_error_index),:))-[xloc yloc]);
% % %         trilat_error = norm(estimatedLocation-[xloc yloc]);
% % % %         display(['Error clustering' num2str(error_clustering)]);
% % % %         display(['Error trilate' num2str(norm(estimatedLocation-[xloc yloc]))]);
% % %         
% % % % % %         ground(round(xloc/step)+1,round(yloc/step)+1).clustering_error = error_clustering;
% % % % % %         ground(round(xloc/step)+1,round(yloc/step)+1).trilat_error = trilat_error;
        
        
    end
end

% %%
% 
% clustering_error =mean(mean(reshape([ground(:,:).clustering_error],nPoints,nPoints)));
% trilat_error = mean(mean(reshape([ground(:,:).trilat_error],nPoints,nPoints)));
% 
% 
% figure
% subplot(1,2,1)
% surf(linspace(0,4,nPoints),linspace(0,4,nPoints),reshape([ground(:,:).clustering_error],nPoints,nPoints))
% title(['Cluster error : ' num2str(clustering_error)])
% xlabel('X(m)')
% ylabel('Y(m)')
% % colormap('jet')
% colorbar
% caxis([0 0.2])
% shading interp
% axis square
% 
% subplot(1,2,2)
% surf(linspace(0,4,nPoints),linspace(0,4,nPoints),reshape([ground(:,:).trilat_error],nPoints,nPoints))
% title(['Trilateration error : ' num2str(trilat_error)])
% xlabel('X(m)')
% ylabel('Y(m)')
% % colormap('jet')
% colorbar
% caxis([0 0.2])
% shading interp
% axis square


%%
% % % % figure
% % % % trilat_error_ground = reshape([ground(:,:).trilat_error],nPoints,nPoints);
% % % % clustering_error_ground = reshape([ground(:,:).clustering_error],nPoints,nPoints);
% % % % gain = (clustering_error_ground)./trilat_error_ground;
% % % % 
% % % % % gain1=gain/max(max(gain));
% % % % 
% % % % surf(linspace(0,4,nPoints),linspace(0,4,nPoints),- 10*log10(gain))
% % % % % title(['Trilateration error : ' num2str(trilat_error)])
% % % % xlabel('X(m)')
% % % % ylabel('Y(m)')
% % % % colormap('jet')
% % % % colorbar
% % % % axis([0 4 0 4 ])
% % % % % caxis([-30 30])
% % % % shading interp
% % % % axis square


% sqrt(mean(mean((clustering_error_ground./ trilat_error_ground)^2)))
% 

save('ground_sensor_data')





