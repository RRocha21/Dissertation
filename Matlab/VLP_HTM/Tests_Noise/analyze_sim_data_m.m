% This script compiles all data into a struture in order to produce the
% desired graph output, there are 2 static paramters, m and Psi, being the
% Np and Nm the parameter under test
% Each run for a given pair of m and Psi will have 26 values for Np and 63
% for Nm, a total of 1638 simulations

%% Basic setup
clear all;
close all;

% add the path to the projective geometry functions
addpath('../../ProjGeom');
addpath('../');

%%
%Path for figure export
path_fig = './figures/';
%String to be used to concat name of figure
tempstr={'max_'; 'mean_'; 'std_'};

%% simulation parameters
%emitter
params.n_Emitters = 4; %square mode 4/9/16
params.m =1;
params.Pb = 1;
params.Ps = 0.25;

params.Re = 2.5;%obsolete

%room
params.W = 7.5;%not to be changed
params.L = 7.5;%not to be changed
params.H = 2.5;%not to be changed

%receiver
%28:32
params.Np = 31; %28/29
%70:74
params.Nm = 70; %70/71/72
params.Psi = 20;
params.SR = 0.25;

%simulation resolution
Wstep = 0.5;

% add number of emitters to differentiate the graphs
path_fig= [path_fig 'n_em_' num2str(params.n_Emitters) '/'];

%% Parameter to be changed in the simulation
% m1 = [1,2,3,4,5,6];
% Psi1 = [5 7.5 10 12.5];
M1 = [1 2 3 4 5 6];

HPA=[60 45 37.46 32.75  29.45 27];
Psi1 = [5 7.5 10 12.5];

%from the comment above choose a value to set m and Psi
% params.m = ;
% params.Psi = ;

%% Compile data into data struture
index=1;


for iPsi = 1:numel(Psi1)
    for iM = 1:numel(M1)
        
        params.m=M1(iM);
        params.Psi=Psi1(iPsi);
        
        %build filename to load
        field = fieldnames(params);
        
        filename= [];
        for i = [9 10 11 2]
            filename = [ filename num2str(getfield(params,field{i})) '-'] ;
        end
        %if(params.n_Emitters == 4)
           % load(['./res/square_' filename num2str(Wstep) '.mat'], 'res',...
           % 'params','underPercentage','broken');
        %else
             load(['./res/square_' filename num2str(Wstep) '-' num2str(getfield(params,field{1})) '.mat'], 'res',...
            'params','underPercentage','broken');
        
        %end
        
        %place data from file in struct for easier access
        data(index).res=res;
        data(index).params=params;
        data(index).underPercentage=underPercentage;
        data(index).broken=broken;
        index=index+1;
    end
end


%%

%get maximum mean and standard deviation from the collected data
for index = 1: numel(data)
    data(index).max = max([data(index).res.dist]);
    
    data(index).mean = mean([data(index).res.dist]);
    data(index).std = std([data(index).res.dist]);
    
    iPsi=find(Psi1==data(index).params.Psi);
    iM=find(M1==data(index).params.m);
    
    mMax(iM,iPsi) = data(index).max;
    mMean(iM,iPsi) = data(index).mean;
    mStd(iM,iPsi) = data(index).std;
end

%% plot max,mean and std vs m
for i = 1:numel(HPA)
    figure(1)
    plot(Psi1,mMax(i,:),'*-')
    hold on
    figure(2)
    plot(Psi1,mMean(i,:),'*-')
    hold on
    figure(3)
    plot(Psi1,mStd(i,:),'*-')
    hold on
end
figure(1)
title({'Max Error vs Psi';...
    [num2str(params.Np) ' Parallels, ' num2str(params.Nm) ' Meridians']})
figure(2)
title({'Mean Error vs Psi';...
    [num2str(params.Np) ' Parallels, ' num2str(params.Nm) ' Meridians']})
figure(3)
title({'Standard Deviation Error vs Psi';...
    [num2str(params.Np) ' Parallels, ' num2str(params.Nm) ' Meridians']})

for i = 1:3
    figure(i)
    set(gca,'XTick',Psi1)
    legend('m=1','m=2', 'm=3', 'm=4', 'm=5', 'm=6','Location','SouthWest')
    ylabel('Error(meters)')
    xlabel('Psi')
    saveas(gcf, [path_fig 'psi_to_' tempstr{i}  num2str(params.Np) '_np_' num2str(params.Nm) '_nm.png'], 'png')
