function [ Emitters ] = CreateEmittersArray2( n_Emitters, Pb, Ps, m, Lx, Ly, Z )
%CREATEEMITTERSARRAY2 Creates a regularly spaced 2 dimensional array of n_Emitters
%   Emitters = CreateEmittersArray( n_Emitters, Pt, m, Lx, Ly, Z )
%
%   n_Emitters  - number of emitters
%   Pb          - Power in the base (DC) component in each emitter
%   Ps          - Power in the signal component in each emitter
%   m           - Lambertian order of the emitter
%   Lx, Ly      - Total length of the array in x and y directions, resp.
%   Z           - z coordinate (if real) or base HTM (HTM of the 1st emitter)
%
%   The emitters are place in a nx x ny array, where nx*ny= n_Emitters at
%   height Z, looking down (i.e., with z axis pointing downwards) when Z is
%   a real value or placed starting at the location defined by the HTM Z.

%   14.11.2017  pf@ua.pt
%               Changed for Emitters with distinct Pb and Ps (Pt removed)

% TODO: Pb, PS and m are arrays with individual values for each emitter.


[ nx , ny ] = factorise2(n_Emitters);

Emitters = CreateEmittersArray(nx, ny, Pb, Ps, m, Lx, Ly, Z);
