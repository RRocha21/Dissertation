% EXTRACT_TESTWACOWCMULTI Extract data from the simulations results
%
%   EXTRACT_TESTWACOWCMULTI(experiment_name)
%
%   experiment_name is the basename of a M-file containing the experiment
%   parameters.
%
%experiment_name = 'WACOWCmulti4';


%% Prepare the workspace

% clearvars -except experiment_name;
% close all;

paramsfile = [experiment_name '.m'];

run(paramsfile);

% add the path to the projective geometry functions
addpath('../../ProjGeom');
addpath('../');

%% Files and folders

% Folter for storing results
resultsdir = 'results/';

% Base filename
resultsBaseFn = experiment_name;

% Experimente results filename
expFilename = [ resultsdir resultsBaseFn '_data' ];
load([expFilename '.mat'])

%% Iterate over experiment conditions and load results

leaving = 0;

test_number=1;
for m = m_v
    for iConfig = 1:size(NmNp,1)
        
        Nm = NmNp(iConfig,1);
        Np = NmNp(iConfig,2);
        Psi_min = 0.5*acos(cos(pi/(2*Np))^2);
        Psi_max = pi/(2*Np);
        switch Psi_mode
            case 1
                Psi_v = [ Psi_min (Psi_min + Psi_max)/2 Psi_max ];
            case 2
                Psi_v = Psi_min *params.Psi_v;
            otherwise
                error('Invalid value or undefined Psi_mode!');
        end
        
        for Psi=Psi_v
            disp([ '{m, N_p, N_m, Psi }={' num2str(m) ',' ...
                num2str(Np) ',' num2str(Nm) ',' ...
                num2str(round(180/pi*Psi)) '}']);

            resultsfilename = createResultFilename( resultsdir, ...
                resultsBaseFn, m, Np, Nm, Psi, Nrep);
            data(test_number) = load(resultsfilename);
            test_number=test_number+1;
        end
    end
end

%% clear workspace and save compiled data

save([resultsdir 'data_' experiment_name '.mat'], 'data')
clearvars -except data;



% each test is stored in a index of data with the test params, results and
% radii to the emitters

% for the first test
% % params = data(1).params;
% % 
% % results=data(1).results;
% % 
% % export_radii = data(1).export_radii;
% % 
% % 

