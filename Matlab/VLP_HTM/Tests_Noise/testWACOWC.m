function testWACOWC(experiment_name)
% TESTWACOWC Run simulation with a single emitter to get reading accuracy data

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
params.W = W;
params.L = L;
params.H = H;
params.Wstep= Wstep;
params.Lstep = Lstep;
params.Nrep = Nrep;
params.HPA_v = HPA_v;
params.m_v = m_v;
params.NmNp = NmNp;
params.Psi_v = Psi_v;
params.rectifyIndication = rectifyIndication;
params.validReadingThreshold = validReadingThreshold;
params.Psi_mode = Psi_mode;
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
        Psi_v =Psi_min *params.Psi_v;
      otherwise
        error('Invalid value or undefined Psi_mode!');
    end
    
    params.Psi_v = Psi_v;
    
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
      locEm = [ W/2 L/2 H ];
      Em_Base_HTM = Trans3( locEm' )*RotX3(pi);      % Base HTM at the center of the ceiling.
      
      % Light emitters placed at ceiling, in a circle of radius R
      Rs = 0;
      for i=1:n_Emitters
        Emitters(i).HTM = Em_Base_HTM*RotZ3(i*(2*pi)/n_Emitters)*...
          Trans3(Rs,0,0)*RotY3(0*pi/8);
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
            
            % Check for valid reading
            validReading = (max(Ynoise)/std(Ynoise) > validReadingThreshold);
            
            
            % Get a matrix with all HTMs, side-by-side
            x = [tempSensor.HTM];
            E = x(1:3,3:4:end);
            
            % Mvec is a matrix with the vectors pointing to the light sources
            Mvec = E*Ynoise;
            % Normalize Mvec
            Mvec = Mvec./repmat(sqrt(sum(Mvec.^2)),3,1);
            
            % The angle with the vertical is given by acos(kz*Mvec),
            % where kz = [0 0 1] (a vector pointing up). The internal
            % product is simply the third line of Mvec, the norm of both
            % vectors being 1 (Mvec has been normalized), so the
            % expression can be simplified.
            vangles = acos(Mvec(3,:));
            
            % Compute the distances to light sources in the xy plane
            if validReading
              radii = H*tan(vangles);
            else
              radii = NaN;
            end
            
            % Get the emitters position
            temp = [Emitters.HTM];
            posEm = temp(1:2,4:4:end);
            
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
            
            % Compute estimated location of emitter
            if validReading
              locEmEstim = [ Sx Sy Sz] + [ Px Py Pz]*H/Pz;
            else
              locEmEstim = [NaN NaN NaN];
            end
            
            if usegraphics
              % Plot the estimated point vector
              hpv = quiver3(Sx,Sy,Sz,2*Px,2*Py,2*Pz,'m','LineWidth',2);
              
              % Plot the circle
              hcirc = drawCircleAtH(Sx,Sy,H,radii(1));
              
              % Plot the estimated location of emitter in the ceiling
              hlem = plot3(locEmEstim(1),locEmEstim(2),locEmEstim(3),'om');
              
              if interactive == 1
                resp = input('[ENTER] to continue, any value to stop...','s');
                if numel(resp) ~= 0
                  display('Leaving...');
                  leaving = 1;
                  break;
                end
              else
                pause(.1);
              end
              
              delete(hpv);
              delete(hcirc);
              delete(hlem);
            end
            
            % Compute errors
            
            % Error on estimation of emitter localization in xy plane
            locerror = norm( locEm(1:2) - locEmEstim(1:2) );
            locerrorv = [ locerrorv locerror ];
            
            % Error in radius
            actualRad = norm( [Sx Sy] - locEm(1:2) );
            raderror = abs(actualRad - radii(1));
            raderrorv = [ raderrorv raderror ];
            
            
          end
          
          % Compute and save experiment data
          %results(ix,iy).validReading =
          results.locerroravg(ix,iy) = mean(locerrorv);
          results.locerrorstd(ix,iy) = std(locerrorv);
          results.locerrormax(ix,iy) = max(locerrorv);
          results.locerrorrms(ix,iy) = rms(locerrorv);
          
          results.raderroravg(ix,iy) = mean(raderrorv);
          results.raderrorstd(ix,iy) = std(raderrorv);
          results.raderrormax(ix,iy) = max(raderrorv);
          results.raderrorrms(ix,iy) = rms(raderrorv);
          
          
        end
      end % end of room traveling

      resultsfilename = createResultFilename( resultsdir, ...
        resultsBaseFn, m, Np, Nm, Psi, Nrep);
      save(resultsfilename,'params','results');

      
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
      roomstats.locerrrms = rms([results.locerrorstd(:)]);
      
      
      roomstats.raderrmax = max([results.raderrormax(:)]);
      roomstats.raderravg = mean([results.raderroravg(:)]);
      roomstats.raderrstd = std([results.raderrorstd(:)]);
      roomstats.raderrrms = rms([results.raderrorstd(:)]);
      
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
