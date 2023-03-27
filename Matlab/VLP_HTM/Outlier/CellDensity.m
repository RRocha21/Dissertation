function [ cell,locations_new,T,m,cell_out] = CellDensity( cell, locations_new,M, cell_w,cell_l )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
% show
%hold on
%plot(locations(1,:), locations(2,:),'.')
% move data from struct to array
dim=M*M;
% xPos=zeros(dim,1);
% yPos=zeros(dim,1);
 for i=1 :dim
%     xPos(i,1)=cell(i).xpos;
%     yPos(i,1)=cell(i).ypos;
% end
% pos=cat(2,xPos(:,1),yPos(:,1));
  if M<18
  %% figure
   hold on
   txt=num2str(cell(i).id);
   text((cell(i).xpos),(cell(i).ypos),txt)
  end
end
   %%
   %% Density calculation
   tot=0;
   top=0;
   m=0;
    for i=1:dim 
        [ cell, locations_new] = findDensCell( cell, i, locations_new, cell_w,cell_l );
        tot=tot+cell(i).density;
%         if cell(i).density>top
%             top=cell(i).density
%             top_row=cell(i).row;
%             top_col=cell(i).col;
%         end   
    end
    %thhreshold Density
    T=tot/dim;
    dens=0;
    for i=1:dim
        if cell( i ).density>T
            cell(i).density_out=cell( i ).density;
            m=m+1;
            dens(m)=cell(i).density_out;
            cell(i).stand=std2(cell(i).loc);
            cell(i).epsilon=cell(i).stand^2*sqrt((cell(i).density_out)/(length(locations_new)*cell_l*cell_w*pi));
            cell_new(m)=cell(i);
        end
    end
    if length(dens)>1
       dens= sort(dens,'descend');
    end
    for i=1:length(dens)
        for j=1:length(dens)
            if dens(i)==cell_new(j).density_out
                cell_out(i)=cell_new(j);
            end
        end
    end
    for i=1:length(dens)
        cell_out(i).minPts=ceil((cell_out(i).density_out/(cell_out(i).stand*(m+1-i)))*cell_out(i).epsilon);
    end    

end