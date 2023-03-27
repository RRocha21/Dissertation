function testWACOWCmulti(experiment_name)
%TESTWACOWCMULTI testWACOWCmulti Simulation of VLP "naive" algorithm in a room.
%
%   TESTWACOWCMULTI(experiment_name)
%
%   experiment_name is the basename of a M-file containing the experiment
%   parameters.
%   
%   TESTWACOWCMULTI should be the first script to be called. It computes
%   the data to be used by the plot creation functions. 

%% Prepare the workspace

clearvars -except experiment_name;
close all;

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


%% Should not change below this line

% Position in x and y
xloc = 0:Wstep:W;
yloc = 0:Lstep:L;

% Save experiment parameters
% Room
params.W = W;
params.L = L;
params.H = H;
params.Wstep= Wstep;
params.Lstep = Lstep;
params.Nrep = Nrep;
% Emitters
params.n_L = n_L;
params.n_W = n_W;
params.n_Emitters = n_Emitters;
params.HPA_v = HPA_v;
params.m_v = m_v;
% Sensor
params.NmNp = NmNp;
params.Psi_v = Psi_v;
params.Psi_mode = Psi_mode;
% Conditions
params.rectifyIndication = rectifyIndication;
params.validReadingThreshold = validReadingThreshold;
params.resultsBaseFn = resultsBaseFn;

% Create the results dir if necessary
if exist(resultsdir) ~= 7
  % Results dir does not exist...
  mkdir(resultsdir);
end


%% Iterate over experiment conditions

leaving = 0;

%Initialize array to store full experiment results
testresults = [];
% Save the experiment results
save(expFilename,'testresults','params');



if(  (usegraphics == 0) )
  barra = waitbar(0,'Progress...');
