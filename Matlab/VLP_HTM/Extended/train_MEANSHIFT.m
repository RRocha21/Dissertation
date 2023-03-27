clc;
clear;
close all;

%% Load Data
addpath('..');
addpath('../Clustering/');
load coordinate_data.mat

plotOn=0;

%% Define the point under test

x_index_array = 1:size(ground,1);
y_index_array = 1:size(ground,2);


bandwidth = linspace(0.001,0.60,100);%0.001:0.001:0.75;%linspace(0.001,1,50);%[ 0.2 0.1 0.05 0.025 0.01 0.005 0.0025]; % min distance between points in meters

%% load coordinates from the data file
for x_index = x_index_array
    for y_index = y_index_array
        display(['X: '  num2str(x_index) ' Y:' num2str(y_index)]);
        coordinates=ground(x_index,y_index).coordinates;
        selected_averages=ground(x_index,y_index).coordinates_averages;
        
        real_pos = ground(x_index,y_index).xy;
        estimated_pos = ground(x_index,y_index).estimated_location;
        
        %% Run DBSCAN Clustering Algorithm
        
        %% Run MEAN SHIFT
        plotFlag=false;
        for bandwidth_index = 1:size(bandwidth,2)
            [clustCent,data2cluster,cluster2dataCell] = ...
                MeanShiftCluster(coordinates',bandwidth(bandwidth_index),plotFlag);
            
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
            
            real_error(bandwidth_index) = inf;
            power_cluster = [];
            %             if size(clustCent,2) < 8
            for i=1:size(clustCent,2)
                %                     if( sum(data2cluster(data2cluster==i))/i >=3)
                power_cluster(i) = sum(selected_averages(data2cluster == i));
                %                         temp_error = norm(clustCent(:,i)'-real_pos);
                %
                %                         if(temp_error <= real_error(bandwidth_index))
                %                             real_error(bandwidth_index)=temp_error;
                %                         end
                %                     end
            end
            %             end
            max_power_index = find(power_cluster == max(power_cluster));
            real_error(bandwidth_index)= norm(clustCent(:,max_power_index)' - real_pos);
            
            
        end
        
        MEANSHIFT_data(x_index, y_index).real_error = real_error;
        MEANSHIFT_data(x_index, y_index).bandwidth = ...
            bandwidth(min(find(real_error == min(real_error))));
        MEANSHIFT_data(x_index, y_index).bandwidth_error = ...
            real_error(min(find(real_error == min(real_error))));
        
    end
end

%%
min(min(reshape([MEANSHIFT_data(:).bandwidth_error],41,41)))
mean(mean(reshape([MEANSHIFT_data(:).bandwidth_error],41,41)))
max(max(reshape([MEANSHIFT_data(:).bandwidth_error],41,41)))

%%

figure
surf(1:41,1:41,reshape([MEANSHIFT_data(:).bandwidth],41,41))
title(' Bandwidth matrtix');
axis([1 41 1 41]);
colorbar;

figure
surf(1:41,1:41,reshape([MEANSHIFT_data(:).bandwidth_error],41,41))
average=mean(mean(reshape([MEANSHIFT_data(:).bandwidth_error],41,41)));
title(['Result error: ' num2str(average)]);
caxis([0 0.2]);
colorbar
axis([1 41 1 41]);


%%

save('meanshift_data', 'MEANSHIFT_data')



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



