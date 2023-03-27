%% test_robot_location
clear
close
clc
%%
% % nonoise =1
load('..\Clustering\epsilon_minPts_matrix_62_exp_4.mat')


%%
load('dbscan_data.mat');
load('kmeans_data.mat');
load('meanshift_data.mat');

% add the path to the projective geometry functions
addpath('../../ProjGeom');
addpath('../');
addpath('../Tests_Noise\')

addpath('../Clustering\')

plotOn = 0;
group_overlap = 1;


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


%% create emitter groups
count=1;

if group_overlap
    for y=1:params.n_W-1
        for x = 1:params.n_L-1
            for j = 1:params.n_W-y
                for i = 1:params.n_L-x
                    emitter_groups(count,:) = [ ...
                        x+(y-1)*params.n_L ...
                        x+i+(y-1)*params.n_L ...
                        x+(y+j-1)*params.n_L ...
                        x+i+(y+j-1)*params.n_L]';
                    count=count+1;
                end
            end
            
        end
    end
else
    for i=1:params.n_W-1
        for j = 1:params.n_L-1
            emitter_groups(count,:) = [ j+(i-1)*params.n_L j+(i-1)*params.n_L+1 j+(i-1)*params.n_L+5 ...
                j+(i-1)*params.n_L+6]';
            count=count+1;
        end
    end
end



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



for xloc = linspace(0,params.W,nPoints)%0:0.05:params.W
    for yloc =linspace(0,params.L,nPoints)% 0:0.05:params.L
        
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
        out_location=[];
        for counter = 1:params.Nrep
            
            % GEnerate noise signal
            s = sqrt(Nu).*randn(size(Y));
            %Add noise do input signal
            Ynoise = Y + s;
            
            % If variable nonoise exists and if it is set, shut down noise
            if exist('nonoise')
                if nonoise
                    Ynoise = Y;
                end
            end
            
            Ynoise_temporal(counter,:,:) = Ynoise;
            
            if(counter == 5)
                var_matrix = squeeze(var(Ynoise_temporal,0,1));
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
            
            [ location ] = trilateration_group_em( Emitters(accepted), radii(accepted) );
            out_location = [out_location location];
            
            % Compute errors
            % Receiver location:
            RecXYLoc = [xloc ; yloc ];
            
            % Error on estimation of emitter localization in xy plane
            locerror = norm( RecXYLoc - location );
            locerrorv = [ locerrorv locerror ];
            
            locaNrep= [ locaNrep location];
            %%emitters_export = Emitters(accepted);
            radii_export = radii(accepted);%[radii_export; radii_ac];
            
        end
        
        estimatedLocation = mean(locaNrep');
        trilat_error=norm(estimatedLocation-[xloc yloc]);
        
        %% combination of Ng emitter selected
        
        Ng=3;
        
        % calculated de average value of the sum of recieved power for each
        % emitter group
        for index=1: size(emitter_groups,1)
            average_power_sum(index) =mean(sum(Ynoise(:,emitter_groups(index,:))));
        end
        
        %select the emitter groups with power above average
        selected_emitters=find(average_power_sum >= mean(average_power_sum));
        selected_averages = average_power_sum(find(average_power_sum >= mean(average_power_sum)));
        %new emitter groups
        new_emitter_groups=emitter_groups(selected_emitters,:);
        
        % create combinations of selected emmiters and radius
        %generate the combination of N
        %combi= nchoosek([1:numel(emitters_export)],Ng);
        
        %locations generated by the emitters group into groups of Ng elements
        loc_combinations=[];
        
        % Calculate an estimate for each group of photodiodes
        for i =1:size(new_emitter_groups)
            radii_group = radii(new_emitter_groups(i,:));
            
            location = trilateration_group_em(Emitters(new_emitter_groups(i,:)), radii_group);%% emitters_export(combi(i,:)), radii);
            
            loc_combinations = [loc_combinations location];
        end
        loc_combinations= loc_combinations';
        
        %%
        coordinates = loc_combinations;
        
        
        %% Run DBSCAN Clustering Algorithm
        %interpolate data for epsilon and minPts
        
        
        epsilon = DBSCAN_data(round(xloc/step)+1,round(yloc/step)+1).best_epsilon;
        IDX=DBSCAN(coordinates,epsilon,3);
        
        
        %%Plot Results
        if plotOn
            figure
            PlotClusterinResult(coordinates, IDX);
            title(['DBSCAN Clustering (\epsilon = ' num2str(epsilon) ', MinPts = ' num2str(3) ')']);
            
            hold on
            %plot real location for comparison
            plot(estimatedLocation(1), estimatedLocation(2),'*m')
            plot(xloc, yloc,'og');
            axis([0 4 0 4])
        end
        
        
        smallest_error_DBSCAN = inf;
        smallest_error_DBSCAN_index=0;

        cluster_power = [];
        for index=1:max(IDX)
            %calculate the center position of each cluster
            cluster_power(index)=sum(selected_averages(IDX==index));

            
            temp=mean(coordinates(IDX==index,:),1);
            estimated_error_DBSCAN = norm(temp -estimatedLocation);

            % find cluster with smallest error
            if estimated_error_DBSCAN <= smallest_error_DBSCAN
                smallest_error_DBSCAN = estimated_error_DBSCAN;
                smallest_error_DBSCAN_index = index;
            end

            
            if plotOn
                plot(temp(1), temp(2),'*k');
                hold on
            end
            
        end
        if max(IDX)== 0 
            cluster_power(1)=sum(selected_averages(IDX==0));
        end
        
        real_error_DBSCAN = norm(mean(coordinates(find(IDX == smallest_error_DBSCAN_index))) - [xloc yloc]); 

        max_cluster_power_index=find(cluster_power==max(cluster_power));
        temp=mean(coordinates(find(IDX == max_cluster_power_index),:),1);
        estimated_error_DBSCAN = norm(temp - estimatedLocation);
        
        temp=mean(coordinates(find(IDX == max_cluster_power_index),:),1);
        real_error_DBSCAN = norm(temp - [xloc yloc]);
        
%         if real_error_DBSCAN_1 < real_error_DBSCAN
%             real_error_DBSCAN = real_error_DBSCAN_1;
%         end
        
        
        
        %% Run K MEANS
        
        n_clusters = KMEANS_data(round(xloc/step)+1, round(yloc/step)+1).n_clusters;
        
        opts = statset('Display','off');
        [cidx, ctrs] = kmeans(coordinates, n_clusters, 'Distance','city', ...
            'Replicates',5, 'Options',opts);
        
        estimated_error_kmeans = inf;
        cluster_power = [];
        for i = 1:n_clusters
            if plotOn
                plot(coordinates(cidx==i,1),coordinates(cidx==i,2),'o');
                hold on;
            end
            
            cluster_power(i)=sum(selected_averages(cidx==i));
%             % find min error of all clusters
            temp_error = norm(ctrs(i,:)-estimatedLocation);
            if(temp_error <= estimated_error_kmeans)
                estimated_error_kmeans=temp_error;
                estimated_error_kmeans_cluster = i;
            end
            
        end
        
         real_error_KMEANS = norm(ctrs(estimated_error_kmeans_cluster,:) - [xloc yloc]);

       
%         for index=1:max(n_clusters)
%             cluster_power(index)=sum(selected_averages(cidx==index));
%         end
        max_cluster_power_index=find(cluster_power==max(cluster_power));
        
        
        estimated_error_KMEANS = norm(ctrs(max_cluster_power_index,:) -estimatedLocation);
        
        real_error_KMEANS = norm(ctrs(max_cluster_power_index,:) - [xloc yloc]);
        
%         if( real_error_KMEANS_1 < real_error_KMEANS)
%             real_error_KMEANS =  real_error_KMEANS_1;
%         end
        
        %% Run MEAN SHIFT
        plotFlag=false;
        bandWidth = 0.1;
        
        bandwidth=MEANSHIFT_data(round(xloc/step)+1,round(yloc/step)+1).bandwidth;
        
        [clustCent,data2cluster,cluster2dataCell] = ...
            MeanShiftCluster(coordinates',bandwidth,plotFlag);
        
        if plotOn
            hold on
            for index=1:max(data2cluster)
                plot(coordinates(data2cluster==index,1),...
                    coordinates(data2cluster==index,2),'*')
                hold on;
                %string_legend(index,:) = ['Cluster ' num2str(index,'%2d')];
            end
            plot(clustCent(1,:),clustCent(2,:),'xr', 'MarkerSize', 12)
            
            legend TOGGLE
        end
        
        
        estimated_error_meanshift = inf;
        
        cluster_power = [];
        
        for i=1:size(clustCent,2)
%             if( sum(data2cluster(data2cluster==i))/i >=2)
                cluster_power(i)=sum(selected_averages(data2cluster==i));
                
                
                temp_error = norm(clustCent(:,i)'- estimatedLocation);
                
                if(temp_error <= estimated_error_meanshift)
                    estimated_error_meanshift = temp_error;
                    estimated_error_meanshift_cluster=i;
                end
%             end
            
        end
        
        max_cluster_power_index=find(cluster_power==max(cluster_power));
        estimated_error_MEANSHIFT = norm(clustCent(:,max_cluster_power_index)' -estimatedLocation);
        
        real_error_MEANSHIFT = norm(clustCent(:,estimated_error_meanshift_cluster)' - [xloc yloc]);

        
        real_error_MEANSHIFT = norm(clustCent(:,max_cluster_power_index)' - [xloc yloc]);
        
%         if real_error_MEANSHIFT_1 < real_error_MEANSHIFT
%             real_error_MEANSHIFT =  real_error_MEANSHIFT_1;
%         end
        
        %%
        
        ground(round(xloc/step)+1,round(yloc/step)+1).trilat_error = trilat_error;
        ground(round(xloc/step)+1,round(yloc/step)+1).dbscan_error = smallest_error_DBSCAN;
        ground(round(xloc/step)+1,round(yloc/step)+1).kmeans_error = estimated_error_kmeans;
        ground(round(xloc/step)+1,round(yloc/step)+1).meanshift_error = estimated_error_meanshift;
        
        
        ground(round(xloc/step)+1,round(yloc/step)+1).dbscan_error_real = real_error_DBSCAN;
        ground(round(xloc/step)+1,round(yloc/step)+1).kmeans_error_real = real_error_KMEANS;
        ground(round(xloc/step)+1,round(yloc/step)+1).meanshift_error_real = real_error_MEANSHIFT;
        ground(round(xloc/step)+1,round(yloc/step)+1).noise = sum(sum(s));
        
    end
end

%%

mean_trilat_error = mean(mean(reshape([ground(:,:).trilat_error],nPoints,nPoints)));
mean_dbscan_error = mean(mean(reshape([ground(:,:).dbscan_error],nPoints,nPoints)));
mean_kmeans_error = mean(mean(reshape([ground(:,:).kmeans_error],nPoints,nPoints)));
mean_meanshift_error = mean(mean(reshape([ground(:,:).meanshift_error],nPoints,nPoints)));

mean_dbscan_error_real = mean(mean(reshape([ground(:,:).dbscan_error_real],nPoints,nPoints)));
mean_kmeans_error_real = mean(mean(reshape([ground(:,:).kmeans_error_real],nPoints,nPoints)));
mean_meanshift_error_real = mean(mean(reshape([ground(:,:).meanshift_error_real],nPoints,nPoints)));

% save(ground)
threshold_level=0.05

trilat_points=reshape([ground(:,:).trilat_error],nPoints,nPoints);
trilat_plot= trilat_points;
trilat_points(find(trilat_points > threshold_level))=1;
count_trilat=sum(trilat_points(find(trilat_points > threshold_level)));
trilat_points(find(trilat_points > threshold_level))=inf;

subplot(1,4,1)
surf(linspace(0,4,nPoints),linspace(0,4,nPoints),trilat_plot)
title(['Trilateration error : ' num2str((1681-count_trilat)/(1681))])
xlabel('X(m)')
ylabel('Y(m)')
% colormap('jet')
colorbar
caxis([0 threshold_level])
shading interp
axis square
view(0,90)

dbscan_points=reshape([ground(:,:).dbscan_error_real],nPoints,nPoints);
dbscan_plot= dbscan_points;
dbscan_points(find(dbscan_points > threshold_level))=1;
count_dbscan=sum(dbscan_points(find(dbscan_points > threshold_level)));
dbscan_points(find(dbscan_points > threshold_level))=inf;

subplot(1,4,2)
surf(linspace(0,4,nPoints),linspace(0,4,nPoints),dbscan_plot)
title(['DBSCAN error : ' num2str((1681-count_dbscan)/(1681))])
xlabel('X(m)')
ylabel('Y(m)')
% colormap('jet')
colorbar
caxis([0 threshold_level])
shading interp
axis square
view(0,90)


kmeans_points=reshape([ground(:,:).kmeans_error_real],nPoints,nPoints);
kmeans_plot=kmeans_points;
kmeans_points(find(kmeans_points > threshold_level))=1;
count_kmeans=sum(kmeans_points(find(kmeans_points > threshold_level)));
kmeans_points(find(kmeans_points > threshold_level))=inf;

subplot(1,4,3)
surf(linspace(0,4,nPoints),linspace(0,4,nPoints),kmeans_plot)
title(['KMEANS error : ' num2str((1681-count_kmeans)/1681)])
xlabel('X(m)')
ylabel('Y(m)')
% colormap('jet')
colorbar
caxis([0 threshold_level])
shading interp
axis square
view(0,90)

meanshift_points=reshape([ground(:,:).meanshift_error_real],nPoints,nPoints);
meanshift_plot=meanshift_points;
meanshift_points(find(meanshift_points > threshold_level))= 1;
count_meanshift=sum(meanshift_points(find(meanshift_points > threshold_level)));
meanshift_points(find(meanshift_points > threshold_level))=inf;



subplot(1,4,4)
surf(linspace(0,4,nPoints),linspace(0,4,nPoints),meanshift_plot)
title(['MEANSHIFT error : ' num2str((1681-count_meanshift)/1681)])
xlabel('X(m)')
ylabel('Y(m)')
% colormap('jet')
colorbar
caxis([0 threshold_level])
shading interp
axis square
view(0,90)

save('ground', 'ground');






