% clear
clc
% close all

%%

load('data_first_5.mat')

threshold_level_array = 0.01:0.01:0.5;
index = 1;
for threshold_level = threshold_level_array
    trilat_points=reshape([ground(:,:).trilat_error],nPoints,nPoints);
    trilat_points(find(trilat_points > threshold_level))=1;
    count_trilat(index)=sum(trilat_points(find(trilat_points > threshold_level)));
    
    dbscan_points=reshape([ground(:,:).dbscan_error_real],nPoints,nPoints);
    dbscan_points(find(dbscan_points > threshold_level))=1;
    count_dbscan(index)=sum(dbscan_points(find(dbscan_points > threshold_level)));
    
    kmeans_points=reshape([ground(:,:).kmeans_error_real],nPoints,nPoints);
    kmeans_points(find(kmeans_points > threshold_level))=1;
    count_kmeans(index)=sum(kmeans_points(find(kmeans_points > threshold_level)));
    
    meanshift_points=reshape([ground(:,:).meanshift_error_real],nPoints,nPoints);
    meanshift_points(find(meanshift_points > threshold_level))= 1;
    count_meanshift(index)=sum(meanshift_points(find(meanshift_points > threshold_level)));
    
    index = index +1;
end

count_trilat = (41^2 - count_trilat )/41^2*100;
count_dbscan = (41^2 - count_dbscan )/41^2*100;
count_kmeans = (41^2 - count_kmeans )/41^2*100;
count_meanshift = (41^2 - count_meanshift )/41^2*100;


%%

plot(threshold_level_array, count_trilat)
hold on
plot(threshold_level_array, count_dbscan)
plot(threshold_level_array, count_kmeans)
plot(threshold_level_array, count_meanshift)




