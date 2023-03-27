function [ ff hh ] = makeSurfPlots( basename, varargin )
%MAKESURFPLOTS Creates surface plots from the files with basename.
%
%   makeSurfPlots(basename, hideplot)
%   makeSurfPlots(basename)
%
%   Calls PLOTERRSURFACE for all .mat files in the current dir with the
%   name starting with basename.
%   If hideplot is set and different from zero, the plot window is hidden,
%   and only the plot file is produced. 
  
list = dir([basename '_1*.mat']);

if numel(varargin)>0
  hideplot = varargin{1};
else
  hideplot = 0;
end

for i = 1:numel(list)
  matfilename = list(i).name;
  [ff hh ]= plotErrSurface(matfilename,'rms',hideplot);
  arrangeGraphsThreshold(hh,0.50);
  dotpos = find((matfilename=='.'));
  pngfilename = [matfilename(1:dotpos) 'png'];
  print(ff(7),[matfilename(1:dotpos-1) '_loc.png'],'-dpng');
  savefig(ff(7),[matfilename(1:dotpos-1) '_loc.fig']);
  if ff(8) ~= 0
    print(ff(8),[matfilename(1:dotpos-1) '_rad.png'],'-dpng');
    savefig(ff(8),[matfilename(1:dotpos-1) '_rad.fig']);
  end
  if hideplot
    close(ff(7));
    if ff(8)
      close(ff(8));
    end
    % Produce some output to show you're alive...
    fprintf('%02d%%\n',round(100*i/numel(list),0));
  end
end


end

