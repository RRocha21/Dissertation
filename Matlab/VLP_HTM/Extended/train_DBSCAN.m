clc;
clear;
close all;

%% Load Data

addpath('../Clustering/');
load coordinate_data.mat

plotOn=0;

%% Define the point under test

x_index_array = 1:size(ground,1);
y_index_array = 1:size(ground,2);


epsilon =0.001:0.001:0.75;%linspace(0.001,1,50);%[ 0.2 0.1 0.05 0.025 0.01 0.005 0.0025]; % min distance between points in meters
MinPts =3;%[3:50];%[20 15 12 10 7 5 3 2]; %min size of the cluster

%% load coordinates from the data file
for x_index = x_index_array
    for y_index = y_index_array
        display(['X: '  num2str(x_index) ' Y:' num2str(y_index)]); 
        coordinates=ground(x_index,y_index).coordinates;
        selected_averages=ground(x_index,y_index).coordinates_averages;
        
        real_pos = ground(x_index,y_index).xy;
        estimated_pos = ground(x_index,y_index).estimated_location;
        
        %% Run DBSCAN Clustering Algorithm
        
        
        for epsilon_index = 1:numel( epsilon)
            for MinPts_index = 1:numel(MinPts)
                IDX=DBSCAN(coordinates,epsilon(epsilon_index),MinPts(MinPts_index));
                
                
                
                if plotOn
                    figure
                    %%Plot Results
                    PlotClusterinResult(coordinates, IDX);
                    %               title(['DBSCAN Clustering (\epsilon = ' num2str(epsilon(epsilon_index)) ', MinPts = ' num2str(MinPts(MinPts_index)) ')']);
                    %
                    hold on
                    %plot real location for comparison
                    plot(real_pos(1), real_pos(2),'*m')
                    plot(estimated_pos(1), estimated_pos(2),'*g')
                end
                
                cluster_power = [];
                
                real_error(epsilon_index)=inf;
                
                if sum(IDX) >= 3
                    for index=1:max(IDX)
                        cluster_centers=mean(coordinates(IDX==index,:),1);
                        if plotOn
                            plot(cluster_centers(1), cluster_centers(2),'*k')
                        end
                        
        
                        cluster_power(index) = sum(selected_averages(find(IDX==index)));
                    end
                    
                    max_cluster_power_index = find(cluster_power==max(cluster_power));
                    
                    temp=mean(coordinates(IDX == max_cluster_power_index,:),1);
                    estimated_error_DBSCAN = norm(temp - estimated_pos);
        
                    temp=mean(coordinates(IDX == max_cluster_power_index,:),1);
                    real_error(epsilon_index) = norm(temp - real_pos);
                      
%                 else
                    %display('ERROR')
%                     real_error(epsilon_index)= inf;
                    
                end
            end
        end
        
        DBSCAN_data(x_index,y_index).real_error = real_error;
        DBSCAN_data(x_index,y_index).best_epsilon = ...
            epsilon(max(find(real_error==min(real_error))));
        DBSCAN_data(x_index,y_index).best_epsilon_error=...
            real_error(max(find(real_error==min(real_error))));
    end
end

%%
min(min(reshape([DBSCAN_data(:).best_epsilon_error],41,41)))
mean(mean(reshape([DBSCAN_data(:).best_epsilon_error],41,41)))
max(max(reshape([DBSCAN_data(:).best_epsilon_error],41,41)))

%% 

figure
surf(1:41,1:41,reshape([DBSCAN_data(:).best_epsilon],41,41))
title('Epsilon matrix');
colorbar
axis([1 41 1 41]);

figure
surf(1:41,1:41,reshape([DBSCAN_data(:).best_epsilon_error],41,41))
average=mean(mean(reshape([DBSCAN_data(:).best_epsilon_error],41,41)));
title(['Result error: ' num2str(average)]);
caxis([0 0.2])
colorbar

axis([1 41 1 41]);



%%
save('dbscan_data', 'DBSCAN_data')



%%
% d_plot = cluster_data(x_index,y_index);
% % for epsilon_index = epsilon
% %     for MinPts_index = MinPts;
% smallest_error_matrix = reshape([d_plot.test.smallest_error],numel(epsilon),numel(MinPts));
% contour3(MinPts,epsilon,(smallest_error_matrix),50)
% % shading interp
%
% %     end
% % end



