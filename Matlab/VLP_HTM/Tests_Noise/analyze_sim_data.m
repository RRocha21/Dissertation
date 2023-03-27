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


path_fig = './figures/';
%% simulation parameters
%emitter
params.n_Emitters = 4; %square mode
params.m =1;
params.Pb = 1;
params.Ps = 0.25;

params.Re = 2.5;%obsolete

%room
params.W = 7.5;%not to be changed
params.L = 7.5;%not to be changed
params.H = 2.5;%not to be changed

%receiver
params.Np = 5;
params.Nm = 10;
params.Psi = 20;
params.SR = 0.25;

%simulation resolution
Wstep = 0.5;

%% Parameter to be changed in the simulation
% m1 = [1,2,3,4,5,6];
% Psi1 = [5 7.5 10 12.5];
Np1 = 5:30;
Nm1 = 10:72;

%from the comment above choose a value to set m and Psi
params.m = 1;
params.Psi = 12.5;

path_fig=[path_fig 'm_' num2str(params.m) '_psi_' num2str(params.Psi) '/'];

%% Compile data into data struture
index=1;


for iNp = 1:numel(Np1)
    for iNm = 1:numel(Nm1)
        
        params.Np=Np1(iNp);
        params.Nm=Nm1(iNm);
        
        %build filename to load
        field = fieldnames(params);
        
        filename= [];
        for i = [2 11 9 10]
            filename = [ filename num2str(getfield(params,field{i})) '-'] ;
        end
        load(['./long_test_m_1/square_' filename num2str(Wstep) '.mat'], 'res',...
            'params','underPercentage','broken');
        
        %place data from file in struct for easier access
        data(index).res=res;
        data(index).params=params;
        data(index).underPercentage=underPercentage;
        data(index).broken=broken;
        index=index+1;
    end
end


%% get maximum mean and standard deviation from the collected data
for index = 1: numel(data)
    data(index).max = max([data(index).res.dist]);
    
    data(index).mean = mean([data(index).res.dist]);
    data(index).std = std([data(index).res.dist]);
    
    mMax(data(index).params.Nm-9,data(index).params.Np-4) = data(index).max;
    mMean(data(index).params.Nm-9,data(index).params.Np-4) = data(index).mean;
    mStd(data(index).params.Nm-9,data(index).params.Np-4) = data(index).std;
end

%max error plot
figure
contour3(Np1,Nm1,mMax,100)
title('Max error across Nm and Np')

ylabel('Number of meridians')
xlabel('Number of paralels')
shading interp
colorbar
view(2)

saveas(gcf, [path_fig 'max_np_nm'], 'png')


%mean error plot
figure
contour3(Np1,Nm1,mMean,100)
title('Mean error across Nm and Np')

ylabel('Number of meridians')
xlabel('Number of paralels')
shading interp
colorbar
view(2)
saveas(gcf, [path_fig 'mean_np_nm.png'], 'png')

%std error plot
figure
contour3(Np1,Nm1,mStd,100)
title('Standard deviation of the error across Nm and Np')
ylabel('Number of meridians')
xlabel('Number of paralels')
shading interp
colorbar
view(2)
saveas(gcf, [path_fig 'std_np_nm.png'], 'png')

%% Load emttiers to plot in 3d graph

xloc=0:Wstep:params.W;
yloc=0:Wstep:params.L;

Emitters = newEmitters(params.n_Emitters,params.Pb,params.Ps,params.m);

offset = 5;

Em_Base_HTM = Trans3(0,0,params.H)*RotX3(pi);      % Base HTM at the center of the ceiling.

tempx = linspace(offset,params.W-offset,sqrt(params.n_Emitters));
tempy = linspace(offset,params.L-offset,sqrt(params.n_Emitters));
[temp_x,temp_y] = meshgrid(tempx,tempy);

temp_x=temp_x(:);
temp_y=temp_y(:);
% Light emitters placed at ceiling, in a square
for i=1:params.n_Emitters
    Emitters(i).HTM =Trans3(temp_x(i),temp_y(i),0)* Em_Base_HTM*...
        RotY3(pi/8*0);
end


%% Find and Plot highest % under 10cm
figure
PlotHTMArray(Emitters);

% dToPlot=find(mStd==min(min(mStd)))

%find the highest percentage under 10cm
highest = 0;
index=0;
for i= 1:numel(data)
    if(data(i).underPercentage > highest)
        highest = data(i).underPercentage;
        index=i;
    end
    
end

index
highest

dToPlot = index;

contour3(xloc,yloc,reshape([data(dToPlot).res.dist],16,16),100)
shading interp
colorbar
axis([0 params.W 0 params.L 0 params.H])
view(3)
title(['Error along the XY plane (' num2str(data(dToPlot).params.Np) ' parallels, ' num2str(data(dToPlot).params.Nm) ' meridians)'])
xlabel('X(m)')
ylabel('Y(m)')
saveas(gcf, [path_fig 'error_across_xy.png'], 'png')
view(2);
saveas(gcf, [path_fig 'error_across_xy_top_view.png'], 'png')

%%plot error under 10 cm
figure

PlotHTMArray(Emitters);

% to take a closer look activate plot under 0.5 m
%graph will be plotted with all values above 0.5 m trimed of
max_H = 0.1;

% dToPlot=find(mMean==min(min(mMean)))
mtemp=reshape([data(dToPlot).res.dist],16,16);

mtempb=double(mtemp < max_H);
mtemp=mtemp.*(1*mtempb)+(mtempb-1)*(-0.1);
underPercentage=sum(sum(mtempb))/numel(mtemp)


