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
Np1=28:32;
params.Np = 31; %28/29
Nm1=70:74;
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


params.Nm=Nm1(1);

for iPsi = 1:numel(Psi1)
    for iM = 1:numel(M1)
        for iP = 1:numel(Np1)

            params.Np = Np1(iP);
            params.m=M1(iM);
            params.Psi=Psi1(iPsi);

            %build filename to load
            field = fieldnames(params);

            filename= [];
            for i = [9 10 11 2]
                filename = [ filename num2str(getfield(params,field{i})) '-'] ;
            end
                 load(['./res/square_' filename num2str(Wstep) '-' num2str(getfield(params,field{1})) '.mat'], 'res',...
                'params','underPercentage','broken');

            %place data from file in struct for easier access
            data(index).res=res;
            data(index).params=params;
            data(index).underPercentage=underPercentage;
            data(index).broken=broken;
            index=index+1;

        end
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
    
    mMax(index) = data(index).max;
    mMean(index) = data(index).mean;
    mStd(index) = data(index).std;
end


%% plot


plot(mStd)

for i=1:numel(M1)
    figure(i)
    plot(Np1, mMean(1+6*i:numel(Np1)+6*i)) 
    hold on
    plot(Np1, mMax(1+6*i:numel(Np1)+6*i)) 
    plot(Np1, mStd(1+6*i:numel(Np1)+6*i)) 
    set(gca,'XTick',(Np1))
    title({['Evolution of the error with Np'];['HPA = ' num2str(HPA(i))...
        ', Psi = ' num2str(Psi1(1)) ' Nm= ' num2str(params.Nm) ]});
    
    
end
    

    
    
