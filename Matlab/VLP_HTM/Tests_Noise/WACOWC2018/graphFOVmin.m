% 
% VLP sensor
% Plot the graph of min and max FOV as a function of Np
%
% Assumption: Nm = 4*Np

Np = 3:20;

% theta = arc between 2 consecutive PD in the equator line
theta = pi./(2*Np);

% FOVmin : minimal value for FOV
% cos(FOVmin) = cos²(theta)
FOVmin= 90/pi*acos(cos(theta).^2);
%FOVmaxx= 2*180/pi*acos(cos(theta).^2);
FOVmax = 180/pi*theta;

figure;
plot(Np,FOVmin,'*--',Np,FOVmax,'*--');
t = title('FOV min and max as a function of N_p');
set(t,'fontWeight','normal');
grid on;
xlabel('N_p');
ylabel('FOV (deg)')
legend(['FOV_{min}' ;'FOV_{max}'])

print('FOVminmax.eps','-depsc');
print('FOVminmax_mono.eps','-deps');

