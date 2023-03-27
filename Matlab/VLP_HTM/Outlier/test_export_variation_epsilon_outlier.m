clear
clc
close all
addpath('..\Clustering\')

load('..\Tests_Noise\results\data_WACOWCmulti4_Ng_3.mat')
%%
% tested i point(20,20)
test_number=62;
x_index=26;
y_index=13;

for x_index =1:26
    for y_index = 1:26
        display([num2str(x_index) '...' num2str(y_index)])
        actualLoc=[(x_index-1)*4/26,(y_index-1)*4/26];
        % the estimated locations
        locations=data(test_number).export(x_index,y_index).locations;
        % number of cells in each direction (grid dimension)
        M=20;  %(2:any integer)
        %% functions
           % remove NaNs and Inf
        [locations_new]= clean( locations );
            % grid formation where the actual location is only for illustration in
            % the figure
        [cell_w, cell_l,cell,M,locations ]= partitioning( locations_new,actualLoc,M );
        % axis([0 4 0 4])
             % cell specifications and cluster initialization
        [ cell,locations_new,T,m,cell_out] = CellDensity( cell, locations_new,M, cell_w,cell_l );


        %% DBSCAN part
        % extract data from cell_out
        coordinates=[];
        for index=1:numel(cell_out)
            coordinates=[coordinates; cell_out(index).loc];
        end
        %%not needed here
        % remove inf and nan form coordinates
        % coordinates(find(coordinates==Inf))=[];
        % coordinates(isnan(coordinates)==1)=[];
        % % reshape (the remove operation alters the shape of the coordinates)
        % coordinates=reshape(coordinates,2,numel(coordinates)/2)';

        % % % export params and generate real position
                params = data(test_number).params;
                d_real =[params.Wstep*(x_index-1) params.Lstep*(y_index-1)];

        %% Run DBSCAN Clustering Algorithm
        %% Run DBSCAN Clustering Algorithm
                epsilon=linspace(0.001, 0.15,15);%0.1; % min distance between points in meters
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

save(['data_out_' num2str(test_number) '_outlier_dbscan.mat'], 'clustering', 'params')



