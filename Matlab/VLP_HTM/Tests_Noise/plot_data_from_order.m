

params=line(30);
field = fieldnames(params);

filename=[];
for i = 1:length(field)
    filename = [ filename num2str(getfield(params,field{i})) '-'] ;
end
line(1)=params;
load(['./res/square_' filename num2str(Wstep) '.mat'], 'res', 'params','underPercentage','broken');


Wstep =0.5;
Lstep = 0.5;

xloc = 0:Wstep:params.W;
yloc = 0:Lstep:params.L;

ix=numel(xloc);
iy=numel(yloc);

% % figure;
% % title(filename);
% % 

% plot quiver mov
% % 
% % PlotHTMArray(Emitters);
% % axis equal;
% % view(3);
% % grid on
% % 
% % for ix = 1:numel(xloc)
% %   for iy = 1:numel(yloc)
% %     quiver(xloc(ix),yloc(iy), res(ix,iy).loc(1)-xloc(ix), res(ix,iy).loc(2)-yloc(iy),'o')
% %   end
% % end

% figure(1)
% quiver(xloc,yloc, location-[xloc(ix);yloc(iy)],'o')
%% hi
figure

title(filename);
axis equal;
view(3);
grid on

% PlotHTMArray(Emitters);


% to take a closer look activate plot under 0.5 m
%graph will be plotted with all values above 0.5 m trimed of
max_H = 0.1;


mtemp=reshape([res.dist],ix,iy);

mtempb=double(mtemp < max_H);
mtemp=mtemp.*(1*mtempb-1e-2);
underPercentage=sum(sum(mtempb))/numel(mtemp)


h=surf(xloc,yloc,mtemp);
axis([0 params.W 0 params.L 0 params.H])

shading interp
colorbar

%% all plot
figure

title(filename);
axis equal;
view(3);
grid on

% PlotHTMArray(Emitters);

mtemp=reshape([res.dist],ix,iy);
h=contour3(xloc,yloc,mtemp,50);
axis([0 params.W 0 params.L 0 params.H])

shading interp
colorbar







