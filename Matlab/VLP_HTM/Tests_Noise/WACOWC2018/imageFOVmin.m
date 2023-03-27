% Add path to the projective geometry functions
addpath('../../../ProjGeom')


% Number of meridians
Nm = 20;

% theta = arc between 2 consecutive PD in the equator line
theta = 2*pi./Nm;


% Draw a circle of radius theta centered in [1 0 0]
center = [1 0 0];
a = linspace(0,2*pi);

circle1=[ones(size(a));
theta/2*sin(a);
theta/2*cos(a);
ones(size(a))];

f = figure;
set(f,'Color','w');
ax = gca;
set(ax,'Visible','off');
hold on
view([146 30]);

% Plot axis

origin = [0 0 0];
l = 0.25;
refax = [0 0 0
  0 0 0
  0 0 0
  l 0 0
  0 l 0
  0 0 l]';

refaxh = quiver3(refax(:,1),refax(:,2),refax(:,3),refax(:,4),refax(:,5),refax(:,6));
% set(refaxh,'


circle2 = RotZ3(theta)*circle1;
circle3 = RotY3(-theta)*circle1;
circle4 = RotZ3(theta)*circle3;

% drawTranslucidPoly(circle1,[0.5 0.5 0.5],0.2);
% drawTranslucidPoly(circle2,[0.5 0.5 0.5],0.2);
% drawTranslucidPoly(circle3,[0.5 0.5 0.5],0.2);
% drawTranslucidPoly(circle4,[0.5 0.5 0.5],0.2);

PD=[1 0 0 1]';

PDs = [ PD RotZ3(theta)*PD RotY3(-theta)*PD RotZ3(theta)*RotY3(-theta)*PD];

% Plot the PD position
for i=1:4
  plot3(PDs(1,i),PDs(2,i),PDs(3,i),'ok','MarkerFaceColor','k','MarkerEdgeColor','k');
end

% Plot vector from origin to PDs
lpd=1.5;
pdh = quiver3(zeros(1,4),zeros(1,4),zeros(1,4),lpd*PDs(1,:), lpd*PDs(2,:), lpd*PDs(3,:),0);
set(pdh,'Color','[0 0 0]','LineWidth',1.);

FOVmin = acos(cos(theta)^2);

arc=[];
for i=linspace(0,1)
  arc = [ arc RotZ3(i*theta)*RotY3(-i*theta)*PD ];
end

FOVmincircle1=[ones(size(a));
FOVmin/2*sin(a);
FOVmin/2*cos(a);
ones(size(a))];

FOVmincircle2 = RotZ3(theta)*FOVmincircle1;
FOVmincircle3 = RotY3(-theta)*FOVmincircle1;
FOVmincircle4 = RotZ3(theta)*FOVmincircle3;

FOVmincirclestyle = 'b--';
drawPoly(FOVmincircle1,FOVmincirclestyle)
drawPoly(FOVmincircle2,FOVmincirclestyle)
drawPoly(FOVmincircle3,FOVmincirclestyle)
drawPoly(FOVmincircle4,FOVmincirclestyle)
drawTranslucidPoly(FOVmincircle1,[0.5 0.5 0.5],0.3);
drawTranslucidPoly(FOVmincircle2,[0.5 0.5 0.5],0.3);
drawTranslucidPoly(FOVmincircle3,[0.5 0.5 0.5],0.3);
drawTranslucidPoly(FOVmincircle4,[0.5 0.5 0.5],0.3);


FOVmaxcircle1=[ones(size(a));
theta*sin(a);
theta*cos(a);
ones(size(a))];

FOVmaxcircle2 = RotZ3(theta)*FOVmaxcircle1;
FOVmaxcircle3 = RotY3(-theta)*FOVmaxcircle1;
FOVmaxcircle4 = RotZ3(theta)*FOVmaxcircle3;

% FOVmaxcirclestyle = 'm-.';
% drawPoly(FOVmaxcircle1,FOVmaxcirclestyle);
% drawPoly(FOVmaxcircle2,FOVmaxcirclestyle);
% drawPoly(FOVmaxcircle3,FOVmaxcirclestyle);
% drawPoly(FOVmaxcircle4,FOVmaxcirclestyle);

delta=[-0.15 -0.1 .1 .1];
for i=1:4
  th = text(PDs(1,i),PDs(2,i),PDs(3,i)+delta(i),['PD_' num2str(i) ]);
  th.FontName='Liberation Serif';
  th.FontAngle='italic';
  th.FontWeight='bold';
  th.FontSize=12;
end

% l1p = [0.8,0.4,0.7];
% l1 = text(l1p(1),l1p(2),l1p(3),'FOV_{max}');
% l1.FontName='Liberation Serif';
% l1.FontAngle='italic';
% l1.FontSize=12;
% 
% l1d = [0.7865 0.3586 0.5929 ; l1p ];
% l1h = line(l1d(:,1),l1d(:,2),l1d(:,3));
% l1h.Color=[0 0 0];


l2p = [0.9,0.7,-0.2];
l2 = text(l2p(1),l2p(2),l2p(3),'FOV_{min}');
l2.FontName='Liberation Serif';
l2.FontAngle='italic';
l2.FontSize=12;

l2d = [0.9125 0.4278 -0.1814 ; l2p ];
l2h = line(l2d(:,1),l2d(:,2),l2d(:,3));
l2h.Color=[0 0 0];

print('imageFOVmin.eps','-depsc');
print('imageFOVmin.png','-dpng');
print('imageFOVmin_mono.eps','-deps');

