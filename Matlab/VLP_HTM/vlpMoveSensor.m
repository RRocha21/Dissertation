function [ displacedSensor ] = vlpMoveSensor( originalSensor , displHTM )
%VLPMOVESENSOR Displaces a sensor or a receiver array in 3D space
%   displacedSensor = vlpMoveSensor( originalSensor , displHTM )
%
%   The sensor is an array of Emitter_t structs. The sensors in the array
%   are displaced (translated and/or rotated) by the transformation defined in
%   the Homogeneous Transformation Matrix displHTM
%
%   VLPMOVESENSOR applies the transformation displHTM to all HTMs of the
%   sensors in the originalSensor structure. 


% This is the non-optimized version
% TODO: verify if vectorization can improve timing. 

displacedSensor = originalSensor;

for n = 1:numel(originalSensor)
    displacedSensor(n).HTM = displHTM * originalSensor(n).HTM;
end

end

