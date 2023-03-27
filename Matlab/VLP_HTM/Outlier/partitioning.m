function  [cell_w, cell_l,cell,M ]= partitioning( locations,actualLoc,M )
    x_min=min(locations(1,:));
    x_max=max(locations(1,:));
    x_st=x_min;
    w=x_max-x_min;
    stdX=std(locations(1,:));
%    x_med=median(locations(1,:));
    y_min=min(locations(2,:));
    y_max=max(locations(2,:));
    y_st=y_min;
    stdY=std(locations(2,:));
 %   y_med=median(locations(2,:));
    l=y_max-y_min;
    h=rectangle('Position',[x_st,y_st,w,l]);
 %   stdXY=std2(locations(:,:));
    %% to ensure minimum m 
%     if (M>min(l/stdY, w/stdX))
%         M=floor(min(l/stdY, w/stdX));
%     end
    %%
    % example: h=rectangle('Position',[start_x,start_y,width,length]);
    pos=get(h,'position');
    cell_w=pos(3)/M;
    cell_l=pos(4)/M;
    close all
    plot (locations(1,:), locations(2,:),'.')
    for k=1:M
      hold on
      new_pos_x=k*cell_w;
      for i=1:M
          hold on
          new_pos_y=i*cell_l;
          rectangle('Position',[pos(1:2) new_pos_x new_pos_y]);
          % cell init
          j = sub2ind([M,M], i, k);
          cell_index = strcat(num2str(i),'-',num2str(k));
          cell_index_in = str2num(cell_index);
          cell(j).id=cell_index;
          cell(j).row=i;
          cell(j).col=k;
          cell(j).xpos=x_min+(new_pos_x-cell_w);
          cell(j).ypos=y_min+new_pos_y;
          cell(j).density=0;
      end
    end
    hold on
    plot(actualLoc(1,1), actualLoc(1,2),'.r')
end