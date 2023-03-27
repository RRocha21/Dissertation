
clear all;

% add the path to the projective geometry functions
addpath('../../ProjGeom');
addpath('../');



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
params.Np = 18;
params.Nm = 23;
params.Psi = 20;
params.SR = 0.25;




%% Parameter to be changed in the simulation
m1 = [1,2,3,4,5,6];
Psi1 = [5 7.5 10 12.5];
Np1 = 28:29;%30:32;%28:29
Nm1 = 73:74; %70:74;%73:74

for d=1:numel(Np1) 
    for e=1:numel(Nm1)
        for c=1:numel(Psi1)
            for b=1:numel(m1)
                
                
                %Update parameter to new iteration
                params.m =  m1(b);
                params.Psi = Psi1(c);
                params.Np = Np1(d);
                params.Nm = Nm1(e);
                
                run run_mult_parameters_daugther.m
                
                %Create filename from the current parameters
                field = fieldnames(params);
                
                
                filename=[];
                
                %From all fields of parameters choose the m, Psi, Np and Nm
                for i = [9 10 11 2]
                    filename = [ filename num2str(getfield(params,field{i})) '-'] ;
                end
                
                save(['./res/square_' filename num2str(Wstep) '-' num2str(getfield(params,field{1})) '.mat'], 'res',...
                    'params','underPercentage','broken');
                
                %Clear vars from the previous simulation before the new one
                clearvars -except a b c d e m1 Np1 SR1 Nm1 Psi1 params
            end
        end
    end
end
