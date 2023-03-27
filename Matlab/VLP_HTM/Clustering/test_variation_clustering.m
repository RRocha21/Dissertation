 clear all
close
clc
%%
load('cluster_new_62_exp_4.mat')

%%
epsilon=linspace(0.001, 0.15,15);%0.1; % min distance between points in meters
MinPts=[3:7];%5 %min size of the cluster
     

x_index= 16;
y_index=17;
for x_index = 1:26
    for y_index = 1:26

        clusterdata=clustering(x_index, y_index);

        clusters = [clusterdata.clusters(:)];
        % .smallest.error]

        smallest=[clusters(:).smallest];
        error=[smallest(:).error];

        error=reshape(error,numel(epsilon),numel(MinPts));
% % 
% %         surf(MinPts,epsilon,error)
% %         colorbar

        error_data(x_index,y_index).clustering = min(min(error));
        error_data(x_index,y_index).rms = clusterdata.rmsError;
        
    end
end

%% plot ground
figure
subplot(1,2,1)
surf(1:26, 1:26, reshape([error_data.clustering],26,26))
title(['Clustering error ->' num2str(mean([error_data.clustering]))]);
axis square
colorbar
caxis([0 0.15])

% hold on
subplot(1,2,2)
surf(1:26, 1:26, reshape([error_data.rms],26,26))
title(['RMS error ->' num2str(mean([error_data.rms]))])
axis square
colorbar

caxis([0 0.15])

%% plot single spot variation
figure


clusterdata=clustering( 20,20);

clusters = [clusterdata.clusters(:)];
% .smallest.error]

smallest=[clusters(:).smallest];
error=[smallest(:).error];

error=reshape(error,numel(epsilon),numel(MinPts));


surf(MinPts,epsilon,error)
xlabel('minPts')
ylabel('\epsilon (m)')
zlabel('Error(m)')
title('Error variation with \epsilon and \it{minPts} on x=3.36m, y=3.36m')
colorbar

