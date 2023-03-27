function SensorArray = vlpCreateSensorParMer(PDArray, NParal,NMerid, r, varargin)
%VLPCREATESENSORPARMER Creates a VLP sensor with parallels and meridians
%
%   SensorArray = vlpCreateSensorParMer(PDArray, NParal, NMerid, r, PMerid, PParal)
%   SensorArray = vlpCreateSensorParMer(PDArray, NParal, NMerid, r, PMerid)
%   SensorArray = vlpCreateSensorParMer(PDArray, NParal, NMerid, r)
%
%   vlpCreateSensorParMer gets an array of photodetectors PDArray and
%   creates a PD sensor, by placing them in a sphere of radius r
%   (eventually zero) at the intersection of the NParal parallels and
%   NMerid meridians in the sphere surface. The z-axis of the sensor points
%   outward, normal to the sphere surphace.
%
%   The construction does not include the vertical ("north-pole") sensor.
%   The sensor is a hemi-spherical dome, where photo-diodes are regularly
%   placed, over NMerid meridians and NParal paralels. The phase arguments
%   are optional; if included, the photodiode location will not start at
%   zero, but at the angle PMerid (for azimuth) and PParal (for elevation).
%
%   Note that the effect of phase is different in the azimuth and
%   elevation. In azimuth, the phase causes a shift in the position of all
%   sensors. In elevation, the phase is the position of the least elevated
%   sensor and the remaining sensors are equally distributed from the
%   initial point and pi/2 (not including).
%
%   The user must guarantee that the number of receivers in PDArray
%   corresponds to NParal*NMerid
%
%   See also NEWRECEIVERS

if(numel(PDArray) ~= NParal*NMerid)
    error('Size of PDArray does not correspond to NParal*NMerid');
end

% Default values
% Meridian start phase
PMerid = 0;

% Paralel start phase
PParal = 0;

% Processing the input arguments
nVarargs = length(varargin);
if (nVarargs >= 1)
	PMerid = varargin{1};
	if nVarargs >=2
		PParal = varargin{2};
	end
end

% Compute the base HTM. 
% This HTM will be first place with z axis aligned with x axis of base
% reference frame (real world coordinates). It will then be rotated along
% (real world) z (for the meridians) and 

% Create a Base_HTM with z aligned with X;
Base_HTM = eye(4)*RotY3(pi/2);
% This HTM is rotated pi along X, so that rotation in y corresponds to
% elevation
Base_HTM = RotX3(pi)*Base_HTM;

SensorArray = PDArray;

% The following cycles compute the elevation and azimuth angles and adjust
% the sensors orientation
for m = 0:NMerid-1
    for p = 0:NParal-1
        
        index = m*NParal + (p+1);
        
        % Compute azimuth and elevation
        azimuth = PMerid + m*2*pi/NMerid;
        elevation = PParal + (p*(pi/2-PParal))/NParal;
        
        % Rotate base HTM.
        % Base HTM is rotated by:
        % - the azimuth angle along Z axis (base coords)
        % - the elevation angle along base HTM's y axis
        % Finally, the HTM is translated by distance r over z (sensor frame) axis
        SensorArray(index).HTM = RotZ3(azimuth)*Base_HTM*RotY3(elevation)*Trans3(0,0,r);
        
    end
end


end

