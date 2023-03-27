function [ ff hh ] = plotErrSurface( filename , varargin )
%PLOTERRSURFACE Creates surface plots from one single experiment
%   plotErrSurface(filename, plotspec, hidden)
%   plotErrSurface(filename, plotspec)
%   plotErrSurface(filename)
%
%   filename: .mat file with the error data
%   plotspec: data to be ploted (opt)
%               'rms' : root mean square
%               'avg' : mean value
%               'std' : standard deviation
%               'max' : max value
%   hidden:   plot visibility (opt). If 1, plot is created but not visible.

load(filename)

% Position in x and y
xloc = 0:params.Wstep:params.W;
yloc = 0:params.Lstep:params.L;

baseTitle = [ '\{m, N_p, N_m, \Psi \}=\{' num2str(params.m) ',' ...
  num2str(params.Np) ',' num2str(params.Nm) ',' ...
  num2str(round(180/pi*params.Psi)) '\}'];

% By default, plot all graphs
plotmax = 1;    % Plot max
plotavg = 1;    % Plot mean
plotstd = 1;    % Plot std dev
plotrms = 1;    % Plot std dev

if nargin > 1
  t = varargin{1};
  if isstr(t)
    plotmax = 0;
    plotavg = 0;
    plotstd = 0;
    plotrms = 0;
    switch t
      case 'max'
        plotmax = 1;
      case 'avg'
        plotavg = 1;
      case 'std'
        plotstd = 1;
      case 'rms'
        plotrms = 1;
      otherwise
        warning('t must be one of [max|avg|std|rms]');
    end
  else
    warning('t must be a string!');
  end
end

% 2nd opt arg is plot control. If 1, creates a hidden plots (does no create
% the plot window). If 0 or absent, plot is created.
if nargin>2
  hideplot = varargin{2};
else
  hideplot = 0;
end

if hideplot==1
  figvisibility = 'off';
else
  figvisibility = 'on';
end

% Vector for storing the graphics handles
ff = zeros(8,1);
hh = zeros(8,1);

if plotmax
  % Location error,max
  ff(1) = figure
  set(ff(1),'Visible',figvisibility);
  hh(1) = surf(xloc,yloc,(results.locerrormax)');
  t = title(['Location, max error | ' baseTitle]);
  set(t,'FontWeight','Normal');
  
  if(exist('results.raderrormax'))
    % Radius error,max
    ff(2) = figure
    set(ff(2),'Visible',figvisibility);
    hh(2) = surf(xloc,yloc,(results.raderrormax)');
    t = title(['Radius, max error | ' baseTitle]);
    set(t,'FontWeight','Normal');
  end
end

if plotavg
  % Location error,mean
  ff(3) = figure;
  set(ff(3),'Visible',figvisibility);
  hh(3) = surf(xloc,yloc,(results.locerroravg)');
  t = title(['Location, mean error | ' baseTitle]);
  set(t,'FontWeight','Normal');
  
  if(exist('results.raderrorstd'))
    % Radius error,mean
    ff(4) = figure;
    set(ff(4),'Visible',figvisibility);
    hh(4) = surf(xloc,yloc,(results.raderroravg)');
    t = title(['Radius, mean error | ' baseTitle]);
    set(t,'FontWeight','Normal');
  end
end

if plotstd
  % Location error, stddev
  ff(5) = figure;
  set(ff(5),'Visible',figvisibility);
  hh(5) = surf(xloc,yloc,(results.locerrorstd)');
  t = title(['Location , st. dev.| ' baseTitle]);
  set(t,'FontWeight','Normal');
  
  if(exist('results.raderrorstd'))
    % Radius error,stdev
    ff(6) = figure;
    set(ff(6),'Visible',figvisibility);
    hh(6) = surf(xloc,yloc,(results.raderrorstd)');
    t = title(['Radius , st. dev.| ' baseTitle]);
    set(t,'FontWeight','Normal');
  end
end

if plotrms
  % Location error, stddev
  ff(7) = figure;
  set(ff(7),'Visible',figvisibility);
  hh(7) = surf(xloc,yloc,(results.locerrorrms)');
  t = title(['Location , rms error| ' baseTitle]);
  set(t,'FontWeight','Normal');
  
  if(exist('results.raderrorstd'))
    % Radius error,stdev
    ff(8) = figure;
    set(ff(8),'Visible',figvisibility);
    hh(8) = surf(xloc,yloc,(results.raderrorrms)');
    t = title(['Radius , rms error| ' baseTitle]);
    set(t,'FontWeight','Normal');
  end
end

end