h=contour3(xloc,yloc,mtemp,100);
axis([0 params.W 0 params.L 0 params.H])

title(['Error along the XY plane (' num2str(data(dToPlot).params.Np) ' parallels, ' num2str(data(dToPlot).params.Nm) ' meridians)'])
xlabel('X(m)')
ylabel('Y(m)')

axis equal;
view(3);
grid on
shading interp
colorbar

%% Plotting with smaller range for simulations

%max error plot
figure
contour3(Np1(15-5:end),Nm1(40-10:end),mMax(40-10:end,15-5:end),100)%plot for np> 15 and nm > 40
title('Max error across Nm and Np')
ylabel('Number of meridians')
xlabel('Number of paralels')

axis([15 30 40 72])
shading interp
colorbar
view(2)

saveas(gcf, [path_fig 'max_np_nm_ranged.png'], 'png')

%mean error plot
figure
contour3(Np1(15-5:end),Nm1(40-10:end),mMean(40-10:end,15-5:end),100)%plot for np> 15 and nm > 40
title('Mean error across Nm and Np')
ylabel('Number of meridians')
xlabel('Number of paralels')

axis([15 30 40 72])
shading interp
colorbar
view(2)

saveas(gcf, [path_fig 'mean_np_nm_ranged.png'], 'png')

%std error plot
figure
contour3(Np1(15-5:end),Nm1(40-10:end),mStd(40-10:end,15-5:end),100)
title('Standard deviation of the error across Nm and Np')
ylabel('Number of meridians')
xlabel('Number of paralels')

axis([15 30 40 72])
shading interp
colorbar
view(2)
saveas(gcf, [path_fig 'std_np_nm_ranged.png'], 'png')


%% Plot graph of average plus 2 std
%% highest percentage under

dToPlot; % value of the graph to plot

figure;


contour3(xloc,yloc,reshape([data(dToPlot).res.dist],16,16),100)
shading interp
axis([0 params.W 0 params.L data(dToPlot).mean-2*data(dToPlot).std...
    data(dToPlot).mean+2*data(dToPlot).std])

colorbar
caxis([data(dToPlot).mean- 2*data(dToPlot).std data(dToPlot).mean+2*data(dToPlot).std])

view(2)
title({['Error along the XY plane (' num2str(data(dToPlot).params.Np)...
    ' parallels, ' num2str(data(dToPlot).params.Nm) ' meridians)']; 'Mean + 2 Standard Deviations'})
xlabel('X(m)')
ylabel('Y(m)')

%% Plot graph of average + 2 std for lowest mean


dToPlot= find(mMean==min(min([mMean])));

figure;


contour3(xloc,yloc,reshape([data(dToPlot).res.dist],16,16),100)
shading interp
axis([0 params.W 0 params.L data(dToPlot).mean-2*data(dToPlot).std...
    data(dToPlot).mean+2*data(dToPlot).std])

colorbar
caxis([data(dToPlot).mean- 2*data(dToPlot).std data(dToPlot).mean+2*data(dToPlot).std])

view(2)

title({['Error along the XY plane (' num2str(data(dToPlot).params.Np)...
    ' parallels, ' num2str(data(dToPlot).params.Nm) ' meridians)'];...
    ['Mean (' num2str(data(dToPlot).mean) ') + 2 Standard Deviations ('...
    num2str(data(dToPlot).std) ')']})

xlabel('X(m)')
ylabel('Y(m)')


saveas(gcf, [path_fig 'error_across_xy_lowest_mean'], 'png')


%% Plot graph of average + 2 std for lowest std


dToPlot= find(mStd==min(min(mStd)))

figure;


contour3(xloc,yloc,reshape([data(dToPlot).res.dist],16,16),100)
shading interp
axis([0 params.W 0 params.L data(dToPlot).mean-2*data(dToPlot).std...
    data(dToPlot).mean+2*data(dToPlot).std])

colorbar
caxis([data(dToPlot).mean- 2*data(dToPlot).std data(dToPlot).mean+2*data(dToPlot).std])

view(2)
title({['Error along the XY plane (' num2str(data(dToPlot).params.Np)...
    ' parallels, ' num2str(data(dToPlot).params.Nm) ' meridians)'];...
    ['Mean (' num2str(data(dToPlot).mean) ') + 2 Standard Deviations ('...
    num2str(data(dToPlot).std) ')']})
xlabel('X(m)')
ylabel('Y(m)')


saveas(gcf, [path_fig 'error_across_xy_lowest_std'], 'png')

%% Plot graph of average + 2 std for lowest max


dToPlot= find(mMax==min(min(mMax)))

figure;


contour3(xloc,yloc,reshape([data(dToPlot).res.dist],16,16),100)
shading interp
axis([0 params.W 0 params.L data(dToPlot).mean-2*data(dToPlot).std...
    data(dToPlot).mean+2*data(dToPlot).std])

colorbar
caxis([data(dToPlot).mean- 2*data(dToPlot).std data(dToPlot).mean+2*data(dToPlot).std])

view(2)
title({['Error along the XY plane (' num2str(data(dToPlot).params.Np)...
    ' parallels, ' num2str(data(dToPlot).params.Nm) ' meridians)'];...
    ['Mean (' num2str(data(dToPlot).mean) ') + 2 Standard Deviations ('...
    num2str(data(dToPlot).std) ')']})
xlabel('X(m)')
ylabel('Y(m)')


saveas(gcf, [path_fig 'error_across_xy_lowest_max'], 'png')





















