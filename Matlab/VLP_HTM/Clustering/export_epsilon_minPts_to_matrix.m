

clear
clc
close 

load('cluster_new_62_exp_4.mat')


for x_index=1:26
    x_data(x_index)= (x_index-1)*params.Wstep;
    for y_index=1:26
        
            y_data(y_index)= (y_index-1)*params.Lstep;
            clusters=clustering(x_index, y_index).clusters;
            temp =[clusters(:)];
            temp2 = [temp.smallest];
            error_matrix=[temp2.error]';
            
            error_matrix=reshape(error_matrix, numel(epsilon), numel(MinPts));
            
            [eps_index, minPts_index ]= find(error_matrix==min(min(error_matrix)));
            
            epsilon_matrix(x_index,y_index) = epsilon(eps_index(1));
            minPts_matrix(x_index,y_index) = MinPts(minPts_index(1));
            
    end
end

figure
surf(linspace(0,4,26),linspace(0,4,26),epsilon_matrix)
xlabel('X(m)')
ylabel('Y(m)')

axis equal
colorbar

figure
surf(linspace(0,4,26),linspace(0,4,26),minPts_matrix)
xlabel('X(m)')
ylabel('Y(m)')


% save('epsilon_minPts_matrix_57_exp_3.mat','epsilon_matrix', 'minPts_matrix', 'x_data', 'y_data','params')