end


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
      
      if(leaving==1)
        break;
      end
      
      disp([ '{m, N_p, N_m, Psi }={' num2str(m) ',' ...
        num2str(Np) ',' num2str(Nm) ',' ...
        num2str(round(180/pi*Psi)) '}']);
      
      %% Create the light emitters
      
      Emitters = newEmitters(n_Emitters,Pb,Ps,m);
      
      % Emitter location in xy plane
      locEm = [ 0 0 H ];
      Em_Base_HTM = Trans3( locEm' )*RotX3(pi);      % Base HTM at (0,0), on the ceiling.
      
      delta_W = W/(n_W+1);
      delta_L = L/(n_L+1);
      for i=1:n_W
        for j = 1:n_L
          Emitters(j+(i-1)*n_L).HTM = Trans3(i*delta_W,j*delta_L,0)*Em_Base_HTM;
        end
      end
      
      if usegraphics
        
        % Plot the emitters position
        if(isgraphics(1))
          clf(1)
        else
          figure(1)
        end
        
        PlotHTMArray(Emitters);
        axis([-0.5 W+0.5 -0.5 L+0.5 0 H+0.5]);
        view(3);
        grid on
      end
      
      %% Create the receivers
      
      n_Receivers = Np*Nm;    % Number of receivers
      
      % Create the receiver structure:
      Receivers = newReceivers(n_Receivers,Ar, Ts, n, Psi, R);
      % Receivers are organized in Parallel and Meridians arragement of photo
      % detectors, with Nm Meridians and 3 Parallels, in a sphere with
      % radius SR
      SR = 0.05;
      PDSensor = vlpCreateSensorParMer(Receivers, Np, Nm, SR, pi/8);
      
      
      %% setup the values for computing received indication
      
      % Quantities required for computation
      %       Bw -      Bandwidth of receiver circuit
      %       Z -       Vector with the transimpedance feedback resistors
      %       s_i -     Vector with the operational amplifiers current PSD
      %       s_v -     Vector with the operational amplifiers voltage PSD
      %       Z_p -     Vector with the photo-diode equivalent impedances
      %       Theta -   Thermodynamic temperature of feedback resistor, in Kelvin
      
      Bw = 10e4;      % Bandwidth= 10kHz
      Theta = 273+30;   % Feedback resistor at 30 degrees C
      
      % Vector of ones for the receivers
      nRec_v = ones(n_Receivers,1);
      
      s_i = 1.3e-15*nRec_v;    % Current noise "plateau" at 1.3 fA/sqrt(Hz)
      s_v = 4.8e-9*nRec_v;     % Voltage noise "plateau" at 4.8 nV/sqrt(Hz)
      Z = 1e6*nRec_v;          % Feedback resistors = 1M
      Z_p = 100e6*nRec_v;      % PD equivalent impedace = 100 MOhm
      
      
      
      
      
      %% Experiment cycle for a set of parameters
      
      
      % tempSensor will be modified when travelling the room floor
      tempSensor = PDSensor;
      
      
      % Save experiment parameters
      % Emitter data
      params.m = m;
      params.Pb = Pb;
      params.Ps = Ps;
      params.n_L = n_L;
      params.n_W = n_W;
      params.n_Emitters = n_Emitters;
      
      % Receiver data
      params.Np = Np;
      params.Nm = Nm;
      params.Psi = Psi;
      
      
      for ix = 1:numel(xloc)
        for iy = 1:numel(yloc)
          
          if(leaving==1)
            break;
          end
          
          f = ((ix-1)*numel(yloc) + iy)/(numel(xloc)*numel(yloc));
          if( (usegraphics == 0) )
            waitbar(f,barra);
          end
          
          % Move the sensor
          % Apply the transformation to every HTM in the sensors
          for i = 1:numel(tempSensor)
            tempSensor(i).HTM = Trans3(xloc(ix),yloc(iy),0)*PDSensor(i).HTM;
          end
          
          
          %  Compute received indication (mean and noise / variance)
          [ Y, nu ] = vlpRecIndication( Emitters, tempSensor, Bw, Z, s_i, s_v, Z_p, Theta );
          Nu = repmat(nu,1,n_Emitters);
          
          % Initialize arrays for storing the experiment error values
          locerrorv = [];
          raderrorv = [];
          
          % Initialize average variables
          export(ix,iy).average_radii= 0;
          export(ix,iy).average_rec_power = 0;
          
          % Iterate
          for counter = 1:Nrep
            
            s = sqrt(Nu).*randn(size(Y));
            Ynoise = Y + s;
            
            % If variable nonoise exists and if it is set, shut down noise
            if exist('nonoise')
              if nonoise
                Ynoise = Y;
              end
            end
            
            % If rectifyIndication is active, negative values are clipped
            % at zero:
            if rectifyIndication
              Ynoise = max(Y+s,zeros(size(Y)));
            end
            
            % Check for valid reading for photodiode
            % *1 to convert to double
            validReading = (Ynoise >  validReadingThreshold.*sqrt(Nu))*1;
            
            
            % Get a matrix with all HTMs, side-by-side
            x = [tempSensor.HTM];
            E = x(1:3,3:4:end);
            
            % Mvec is a matrix with the vectors pointing to the light sources
            filtered_Ynoise = Ynoise.*validReading;
            
            Mvec = E*filtered_Ynoise;
            % Normalize Mvec
            Mvec = Mvec./repmat(sqrt(sum(Mvec.^2)),3,1);
            
            % The angle with the vertical is given by acos(kz*Mvec),
            % where kz = [0 0 1] (a vector pointing up). The internal
            % product is simply the third line of Mvec, the norm of both
            % vectors being 1 (Mvec has been normalized), so the
            % expression can be simplified.
            vangles = acos(Mvec(3,:));
            
            % Compute the distances to light sources in the xy plane
%             if validReading
              radii = H*tan(vangles);
%             else
%               radii = NaN;
%             end
            
      
            
            % recP holds the total power received from each emitter
            recP = sqrt(sum(Ynoise.*Ynoise));
            
            % Criteria for accepting the location data
            accepted=zeros(1,n_Emitters);
            mrecP = mean(recP);
            while(sum(accepted) <4)
              accepted = recP > mrecP;
              mrecP = 0.98*mrecP;
            end
            
            % Get the emitters position
            temp = [Emitters.HTM];
            posEm = temp(1:2,4:4:end);
            %Consider only accepted positions
            posEm_ac = posEm(:,accepted);
            
            % Consider only accepted radii
            radii_ac = radii(accepted);
            
            Xx = posEm_ac(1,:);
            Yy = posEm_ac(2,:);
            
            A=[ Xx(2:end)'-Xx(1) Yy(2:end)'-Yy(1)];
            B=0.5*((radii_ac(1)^2-radii_ac(2:end)'.^2) + (Xx(2:end)'.^2+Yy(2:end)'.^2) - (Xx(1)^2 + Yy(1)^2));
            %A
            %B
            %accepted
            location = (A'*A)^(-1)*A'*B;
            % location=[0 0]';
            
            % Compute the true value for radii
            delta = posEm - repmat([xloc(ix);yloc(iy)],1,n_Emitters);
            trueradii = sqrt(sum(delta.^2));
            
            
            % PLOT SECTION
            
            % Sensor coordinates:
            Sx = xloc(ix);
            Sy = yloc(iy);
            Sz = 0;
            
            % Pointing vector
            Px = Mvec(1,1);
            Py = Mvec(2,1);
            Pz = Mvec(3,1);
            
            
            if usegraphics
              
              hcirc = zeros(size(radii));
              % Plot the circles
              for cc = 1:numel(radii)
                hcirc(i) = drawCircleAtH(Sx,Sy,H,radii(cc));
              end
              
              % Plot the estimated location of emitter in the ceiling
              hlem = plot3(location(1),location(2),H,'om');
              
              if interactive == 1
                resp = input('[ENTER] to continue, any value to stop...','s');
                if numel(resp) ~= 0
                  display('Leaving...');
                  leaving = 1;
                  break;
                end
              else
                pause(.01);
              end
              
              delete(hcirc);
              delete(hlem);
            end
            
                        
            % Compute errors
            % Receiver location:
            RecXYLoc = [Sx ; Sy ];
            
            % Error on estimation of emitter localization in xy plane
            locerror = norm( RecXYLoc - location );
            locerrorv = [ locerrorv locerror ];
            
            % Add current repetition for later average calcualtion
            export(ix,iy).average_radii= export(ix,iy).average_radii + radii;
            export(ix,iy).average_rec_power = export(ix,iy).average_rec_power + filtered_Ynoise;
            
          
          end
          
          % Compute and save experiment data
          results.locerroravg(ix,iy) = mean(locerrorv);
          results.locerrorstd(ix,iy) = std(locerrorv);
          results.locerrormax(ix,iy) = max(locerrorv);
          results.locerrorrms(ix,iy) = rms(locerrorv);
               
          % Radii export struture
          % radii is the estimated distance to each emitter
          % Add computed radii to export structure
          export(ix,iy).computed_radii = radii;
          export(ix,iy).average_radii = export(ix,iy).average_radii/params.Nrep;
          export(ix,iy).true_radii = trueradii;
          export(ix,iy).vector = Mvec;
          
          % Reusing the strucutre to also export the recieved power and the
          % average received power
          export(ix,iy).rec_power = sum(filtered_Ynoise);
          export(ix,iy).average_rec_power = sum(export(ix,iy).average_rec_power/params.Nrep);
                    
        end
      end % end of room traveling

      resultsfilename = createResultFilename( resultsdir, ...
        resultsBaseFn, m, Np, Nm, Psi, Nrep);
      save(resultsfilename,'params','results', 'export');

      
      %% Compute and save full area aggregate results
      %
      roomstats.Nrep = Nrep;
      roomstats.m = m;
      roomstats.Psi = Psi;
      roomstats.Np = Np;
      roomstats.Nm = Nm;
      
      roomstats.locerrmax = max([results.locerrormax(:)]);
      roomstats.locerravg = mean([results.locerroravg(:)]);
      roomstats.locerrstd = std([results.locerrorstd(:)]);
      roomstats.locerrrms = rms([results.locerrorrms(:)]);
      
           
      load(expFilename);
      % Add to array with all test results
      testresults = [ testresults; roomstats ];
      testresultstable = struct2table(testresults);
      
      % Save the experiment results
      save(expFilename,'testresults','testresultstable','params');
      
      
      
      %% Close the iteration over the experiment conditions
      
    end
  end
end

if( (usegraphics == 0) )
  delete(barra);
end



end

