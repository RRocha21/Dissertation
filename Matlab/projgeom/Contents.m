% PROJGEOM commands for handling objects using projective geometry
%
%
% Euclidian transformations:
%   Trans3                - Translation along the vector r = [x,y,z]
%   RotX3                 - Rotation of an angle alpha around X axis.
%   RotY3                 - Rotation of an angle beta around Y axis.
%   RotZ3                 - Rotation of an angle gamma around Z axis.
%
% Perspective transformations:
%   PersProjMatrix        - Computes the Perspective Projection Matrix from camera parameters
%   PersProjMatrix1       - Computes the Perspective Projection Matrix from camera parameters
%
% Visualization:
%   plot2Dpoints          - Plots the points in 2D defined by array m.
%   plot3Dpoints          - Plots the points in 3D defined by array m.
%   plot3Drefaxis         - Plots the referential basis defined by homogeneous transformation matrix K.
%   PlotHTMArray          - Plots the HTMs in a struct array
%
% Auxilliary and miscelaneous: 
%   pgNormalize           - Normalize a vector or an array in homogeneous coordinates
%   pg2DcomputeProjTransf - Computes the Projective Transformation Matrix given 4 pairs of points
%   irradIncid            - Computes the irradiation and incidence angles
%
% Demo scripts
%   experience1           - Generates several objects and their view from cameras in different positions.
%   experience2           - Verification of the pg2DcomputeProjTransf function
%   objects               - Objects to be used in experience1
%   objects2              - Set of data objects for testing the computation of the projective transformation matrix
%
% Testing:
%   testirradincid        - Unit tests for the irradIndic.m function
