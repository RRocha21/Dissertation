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
clear;
close all;

%% Load Data
experiment_number = 2;
Ng=3;

path ='..\Tests_Noise\';
resultsdir = 'results\';

load([path resultsdir 'data_WACOWCmulti' num2str(experiment_number) '_Ng_' num2str(Ng) '.mat'])

test_number=60;

%% Define the point under test
x_index_array =13;%[ 1 7 13];
y_index_array = 13;%[ 1 7 13];

%% load coordinates from the data file
for x_index = x_index_array
    for y_index = y_index_array
        coordinates=data(test_number).export(x_index,y_index).locations;
        
        % remove inf and nan form coordinates
        coordinates(find(coordinates==Inf))=[];
        coordinates(isnan(coordinates)==1)=[];
        % reshape (the remove operation alters the shape of the coordinates)
        coordinates=reshape(coordinates,2,numel(coordinates)/2)';
        
        % export params and generate real position
        params = data(test_number).params;
        d_real =[params.Wstep*(x_index-1) params.Lstep*(y_index-1)];
        
        %% Run DBSCAN Clustering Algorithm
        epsilon =linspace(0.001,0.2,10);%[ 0.2 0.1 0.05 0.025 0.01 0.005 0.0025]; % min distance between points in meters
        MinPts =[3:50];%[20 15 12 10 7 5 3 2]; %min size of the cluster
        for epsilon_index = 1:numel( epsilon)
            for MinPts_index = 1:numel(MinPts)
                IDX=DBSCAN(coordinates,epsilon(epsilon_index),MinPts(MinPts_index));
                
       %%         
                
                %% Plot Results
                 PlotClusterinResult(coordinates, IDX);
%               title(['DBSCAN Clustering (\epsilon = ' num2str(epsilon(epsilon_index)) ', MinPts = ' num2str(MinPts(MinPts_index)) ')']);
%                 
                hold on
                %plot real location for comparison
                plot(d_real(1), d_real(2),'*m')
%                 
%                 axis([0 4 0 4])
%                 
                mean(coordinates(logical(IDX),:)) %average position of all the clusters
                
                %%
                cluster_error=[];
                
                %smallest
                smallest_error = Inf;
                smallest_error_index = 0;
                largest_error= Inf;
                largest_error_index = 0;
                largest_size_cluster=0;
                temp_size_cluster=0;
                for clu_index = 1:max(IDX)
                    cluster_error(clu_index) =norm(mean(coordinates(IDX==clu_index))-d_real);
                    
                    temp_size_cluster= sum(IDX==clu_index);
                    if(temp_size_cluster >= largest_size_cluster)
                        largest_size_cluster= temp_size_cluster;
                        largest_error=cluster_error(clu_index);
                        largest_error_index=clu_index;
                    end
                    
                    if(cluster_error(clu_index) < smallest_error)
                        smallest_error = cluster_error(clu_index);
                        smallest_error_index = clu_index;
                    end
                    
                    
                end
                cluster_data(x_index,y_index).test(epsilon_index,MinPts_index).cluster_error=cluster_error;
                
                
                cluster_data(x_index,y_index).test(epsilon_index,MinPts_index).smallest_error = smallest_error;
                cluster_data(x_index,y_index).test(epsilon_index,MinPts_index).smallest_error_index = smallest_error_index;
                
                cluster_data(x_index,y_index).test(epsilon_index,MinPts_index).largest_error = largest_error;
                cluster_data(x_index,y_index).test(epsilon_index,MinPts_index).largest_error_index = largest_error_index;
                cluster_data(x_index,y_index).test(epsilon_index,MinPts_index).largest_size_cluster = largest_size_cluster;
                cluster_data(x_index,y_index).test(epsilon_index,MinPts_index).rms_error = ...
                    data(test_number).results.locerrorrms(x_index,y_index);
                
            end
        end
    end
end

%%
d_plot = cluster_data(x_index,y_index);
% for epsilon_index = epsilon
%     for MinPts_index = MinPts;
smallest_error_matrix = reshape([d_plot.test.smallest_error],numel(epsilon),numel(MinPts));
contour3(MinPts,epsilon,(smallest_error_matrix),50)
% shading interp

%     end
% end



