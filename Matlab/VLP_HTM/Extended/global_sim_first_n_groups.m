clear
close all
clc

%%
load('..\Clustering\epsilon_minPts_matrix_62_exp_4.mat')


%%
load('dbscan_data.mat');
load('kmeans_data.mat');
load('meanshift_data.mat');

%%

% add the path to the projective geometry functions
addpath('../../ProjGeom');
addpath('../');
addpath('../Tests_Noise\')

addpath('../Clustering\')


%%
first_n_groups_array = 5:10:55;
nPoints = 41;
%%

for first_n_groups = first_n_groups_array
    
    plotOn = 0;
    group_overlap = 1;
    trilat_filter = 0;
    step1 = 0.1;%(size(DBSCAN_data,1)-1)/(params.W)
    
    
    Nm = params.Nm;
    Np = params.Np;
    
    Psi=params.Psi;
    
    run partial_sim.m
    save(['data_first_n_groups_' num2str(first_n_groups)], 'ground');
    clearvars -except params first_n_groups DBSCAN_data KMEANS_data MEANSHIFT_data nPoints ...
         first_n_groups_array
end


%%
clearvars -except first_n_groups_array nPoints

corner_x = 5:10;
corner_y = 5:10;

center_x = 3:7;
center_y = 3:7;

index = 1;

for first_n_groups = first_n_groups_array
    load(['data_first_n_groups_' num2str(first_n_groups)]);
    
    temp_ground = reshape([ground(:,:).trilat_error],size(ground,1), size(ground,2));
    trilat_mean_ground_corner(index) = mean(mean(temp_ground(corner_x, corner_y)));
    trilat_mean_ground_center(index) = mean(mean(temp_ground(center_x, center_y)));
    trilat_mean_ground(index) = mean(mean(temp_ground));
    
    temp_ground = reshape([ground(:,:).dbscan_error_real],size(ground,1), size(ground,2));
    dbscan_mean_ground_corner(index) = mean(mean(temp_ground(corner_x, corner_y)));
    dbscan_mean_ground_center(index) = mean(mean(temp_ground(center_x, center_y)));
    dbscan_mean_ground(index) = mean(mean(temp_ground));
    
    
    temp_ground = reshape([ground(:,:).kmeans_error_real],size(ground,1), size(ground,2));
    kmeans_mean_ground_corner(index) = mean(mean(temp_ground(corner_x, corner_y)));
    kmeans_mean_ground_center(index) = mean(mean(temp_ground(center_x, center_y)));
    kmeans_mean_ground(index) = mean(mean(temp_ground));
    
    temp_ground = reshape([ground(:,:).meanshift_error_real],size(ground,1), size(ground,2));
    meanshift_mean_ground_corner(index) = mean(mean(temp_ground(corner_x, corner_y)));
    meanshift_mean_ground_center(index) = mean(mean(temp_ground(center_x, center_y)));
    meanshift_mean_ground(index) = mean(mean(temp_ground));
     
    index = index + 1;    
end


figure
hold on
plot(first_n_groups_array,trilat_mean_ground_corner,'-')
plot(first_n_groups_array,dbscan_mean_ground_corner,'*-')
plot(first_n_groups_array,kmeans_mean_ground_corner,'+-')
plot(first_n_groups_array,meanshift_mean_ground_corner,'o-')
title('Corner')
ylabel('Error(m)')
xlabel('First N most powerful groups')
legend('Trilat','DBSCAN','KMEANS','Meanshift');

figure
hold on
plot(first_n_groups_array,trilat_mean_ground_center,'-')
plot(first_n_groups_array,dbscan_mean_ground_center,'*-')
plot(first_n_groups_array,kmeans_mean_ground_center,'+-')
plot(first_n_groups_array,meanshift_mean_ground_center,'o-')
title('Center')
ylabel('Error(m)')
xlabel('First N most powerful groups')
legend('Trilat','DBSCAN','KMEANS','Meanshift');

figure
hold on
plot(first_n_groups_array,trilat_mean_ground,'-')
plot(first_n_groups_array,dbscan_mean_ground,'*-')
plot(first_n_groups_array,kmeans_mean_ground,'+-')
plot(first_n_groups_array,meanshift_mean_ground,'o-')
title('All')
ylabel('Error(m)')
xlabel('First N most powerful groups')
legend('Trilat','DBSCAN','KMEANS','Meanshift');


%%
threshold_level_array = linspace(0.01, 0.5, 100);



    load(['data_first_n_groups_' num2str(15)]);
    index = 1;
    temp_ground = [];

for threshold_level = threshold_level_array


    temp_ground = reshape([ground(:).trilat_error],size(ground,1), size(ground,2));
    trilat_count(index) = sum(sum(temp_ground <= threshold_level))/(size(ground,1)*size(ground,2));
    trilat_count_corner(index) = sum(sum(temp_ground(corner_x, corner_y) <= threshold_level))...
        /(size(corner_x,2)*size(corner_y,2));
    trilat_count_center(index) = sum(sum(temp_ground(center_x, center_y) <= threshold_level))...
        /(size(center_x,2)*size(center_y,2));
    
    temp_ground = reshape([ground(:,:).dbscan_error_real],size(ground,1), size(ground,2));
    dbscan_count(index) = sum(sum(temp_ground <= threshold_level))/(size(ground,1)*size(ground,2));
    dbscan_count_corner(index) = sum(sum(temp_ground(corner_x, corner_y) <= threshold_level))...
        /(size(corner_x,2)*size(corner_y,2));
    dbscan_count_center(index) = sum(sum(temp_ground(center_x, center_y) <= threshold_level))...
        /(size(center_x,2)*size(center_y,2));
    
    temp_ground = reshape([ground(:,:).kmeans_error_real],size(ground,1), size(ground,2));
    kmeans_count(index) = sum(sum(temp_ground <= threshold_level))/(size(ground,1)*size(ground,2));
    kmeans_count_corner(index) = sum(sum(temp_ground(corner_x, corner_y) <= threshold_level))...
        /(size(corner_x,2)*size(corner_y,2));
    kmeans_count_center(index) = sum(sum(temp_ground(center_x, center_y) <= threshold_level))...
        /(size(center_x,2)*size(center_y,2));
    
    temp_ground = reshape([ground(:,:).meanshift_error_real],size(ground,1), size(ground,2));
    meanshift_count(index) = sum(sum(temp_ground <= threshold_level))/(size(ground,1)*size(ground,2));
    meanshift_count_corner(index) = sum(sum(temp_ground(corner_x, corner_y) <= threshold_level))...
        /(size(corner_x,2)*size(corner_y,2));
    meanshift_count_center(index) = sum(sum(temp_ground(center_x, center_y) <= threshold_level))...
        /(size(center_x,2)*size(center_y,2));
    index = index+1;
end



figure
hold on
plot(threshold_level_array, trilat_count_corner,'-')
plot(threshold_level_array, dbscan_count_corner,'*-')
plot(threshold_level_array, kmeans_count_corner,'+-')
plot(threshold_level_array, meanshift_count_corner,'o-')
title('Below threshold corner')
ylabel('Percentage')
xlabel('Threshold(m)')
legend('Trilat','DBSCAN','KMEANS','Meanshift');

figure
hold on
plot(threshold_level_array, trilat_count_center,'-')
plot(threshold_level_array, dbscan_count_center)
plot(threshold_level_array, kmeans_count_center,'+-')
plot(threshold_level_array, meanshift_count_center,'o-')
title('Below threshold center')
ylabel('Percentage')
xlabel('Threshold(m)')
legend('Trilat','DBSCAN','KMEANS','Meanshift');

figure
hold on
plot(threshold_level_array, trilat_count,'-')
plot(threshold_level_array, dbscan_count,'*-')
plot(threshold_level_array, kmeans_count,'+-')
plot(threshold_level_array, meanshift_count,'o-')
title('Below threshold all')
ylabel('Percentage')
xlabel('Threshold(m)')
legend('Trilat','DBSCAN','KMEANS','Meanshift');

%% ground noise


figure
surf(1:nPoints,1:nPoints,reshape([ground(:).noise],nPoints,nPoints))











