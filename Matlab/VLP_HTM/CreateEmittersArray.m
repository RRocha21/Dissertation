function [ Emitters ] = CreateEmittersArray( nx, ny, Pb, Ps, m, Lx, Ly, Z )
%CREATEEMITTERSARRAY Creates a regularly spaced 2 dimensional array of nx x ny emitters
%   Emitters = CreateEmittersArray( nx, ny, Pb, Ps, m, Lx, Ly, Z )
%
%   nx, ny      - dimension of emitter array in x and y directions.
%   Pb          - Power in the base (DC) component in each emitter
%   Ps          - Power in the signal component in each emitter
%   m           - Lambertian order of the emitter
%   Lx, Ly      - Total length of the array in x and y directions, resp.
%   Z           - z coordinate (if real) or base HTM (HTM of the 1st emitter)
%
%   The emitters are place in a nx x ny array at height Z, looking down
%   (i.e., with z axis pointing downwards) when Z is real valued or placed
%   starting at the location defined by the HTM Z, if Z is a 4x4 matrix.

%   14.11.2017  pf@ua.pt
%               Changed for Emitters with distinct Pb and Ps (Pt removed)

% TODO: Pb, PS and m are arrays with individual values for each emitter.

n_Emitters = nx * ny; 

Emitters = newEmitters(n_Emitters, Pb, Ps, m);

if (size(Z) == [1 1] )
    % No base HTM provided.
    % First emitter is at (0,0,Z), looking down
    HTM_E_base = Trans3(0,0,Z)*RotX3(pi);
else
    if(size(Z) == [4 4])
        % Z contains the base HTM (HTM of the first emitter)
        HTM_E_base = Z;
    else
        warning('Z must be real-valued or a HTM! Returning empty array.');
        Emitters = [];
        return;
    end
end

xvals = (1/(2*nx):1/nx:1)*Lx;

yvals = (1/(2*ny):1/ny:1)*Ly;

for ix = 1:nx
    for iy = 1:ny
        % Compute emitter HTM
        ri = iy + ny*(ix-1);
        Emitters(ri).HTM = Trans3(xvals(ix),yvals(iy),0)*HTM_E_base;
    end
end

end

