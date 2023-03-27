clc;
clear;
close all;

%% Load Data

addpath('../Clustering/');
load coordinate_data.mat

plotOn=0;

n_max_clusters = 5;


cluster_array = 1: n_max_clusters;
%% Define the point under test

x_index_array = 1:size(ground,1);
y_index_array = 1:size(ground,2);


%% load coordinates from the data file
for x_index = x_index_array
    for y_index = y_index_array
        
        display(['X: '  num2str(x_index) ' Y:' num2str(y_index)]);
        coordinates=ground(x_index,y_index).coordinates;
        selected_averages=ground(x_index,y_index).coordinates_averages;

        real_pos = ground(x_index,y_index).xy;
        estimated_pos = ground(x_index,y_index).estimated_location;
        
        %% Run DBSCAN Clustering Algorithm
        
        for n_clusters = cluster_array
            
            opts = statset('Display','off');
            [cidx, ctrs] = kmeans(coordinates, n_clusters, 'Distance','city', ...
                'Replicates',5, 'Options',opts);
            
            if plotOn
                figure;
                
                hold on;
                plot(ctrs(:,1),ctrs(:,2),'gx', 'MarkerSize', 12);
                legend toggle
                axis([0 4 0 4]);
                
                plot(real_pos(1), real_pos(2),'k*')
                plot(estimated_pos(1), estimated_pos(2),'m*')
            end
            
            real_error(n_clusters) = inf;
            power_cluster= [];
            for i = 1:n_clusters
                if plotOn
                    plot(coordinates(cidx==i,1),coordinates(cidx==i,2),'o');
                    hold on;
                end
                
                % find min error of all clusters
                power_cluster(i)= sum(selected_averages(cidx== i));
                                
%                 temp_error = norm(ctrs(i,:)-real_pos);
%                 if(temp_error <= real_error(n_clusters))
%                     real_error(n_clusters)=temp_error;
%                 end  
%                 
            end
%             find
            real_error(n_clusters)=norm(ctrs(find(power_cluster==max(power_cluster)),:)- real_pos);
%                 
            
        end
        KMEANS_data(x_index, y_index).real_error = real_error;
        KMEANS_data(x_index, y_index).n_clusters = ...
            cluster_array(min(find(real_error == min(real_error))));
        KMEANS_data(x_index, y_index).min_error = min(real_error);

    end
end
min(min(reshape([KMEANS_data(:).min_error],41,41)))
mean(mean(reshape([KMEANS_data(:).min_error],41,41)))
max(max(reshape([KMEANS_data(:).min_error],41,41)))

%%

figure
surf(1:41,1:41,reshape([KMEANS_data(:).n_clusters],41,41))
title('N clusters matrix');
colorbar
axis([1 41 1 41]);

figure
surf(1:41,1:41,reshape([KMEANS_data(:).min_error],41,41))
average=mean(mean(reshape([KMEANS_data(:).min_error],41,41)));
title(['Result error: ' num2str(average)]);
caxis([0 0.2]);
colorbar
axis([1 41 1 41]);


%%
save('kmeans_data', 'KMEANS_data')



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



