%
% Copyright (c) 2015, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YPML110
% Project Title: Implementation of DBSCAN Clustering in MATLAB
% Publisher: Yarpiz (www.yarpiz.com)
%
% Developer: S. Mostapha Kalami Heris (Member of Yarpiz Team)
%
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%

clc;
% clear;
close all;

%% Load Data
display('Loading...');
experiment_number = 4;
Ng=3;

path ='..\Tests_Noise\';
resultsdir = 'results\';

% load([path resultsdir 'data_WACOWCmulti' num2str(experiment_number) '_Ng_' num2str(Ng) '.mat'])

test_number=62;

x_index =7;
y_index=7;

display('Processing...')
%% load coordinates from the data file
coordinates=data(test_number).export(x_index,y_index).locations;

% remove inf and nan form coordinates
coordinates(find(coordinates==Inf))=[];
coordinates(isnan(coordinates)==1)=[];
% reshape (the remove operation alters the shape of the coordinates)
coordinates=reshape(coordinates,numel(coordinates)/2,2);

% export params and generate real position
params = data(test_number).params;
d_real =[params.Wstep*(x_index-1) params.Lstep*(y_index-1)];

%% Run DBSCAN Clustering Algorithm
epsilon=0.001; % min distance between points in meters
MinPts=3; %min size of the cluster

IDX=DBSCAN(coordinates,epsilon,MinPts);


%% Plot Results
PlotClusterinResult(coordinates, IDX);
title(['DBSCAN Clustering (\epsilon = ' num2str(epsilon) ', MinPts = ' num2str(MinPts) ')']);

hold on
%plot real location for comparison
plot(d_real(1), d_real(2),'*m')
xlabel('X(m)')
ylabel('Y(m)')


axis([0 4 0 4])

mean(coordinates(logical(IDX),:)) %average position of all the clusters


%% Select the largest cluster
now=0;
largest=0;
largest_index=0;

smallest_error = inf;
smallest_error_index=0;


for clu_index = 1:max(IDX)
    now = sum(IDX==clu_index);
    
    if(now>largest)
        largest=now;
        largest_index=clu_index;
    end
    
    temp_error=norm(mean(coordinates(logical(IDX==clu_index),:))-d_real);
    if(temp_error < smallest_error)
        smallest_error=temp_error;
        smallest_error_index=clu_index;
    end
end

% display the index of the largest cluster and it's error
largest_index
largest_cluster_error=norm(mean(coordinates(logical(IDX==largest_index),:))-d_real)

%display the error of the trilateration calculation
trilat_error_rms=data(test_number).results.locerrorrms(x_index,y_index)


% smallest error of the clustering
smallest_error_index
smallest_error

