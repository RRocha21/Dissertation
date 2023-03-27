function [ H ] = H0_ER( HTM_E, HTM_R, m, Ar, varargin )
%H0_ER Compute OWC channel gain (deprecated)
%
%   H0_ER( HTM_E, HTM_R, m, Ar ) 
%   H0_ER( HTM_E, HTM_R, m, Ar, FOV ) 
%   H0_ER( HTM_E, HTM_R, m, Ar, FOV, n ) 
%   H0_ER( HTM_E, HTM_R, m, Ar, FOV, n, Ts ) 
%
%   OWC channel gain 
%
%   Computes the DC gain of a optical channel from emitter to receiver
%   following the models defined by Gfeller and Bapst [1] and Barry et al
%   [2]. 
%
%   The position and orientation of emitter and receiver are defined
%   by Homogeneous Transformation Matrices HTM_E and HTM_R. The axis of
%   emitter and receiver are aligned with the respective z axis.
%
%   m is the Lambertian order of the emitter, Ar the sensor area at the
%   receiver; FOV is the semi-angle for the Field of View; n is the
%   internal refractive index of the receiver; Ts is the signal
%   transmission gain of the filter. 
%
%   If FOV is omitted, it defaults to pi/2; if n is omitted, no
%   concentrator gain is considered, and the FOV is defined by obstructing
%   the field of view; if Ts is omitted, it defaults to 1. 
%
%   HTM_E : HTM with position and orientation of emitter;
%   HTM_R : HTM with position and orientation of receiver;
%   m : Lambertian mode number of emitter; 
%   Ar : area of receiver detection surface;
%   FOV : semi-angle for field of view;
%   n : refractive index of non-imaging optical concentrator;
%   Ts : optical filter gain.
%
%   [1] F. R. Gfeller and U. Bapst, ‘Wireless in-house data communication 
%   via diffuse infrared radiation’, Proceedings of the IEEE, vol. 67, no. 
%   11, pp. 1474–1486, 1979.
%   [2] J. R. Barry, J. M. Kahn, W. J. Krause, E. A. Lee, and D. G. 
%   Messerschmitt, ‘Simulation of multipath impulse response for indoor 
%   wireless optical channels’, IEEE Journal on Selected Areas in 
%   Communications, vol. 11, no. 3, pp. 367–379, Apr. 1993.

narginchk(4,7);

% Get emitter and receiver position
P_e = HTM_E(1:3,4);
P_r = HTM_R(1:3,4);

% Get emitter and receiver orientation. 
n_e = HTM_E(1:3,3);
n_r = HTM_R(1:3,3);

% Receiver and emitter must be facing each other
if dot(n_e,n_r) > 0
    % not facing...
    H = 0;
    return
end

% Compute distance from emitter to receiver
d = norm(P_e - P_r);

% Compute u, the versor in the direction P_e to P_r: 
u = (P_r - P_e)/d;

% Default values
g = 1; 
Ts = 1; 

% Check 5th argument: FOV
if nargin > 4 
    % incidence angle must be computed
    Theta = acos(dot(n_r,-u));

    FOV = varargin{1};
    
    % Check for 6th argument: n
    if nargin > 5
        % A non-imaging is considered
        % n is the internal refractive index of the non-imaging
        % concentrator
        n = varargin{2};
        g = (n / sin(FOV) )^2;
    end
    
    % restrict to the FOV
    g = g*rectangularPulse(-FOV,FOV,Theta);
    
    % Check 7th argument: Ts (filter gain)
    if nargin == 7
        Ts = varargin{3};
    end
end


H = (m+1)/(2*pi)*Ar*Ts*g*(dot(n_e,u)^m)*dot(n_r,-u)/d^2;

if H<0
    H=0;
end

end

