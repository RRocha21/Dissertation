% OBJECTS2 Set of data objects for testing the computation of the projective transformation matrix

% Transformation matrix
H = [ 1 2 3
      4 5 6
      7 8 7 ]

  
% Initial points
M = [ -1   -1   1
       1   -1   1
      -1    1   1
       1    1   1]'
   
   
links = [1 2
         1 3
         3 4
         2 4]';
     
% Image points
m = H*M
