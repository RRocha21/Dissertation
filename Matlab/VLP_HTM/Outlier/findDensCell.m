function [ cell, locations_new ] = findDensCell( cell, i, locations_new, cell_w,cell_l )
%   Detailed explanation goes here
%   the points that you need
       xq = locations_new(1,:);
       yq = locations_new(2,:);
       % Define the x and y coordinates of polygon vertices to create a pentagon
       xv = [cell(i).xpos cell(i).xpos+cell_w cell(i).xpos+cell_w cell(i).xpos cell(i).xpos NaN ];
       yv = [cell(i).ypos cell(i).ypos cell(i).ypos-cell_l cell(i).ypos-cell_l cell(i).ypos NaN ];
      % Determine whether each point lies inside or on the edge of the polygon area. 
       % Also determine whether any of the points lie on the edge of the polygon area.
       [in,on] = inpolygon(xq,yq,xv,yv);
%       Determine the number of points lying inside or on the edge of the polygon area.
        Xon=numel(xq(on));
        Yon=numel(yq(on));
        cell(i).loc=[];
        for j=1:length(in)
            if in(j)==1
                cell(i).loc=[cell(i).loc; (locations_new(:,j))'];
            end
        end
        cell(i).density = numel(xq(in))-numel(xq(on));
        tempx=xq(on);
        tempy=yq(on);
        inon = in | on;                                             % Combine ‘in’ And ‘on’
        idx = find(inon(:));                                        % Linear Indices Of ‘inon’ Points
        xcoord = xq(idx);                                           % X-Coordinates Of ‘inon’ Points
        ycoord = yq(idx);      
        Xin=xq(in);
        loc(i,:)=[xcoord];
        for j=1:length(tempx)
            if (cell(i).xpos==tempx(j) && cell(i).ypos==tempy(j)) || (cell(i).xpos+cell_w==tempx(j) && cell(i).ypos==tempy(j)) || (cell(i).xpos==tempx(j) && cell(i).ypos-cell_l==tempy(j)) || (cell(i).xpos+cell_l==tempx(j) && cell(i).ypos-cell_l==tempy(j))
               cell(i).density = cell(i).density+0.25;
            else
               cell(i).density = cell(i).density+0.5 ;
            end
        end
        cell(i).PercDensity = (cell(i).density/length(locations_new))*100;
end

