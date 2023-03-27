function h=plot2Dpoints(m,s,links)
% PLOT2DPOINTS Plots the points in 2D defined by array m.
%   plot2Dpoints(m,s,links)
% 
%   Plots the 2D points defined by array m. Each column of m defines a
%   point in 2-D space, up to a constant, such that, given a column C=[U V
%   S]' of m, the point represented by C is (x,y) = (U/S, V/S)
%   
%   links is a 2xn array defining n pairs of points. Each column of links
%   contains the index of 2 points in m that will be connected by a line in
%   the final plot. 
% 
%   's' is a string defining the plot style (defaults to '*r' if ommited).
%
%   pf@ua.pt, 12 Dec 2016

if nargin < 2
  s = '*r';
 end

h = plot(m(1,:)./m(3,:),m(2,:)./m(3,:),s);

% If links were provided, draw them:

if nargin >= 3
    % store current hold state
    holdstate = ishold;
    
    % Force hold on to plot the links
    hold on
    
    for n = 1:size(links,2)
        i = links(1,n);
        j = links(2,n);
        
        X = m(1,[i j])./m(3,[i j]);
        Y = m(2,[i j])./m(3,[i j]);
        
        plot(X,Y,'b');
    end
    
    % Restore hold state
    if holdstate == 0
        hold off
    end
end


    