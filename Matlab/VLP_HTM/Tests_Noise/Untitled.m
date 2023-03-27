
for experiment_number= 1: 4
    for test_number = 1:65; % 1 to 65 -> information about the test in the params structure
        display([ num2str(experiment_number) ' -- ' num2str(test_number)])
        close all;
        run test_export_coordinates_plot.m

    end
end






