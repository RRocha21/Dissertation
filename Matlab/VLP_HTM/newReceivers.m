function [ Receivers ] = newReceivers( varargin )
%NEWRECEIVERS Creates new Receivers
%   Receivers = newReceivers(n_Receivers, Ar, Ts, n, Psi,R)
%   Receivers = newReceivers(Ar, Ts, n, Psi,R)
%   Receivers = newReceivers(n_Receivers)
%   Receivers = newReceivers()
% 
%   n_Receivers - number of receivers
%   Ar          - receiver's sensing area (default: 0.01)
%   Ts          - receiver filter gain (default: 1)
%   n           - receiver's internal refractive index (default: 1)
%   Psi         - Hemi-FOV (default: pi/2)
%   R           - Receiver's responsivity
%
%   Creates an emitter of an array of n_Receivers receivers. If n_Receivers
%   is omitted, Receivers has 1 single element. If all other arguments are
%   omitted, they get the default value. 
%
%   The HTM of the receivers are placed at the origin. 

% Default values
Ar = 0.01;
Ts = 1;
n = 1;
Psi = pi/2;
Pr = 0;
R = 1;

if (nargin == 6)
    n_Receivers = varargin{1};
    Ar = varargin{2};
    Ts = varargin{3};
    n = varargin{4};
    Psi = varargin{5};
    R = varargin{6};
    
elseif (nargin == 5)
    n_Receivers = 0;
    Ar = varargin{1};
    Ts = varargin{2};
    n = varargin{3};
    Psi = varargin{4};
    R = varargin{5};
elseif (nargin == 1)
    n_Receivers = varargin{1};
    
elseif (nargin == 0)
    n_Receivers = 0;
    Ar = [];
    Ts = [];
else
    error('Incorrect number of arguments.');
end

% Create the receiver structure:
Receiver_t = struct('HTM',{},'Ar',{},'Ts',{},'n',{},...
    'Psi',{},'Pr',{},'R',{});

if(numel(Ar) == 1)
    % Receiver parameters are defined
    Receiver_t(1).Ar = Ar;
    Receiver_t(1).Ts = Ts;
    Receiver_t(1).n = n;
    Receiver_t(1).Psi = Psi;
    Receiver_t(1).Pr = Pr;
    Receiver_t(1).R = R;
    Receiver_t(1).HTM = eye(4);
end

if (n_Receivers == 0)
    % Receivers is just a single struct
    Receivers = Receiver_t;
    return;
else
    % Replicate to create the receivers array:
    Receivers = repmat(Receiver_t,1,n_Receivers);
end

end

