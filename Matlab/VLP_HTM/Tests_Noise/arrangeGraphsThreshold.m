function arrangeGraphsThreshold( hh, t )
%ARRANGEGRAPHSTHRESHOLD Converts surface graphs to 2D and hide values above threshold
%
%   hh is an array of graphic objects (surface plots). 
%   t is the threshold value
%
%   The colormap of the graphs in hh is changed for the range [0 t] and the
%   values above the threshold t are hidden (colour is changed to white).

% For all graphs in hh
for i = 1:numel(hh)
  f = hh(i);
  ax = ancestor(f,'axes');
  if( isempty(ax) == 0)
    colorbar(ax);
    caxis(ax,[0 t]);
    map = colormap;
    map(size(map,1),:) = [1 1 1];
    colormap(ax,map);
    view(ax,2);
  end
end


end

