clear

%%
load('ground_sensor_data.mat', 'ground', 'params','Emitters');

%%
i = 1;
for xi = 1: size(ground,1)
    for yi = 1:size(ground,2)
        temp_data = ground(xi,yi).Y_data;he
        
        temp_data_noise = ground(xi,yi).Ynoise_data;
        
        for em_i = 1:params.n_Emitters
            data(i).sensor = reshape(temp_data(:,em_i),params.Np, params.Nm)*255;
            data_noise(i).sensor = reshape(temp_data_noise(:,em_i),params.Np, params.Nm)*255;
            emitter_data(:,i) = Emitters(rem(i-1,params.n_Emitters)+1).HTM(1:3,4);
            target_data(i).x = ground
            i = i+1;
        end  
    end
end
%%

% x = digitsmall_dataset;
x = struct2cell(data(:));

x_noise = struct2cell(data_noise(:));
%%help neural net


hiddenSize = 30;

autoenc = trainAutoencoder(x, hiddenSize, ...
    'L2WeightRegularization', 0.001, ... %0.004
    'SparsityRegularization', 1.6, ...
    'SparsityProportion', 0.5, 'ScaleData',false);

%%
% xReconstructed = predict(autoenc, x);

xReconstructed = predict(autoenc, x);
figure;

offset=200;
for i = 1:20
    subplot(4,5,i);
    imshow(x{i+offset});
end
figure;
for i = 1:20
    subplot(4,5,i);
    imshow(xReconstructed{i+offset});
end
xReconstructed = predict(autoenc, x_noise);
figure;

offset=100;
for i = 1:20
    subplot(4,5,i);
    imshow(x_noise{i+offset});
end  
figure;
for i = 1:20
    subplot(4,5,i);
    imshow(xReconstructed{i+offset});
end




