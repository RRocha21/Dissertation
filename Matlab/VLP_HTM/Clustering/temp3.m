clc;
clear;
close all;

%% Load Data

experiment_number = 4;
Ng=3;

path ='..\Tests_Noise\';
resultsdir = 'results\';

load([path resultsdir 'data_WACOWCmulti' num2str(experiment_number) '_Ng_' num2str(Ng) '.mat'])

test_number=53;

x_index =16;
y_index=14;

for x_index = 14:26
    for y_index = 1:13
        %% load coordinates from the data file
        display([ num2str(x_index) '...' num2str(y_index)])
        coordinates=data(test_number).export(x_index,y_index).locations;

        % remove inf and nan form coordinates
        coordinates(find(coordinates==Inf))=[];
        coordinates(isnan(coordinates)==1)=[];
        % reshape (the remove operation alters the shape .0of the coordinates)
        coordinates=reshape(coordinates,numel(coordinates)/2,2);

        % export params and generate real position
        params = data(test_number).params;
        d_real =[params.Wstep*(x_index-1) params.Lstep*(y_index-1)];

        %% Run DBSCAN Clustering Algorithm
        epsilon=linspace(0.001, 0.2,20);%0.1; % min distance between points in meters
        MinPts=[3:10];%5 %min size of the cluster
        
        for index_epsilon = 1:numel(epsilon)
            for index_minPts = 1:numel(MinPts)
                IDX=DBSCAN(coordinates,epsilon(index_epsilon),MinPts(index_minPts));
                clusters(index_epsilon,index_minPts).IDX=IDX;
                
                % run across the generated cluster and calculate the
                % average for each cluster
                temp_sum=0;
                largest_cluster=0;
                largest_index=0;

                smallest_error = inf;
                smallest_error_index=0;


                for clu_index = 1:max(IDX)
                    %count the elements that belong to the cluster
                    temp_sum = sum(IDX==clu_index); 
                    %calculate the average position for the selected
                    %cluster
                    temp_error=norm(mean(coordinates(logical(IDX==clu_index),:))-d_real);
                    
                    % find the cluster with largest number of elements
                    if(temp_sum>largest_cluster)
                        largest_cluster=temp_sum;
                        largest_index=clu_index;
                        largest_error = temp_error;
                    end

                    %find the cluster with the smallest error
                    if(temp_error < smallest_error)
                        smallest_error=temp_error;
                        smallest_error_index=clu_index;
                    end
                end
                
                clusters(index_epsilon,index_minPts).smallest.index = smallest_error_index;
                clusters(index_epsilon,index_minPts).smallest.error = smallest_error;
                
                clusters(index_epsilon,index_minPts).largest.index = largest_index;
                clusters(index_epsilon,index_minPts).largest.nElem = largest_cluster;
                clusters(index_epsilon,index_minPts).largest.error = largest_error;
                

            end
        end
        clustering(x_index,y_index).clusters=clusters;
        %% display the error of the trilateration calculation
        trilat_error_rms=data(test_number).results.locerrorrms(x_index,y_index);
        clustering(x_index,y_index).rmsError= trilat_error_rms;

      end
end
save('cluster_new_53_3.mat')


%% plot error variation with epsilon an minPts
 