end

%% plot max,mean,std vs m
for i = 1:numel(Psi1)
    figure(4)
    plot(HPA,mMax(:,i),'-*')
    hold on
    figure(5)
    plot(HPA,mMean(:,i),'-*')
    hold on
    figure(6)
    plot(HPA,mStd(:,i),'-*')
    hold on
end
figure(4)
title({'Max Error vs HPA';...
    [num2str(params.Np) ' Parallels, ' num2str(params.Nm) ' Meridians']})
figure(5)
title({'Mean Error vs HPA';...
    [num2str(params.Np) ' Parallels, ' num2str(params.Nm) ' Meridians']})
figure(6)
title({'Standard Deviation Error vs HPA';...
    [num2str(params.Np) ' Parallels, ' num2str(params.Nm) ' Meridians']})

for i = 4:6
    figure(i)
    
    %     set(gca,'XTick',(HPA))
    legend('Psi = 5','Psi = 7.5', 'Psi = 10', 'Psi = 12.5')
    ylabel('Error(meters)')
    xlabel('HPA')
    saveas(gcf, [path_fig 'hpa_to_' tempstr{i-3}  num2str(params.Np) '_np_' num2str(params.Nm) '_nm.png'], 'png')
end

%% 

figure
contour3(Psi1,HPA,mMax,20)
xlabel('Psi')
ylabel('HPA')
shading interp
view(2)
colorbar

title({'Max Error vs HPA';...
    [num2str(params.Np) ' Parallels, ' num2str(params.Nm) ' Meridians']})
saveas(gcf, [path_fig 'psi_hpa_to_max_' num2str(params.Np) '_np_' num2str(params.Nm) '_nm.png'], 'png')

figure
contour3(Psi1,HPA,mMean,20)
xlabel('Psi')
ylabel('HPA')
shading interp
view(2)
colorbar

title({'Mean Error vs HPA';...
    [num2str(params.Np) ' Parallels, ' num2str(params.Nm) ' Meridians']})
saveas(gcf, [path_fig 'psi_hpa_to_mean_' num2str(params.Np) '_np_' num2str(params.Nm) '_nm.png'], 'png')

figure
contour3(Psi1,HPA,mStd,20)
xlabel('Psi')
ylabel('HPA')
shading interp
view(2)
colorbar

title({'Standard Deviation Error vs HPA';...
    [num2str(params.Np) ' Parallels, ' num2str(params.Nm) ' Meridians']})

saveas(gcf, [path_fig 'psi_hpa_to_std_' num2str(params.Np) '_np_' num2str(params.Nm) '_nm.png'], 'png')

%%
% % % fig = get(0, 'children');
% % % 
% % % % Alterar as propriedades das figuras. Resize para a resolução do ecrã e
% % % % indicar que a imagem é para ser imprimida com o mesmo número de pixeis
% % % % que possui no ecrã 
% % % % screensize = get(0, 'ScreenSize');
% % % % set(fig, 'Position',[0 0 screensize(3) screensize(4)], 'PaperPositionMode','auto');
% % % 
% % % % para cada imagem, gravar em formato jpeg
% % % for k = 1 : length(fig)
% % %     saveas(fig(k), [fig(k).CurrentAxes.Title.String(1) fig(k).CurrentAxes.Title.String(2) '.png'], 'png')
% % % end;


% % % %% Plot histogram error
% % % min(min(mMean))
% % % dToPlot= find(mMean == min(min(mMean)));
% % % figure
% % % 
% % % hist([data(dToPlot).res.dist], 100 )
% % % 
% % % 
% % % 


%%
figure
surf(0:0.5:7.5,0:0.5:7.5,reshape([data(15).res.dist],16,16))
shading interp
view(2)
axis([0 7.5 0 7.5])
colorbar
xlabel('X(m)')
ylabel('Y(m)')
title({'Error along XY plane';['Np = ' num2str(data(15).params.Np) ',Nm = '...
    num2str(data(15).params.Nm) ',Mean = ' num2str(data(15).mean) ...
    ' m, Psi = ' num2str(data(15).params.Psi) ', HPA =' num2str(HPA(data(15).params.m))]})


