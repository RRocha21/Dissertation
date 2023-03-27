function [ Emitters ] = newEmitters( varargin )
%NEWEMITTERS Creates new Emitters
%   Emitters = newEmitters(n_Emitters, Pb, Ps, m);
%   Emitters = newEmitters(Pb, Ps, m);
%   Emitters = newEmitters(n_Emitters);
%   Emitters = newEmitters();
%
%   n_Emitters  : number of emitters to create
%   Pb          : DC component of transmitted power
%   Ps          : signal component of transmitted power
%   m           : Lambertian mode number
%
%   Creates an emitter of an array of n_Emitters emitters. If n_Emitters is
%   omitted, Emitters has 1 single element. If Pb, Ps and m are omitted, Pb
%   and Ps default to 0 and m defaults to 1.
%
%   The HTM of the emitters are placed at the origin.
%

%   14.11.2017  pf@ua.pt
%               Emitters structure changed to include Pb and Ps (Pt
%               removed)

% TODO: Pt and m are [n_Emitters x 1] arrays with the individual values of
% Pt and m for every emitter


narginchk(0,4);

if (nargin == 4)
  n_Emitters = varargin{1};
  Pb = varargin{2};
  Ps = varargin{3};
  m = varargin{4};
elseif (nargin == 3)
  n_Emitters = 0;
  Pb = varargin{1};
  Ps = varargin{2};
  m = varargin{3};
elseif (nargin == 2)
  warning('Called with 2 arguments. Treated as zero arguments.');
  n_Emitters = 0;
elseif (nargin == 1)
  n_Emitters = varargin{1};
  Pb = 0;
  Ps = 0;
  m = 1;
else
  n_Emitters = 0;
end

% Create the emitter structure:
Emitter_t = struct('HTM',{},'Pb',{},'Ps',{},'m',{});

if(exist('Pb') == 1)
  % Pb, Ps and m are defined. Either n_Emitters or these variables were
  % defined in the arguments
  Emitter_t(1).Pb = Pb;
  Emitter_t(1).Ps = Ps;
  Emitter_t(1).m  = m;
  Emitter_t(1).HTM = eye(4);
end

if (n_Emitters == 0)
  % Emitters is just a single struct
  Emitters = Emitter_t;
  return;
else
  % Replicate to create the receivers array:
  Emitters = repmat(Emitter_t,1,n_Emitters);
end

end

