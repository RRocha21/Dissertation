function [] = export_coordinates( experiment_number, test_number, Ng)
%% export_coordinates - export the data
% experiment_number - number of the experiment to run -> 1 : 4
% test_number - number of the test to run -> 1:65
% Ng - number of elements per group -> 3:params.nEmitters
%
% %

%% add the path to the projective geometry functions
addpath('../../ProjGeom');
addpath('../');

%% export from raw data to xy coordinates
if exist(['results/data_WACOWCmulti' num2str(experiment_number) '_Ng_' num2str(Ng) '.mat'], 'file')
    load(['results/data_WACOWCmulti' num2str(experiment_number) '_Ng_' num2str(Ng) '.mat'])
else
    load(['results/data_WACOWCmulti' num2str(experiment_number) '.mat']);
end

temp_data = data(test_number);
% Params Structure
params = temp_data.params;

% Grouping parameters
% Ng = 3; % number of emitters in the group
use_average=0; % set to one to use the average of params.Nrep repetitions

%% generate emitters from params
%%Create the light emitters
Emitters = newEmitters(params.n_Emitters,params.Pb,params.Ps,params.m);
% Emitter location in xy plane
locEm = [ 0 0 params.H ];
Em_Base_HTM = Trans3( locEm' )*RotX3(pi);      % Base HTM at (0,0), on the ceiling.
delta_W = params.W/(params.n_W+1);
delta_L = params.L/(params.n_L+1);
for i=1:params.n_W
    for j = 1:params.n_L
        Emitters(j+(i-1)*params.n_L).HTM = Trans3(i*delta_W,j*delta_L,0)*Em_Base_HTM;
    end
end

warning('off','all')

J = waitbar(0, 'Exporting coordinates...');
%% Iterate over the xy plane and aggregate the emmiters into groups
for xi=1: size(temp_data.export,1)
    for yi=1: size(temp_data.export,2)
        
        %extract variables from structure for easier handling
        export = temp_data.export(xi,yi);
        
        radii_all = export.computed_radii;

        %generate the combination of N
        combi= nchoosek([1:params.n_Emitters],Ng);
        
        loc_xy=[];
        loc_ave_xy = [];
        
        % Calculate an estimate for each group of photodiodes
        for i =1:size(combi,1)
            radii = radii_all(combi(i,:));
            
            location = trilateration_group_em(Emitters(combi(i,:)), radii);
            
            loc_xy = [loc_xy location];
        end
        
        location_xy_plane(xi,yi).locations = loc_xy;
        
        location_xy_plane(xi,yi).comb =combi(i);%% information is indexed from i =1:size(combi,1), not much needed
        
        % add calculated locations to the export
        temp_data.export(xi,yi).locations= location_xy_plane(xi,yi).locations;
        
        % update the data stored
        data(test_number) = temp_data;
        
        waitbar((xi*26+yi)/(26*26),J,['Exporting coordinates... ' num2str(xi) ' - ' num2str(yi)]);
    end
end
close(J)
save([ 'results\data_WACOWCmulti' num2str(experiment_number) '_Ng_' num2str(Ng) '.mat'], 'data','Ng');

end

