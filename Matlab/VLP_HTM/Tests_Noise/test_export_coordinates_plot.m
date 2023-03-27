%%
clear all;
clc

%%
experiment_number= 1;%1 to 4
test_number = 61; % 1 to 65 -> information about the test in the params structure

% size of the group of emitters
Ng=3;
%verify conditions for Ng
if Ng > (experiment_number+1)^2 || Ng < 3
   display( [' Ng must be greater than 3 and less than ' num2str((experiment_number+1)^2)]);
   return
end

% choose position on the ground to plot
x_index= 15;
y_index = 15;

experiment_name = ['WACOWCmulti' num2str(experiment_number)];
% Folter for storing results
resultsdir = 'results/';

%% Check existence of the data and generate if needed
%check if file exist, if not generate the data
if exist([resultsdir 'data_' experiment_name '.mat'], 'file') == 0
    % File does not exist.
    display('Running tests....');
    testWACOWCmulti(experiment_name);
    
    clearvars -except  experiment_number test_number Ng x_index y_index experiment_name resultsdir;
    display('Exporting data into structure...');
    run extract_testWACOWCmulti.m
end


%% Export coordinates for specific experiment

resultsdir = 'results/';

% check if the selected test has location data already generated
if exist([resultsdir 'data_' experiment_name '_Ng_' num2str(Ng) '.mat'], 'file')
    load([resultsdir 'data_' experiment_name '_Ng_' num2str(Ng) '.mat'])
    %verify if specific test already has the location data
    if(isfield(data(test_number).export(1,1),'locations')== 0 ) %% don't have field so generate
        display(['Exporting coordinates to existing file with test_number ' num2str(test_number) '....']);
        export_coordinates( experiment_number, test_number, Ng);
    end
else
    display(['Create file and exporting coordinates for test_number ' num2str(test_number) '....']);
    export_coordinates( experiment_number, test_number, Ng);
end


%% Load locations for x-index y-index
clearvars -except  experiment_number test_number Ng x_index y_index experiment_name resultsdir;

% Load file
display('Loading requested data...')
load([resultsdir 'data_WACOWCmulti' num2str(experiment_number) '_Ng_' num2str(Ng) '.mat']);


temp_data = data(test_number);

% Params Structure
params = temp_data.params;

locations=[temp_data.export(x_index,y_index).locations];

%for visualization purposes
display('Plotting data...')

% plot the cloud of estimated position from grouping
plot(locations(1,:),locations(2,:),'.')

hold on

axis([0 4 0 4])

% plot real location
plot(params.Wstep*(x_index-1),params.Lstep*(y_index-1), 'or')

