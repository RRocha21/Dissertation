% clear
clc
close all

% load('..\Tests_Noise\results\data_WACOWCmulti4_Ng_3.mat')
%%
% tested i point(20,20)
test_number=53;
x_index=26;
y_index=13;


actualLoc=[(x_index-1)*4/26,(y_index-1)*4/26];
% the estimated locations
locations=data(test_number).export(x_index,y_index).locations;
% number of cells in each direction (grid dimension)
M=30;  %(2:any integer)
%% functions
   % remove NaNs and Inf
[locations_new]= clean( locations );
    % grid formation where the actual location is only for illustration in
    % the figure
[cell_w, cell_l,cell,M,locations ]= partitioning( locations_new,actualLoc,M );
axis([0 4 0 4])
     % cell specifications and cluster initialization
[ cell,locations_new,T,m,cell_out] = CellDensity( cell, locations_new,M, cell_w,cell_l );


%% DBSCAN part


addpath('..\Clustering\')

%% load coordinates from the data file

temp_out=[];
for index=1:numel(cell_out)
temp_out=[temp_out; cell_out(index).loc];
end

coordinates=temp_out;

% remove inf and nan form coordinates
% coordinates(find(coordinates==Inf))=[];
% coordinates(isnan(coordinates)==1)=[];
% % reshape (the remove operation alters the shape of the coordinates)
% coordinates=reshape(coordinates,2,numel(coordinates)/2)';

% export params and generate real position
params = data(test_number).params;
d_real =[params.Wstep*(x_index-1) params.Lstep*(y_index-1)];

%% Run DBSCAN Clustering Algorithm
epsilon=cell_out(1).epsilon;%0.03; % min distance between points in meters
MinPts = cell_out(1).minPts;%5; %min size of the cluster

IDX=DBSCAN(coordinates,epsilon,MinPts);


%% Plot Results
figure
PlotClusterinResult(coordinates, IDX);
title(['DBSCAN Clustering (\epsilon = ' num2str(epsilon) ', MinPts = ' num2str(MinPts) ')']);

hold on
%plot real location for comparison
plot(d_real(1), d_real(2),'*m')

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


