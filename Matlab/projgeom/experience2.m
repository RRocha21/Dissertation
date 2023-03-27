% EXPERIENCE2 Verification of the pg2DcomputeProjTransf function


% Initial points
M1 = [ -1   -1   1
       1   -1   1
      -1    1   1
       1    1   1]'
   
   
links = [1 2
         1 3
         3 4
         2 4]';

% Transformation matrix
H = [ 1 2 3
      4 5 6
      7 8 7 ]

% Image points
m1 = H*M1

% load objects
objects2

% Estimate H from M and m
He = pg2DcomputeProjTransf(M1,m1)

H/H(9)

alpha=pi/6;

H2 = [   cos(alpha) sin(alpha) 3
        -sin(alpha) cos(alpha) 2
              0           0    1 ];
          
m1a = H2*M1;

H2e = pg2DcomputeProjTransf(M1,m1a)
