%% Run single np,nm,m,psi multiple times to obtain error histogram

clear all;

% add the path to the projective geometry functions
addpath('../../ProjGeom');
addpath('../');

%% simulation parameters
%emitter
params.n_Emitters = 4; %square mode
params.m = 3;
params.Pb = 1;
params.Ps = 0.25;

params.Re = 2.5;%obsolete

%room
params.W = 7.5;%not to be changed
params.L = 7.5;%not to be changed
params.H = 2.5;%not to be changed

%receiver
params.Np = 31;
params.Nm = 70;
params.Psi = 10;
params.SR = 0.25;

%% run simulation Nrep times
Nrep=10;


for iRep=1:Nrep
    run run_mult_parameters_daugther.m
    
    %Create filename from the current parameters
    field = fieldnames(params);
    
    
    filename=[];
    
    %From all fields of parameters choose the m, Psi, Np and Nm
    for i = [3 4 9 10 11 2 1]
        filename = [ filename num2str(getfield(params,field{i})) '-'] ;
    end
    
    save(['./res/rep_' filename num2str(Wstep) '-' num2str(iRep) '.mat'], 'res',...
        'params','underPercentage','broken');
    
    %Clear vars from the previous simulation before the new one
    clearvars -except iRep params
end
31