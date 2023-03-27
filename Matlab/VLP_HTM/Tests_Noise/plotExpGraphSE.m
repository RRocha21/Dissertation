function plotExpGraphSE(experiment_data)
%PLOTEXPGRAPHSE (testWACOW) Plots the graphs with overall data

run(experiment_data);

%% Files and folders

% Folter for storing results
resultsdir = 'results/';

% Base filename
resultsBaseFn = experiment_data;

% Experimente results filename 
expFilename = [ resultsdir resultsBaseFn '_data' ];

%% 
load (expFilename);

% testresultstable = struct2table(testresults);

% Test: Psi
% Filter: m 
% Implicit: Np/Nm

plotBaseFn = [resultsdir resultsBaseFn];

for m = m_v
  
  % filter the table on m
  ifx = testresultstable.m==m;
  filtered = testresultstable(ifx,:);
  
  % Sort by Implicit and then by Test
  [x ix] = sort(filtered.Np);
  filtered = filtered(ix,:);
  [x ix] = sort(filtered.Psi);
  filtered = filtered(ix,:);

  % Get the indexes for the plots (unique values for each var)
  valstest = unique(filtered.Psi);
  valsimpl = unique(filtered.Np);
  
  nvalstest = numel(valstest);
  nvalstest = numel(Psi_v);
  nvalsimpl = numel(valsimpl);

  % Plot location error
  % Create the array: 
  plotdata = reshape(filtered.locerrmax, nvalsimpl,nvalstest);
  
  h = figure;
  plot(Psi_v*180/pi,plotdata','*-')
  ylim([0 Inf])
  title(['location, max error, m=' num2str(m) ', VRT=' num2str(params.validReadingThreshold) ])
  ylabel('Max error/m')
  xlabel('Psi/deg')
  legend(num2str(NmNp(:,1)))
  
  filename = [ plotBaseFn '_LocMaxErr_m_' num2str(m) '.png' ]
  print(filename,'-dpng')
  
  % Plot radius error
  % Create the array: 
  plotdata = reshape(filtered.raderrmax, nvalsimpl,nvalstest);

  
  h = figure;
  plot(Psi_v*180/pi,plotdata','*-')
  ylim([0 Inf])
  title(['radius, max error, m=' num2str(m) ', VRT=' num2str(params.validReadingThreshold) ])
  ylabel('Max error/m')
  xlabel('Psi/deg')
  legend(num2str(NmNp(:,1)))

  filename = [ plotBaseFn '_RadMaxErr_m_' num2str(m) '.png' ]
  print(filename,'-dpng')

end

% Test: m
% Filter: Psi 
% Implicit: Np/Nm

if Psi_mode == 2
  % Rearrange Psi values
  % Psi values are a function of Np. Replace actual values by the ratio
  % Psi/Psi_min
  % 1. Get the values for corresponding Phi_min
  Psi_min = 0.5*acos(cos(pi./(2*testresultstable.Np)).^2);
  % 2. Compute the ratio Psi/Psi_min
  Psi_ratio = round(testresultstable.Psi ./ Psi_min,2);
  % 3. Update table
  testresultstable.Psi = Psi_ratio;
end


for Psi = Psi_v
  Psi
  

  % filter the table on Psi
  ifx = testresultstable.Psi==Psi;
  filtered = testresultstable(ifx,:);
  
  % Sort by Implicit and then by Test
  [x ix] = sort(filtered.Np);
  filtered = filtered(ix,:);
  [x ix] = sort(filtered.m);
  filtered = filtered(ix,:);

  % Get the indexes for the plots (unique values for each var)
  valstest = unique(filtered.m);
  valsimpl = unique(filtered.Np);
  
  nvalstest = numel(valstest);
  nvalsimpl = numel(valsimpl);

  % Plot location error
  % Create the array: 
  plotdata = reshape(filtered.locerrmax, nvalsimpl,nvalstest);
  
  h = figure;
  plot(m_v,plotdata','*-')
  ylim([0 Inf])
  title(['location, max error, \Psi=' num2str(Psi*180/pi) ', VRT=' num2str(params.validReadingThreshold) ])
  ylabel('Max error/m')
  xlabel('m')
  legend(num2str(NmNp(:,1)))

  filename = [ plotBaseFn '_LocMaxErr_Psi_' num2str(180*Psi/pi) '.png' ]
  print(filename,'-dpng')

  
  
  % Plot radius error
  % Create the array: 
  plotdata = reshape(filtered.raderrmax, nvalsimpl,nvalstest);

  
  h = figure;
  plot(m_v,plotdata','*-')
  ylim([0 Inf])
  title(['radius, max error, \Psi=' num2str(Psi*180/pi) ', VRT=' num2str(params.validReadingThreshold) ])
  ylabel('Max error/m')
  xlabel('m')
  legend(num2str(NmNp(:,1)))

  filename = [ plotBaseFn '_RadMaxErr_Psi_' num2str(180*Psi/pi) '.png' ]
  print(filename,'-dpng')
  
end
