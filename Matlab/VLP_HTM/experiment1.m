%EXPERIMENT1 Plot of power received in the plane from a source using H0_ER

% addpath('/Users/win10/Github/projgeom/');
addpath('./../../projgeom/');

% Define base values

% Room dimensions
Lx = 3;
Ly = 3;
Lz = 2; 

dx = .05; 
dy = .05;

% Emitter position and orientation: 
HTM_E = Trans3(Lx, Ly/2, Lz);
HTM_E = HTM_E * RotY3(pi+pi/8);

% - m (Lambertian mode number)
% - Ar (receiver area) 
m = 2;
Ar = 1e-4;


xvals = 0:dx:Lx;
yvals = 0:dy:Ly;

rec_power = zeros(numel(xvals),numel(yvals));

% Make receiver traverse all ground area
for ix = 1:numel(xvals)
    for iy = 1:numel(xvals)
        % Compute receiver position
        HTM_R = Trans3(xvals(ix),yvals(iy),0);
        % HTM_R = HTM_R * RotY3(pi/8);
        
        % Compute received power
        rp = H0_ER(HTM_E, HTM_R, m, Ar);
        % Store received power
        % Note: the triples for surf(X,Y,Z) are defined as 
        % ( X(j), Y(i), Z(i,j) )
        rec_power(iy,ix) = rp;
    end
end

% Show the results
figure
plot3Drefaxis(HTM_E)
axis equal
hold

h = surf(xvals,yvals,rec_power);
h.MeshStyle = 'none';
% view(2);
figure(gcf);
