function T = Trans3(x,y,z)
% TRANS3 Translation along the vector r = [x,y,z]
%   T = Trans3(x,y,z)
%   T = Trans3(r)
%
%   If x,y,z are given, these are considered as the 3 coordinates of the
%   displacement vector. If only one value is given, this is taken as the
%   displacement vector. The displacement vector must be a 3x1 column
%   vector.

% Create matrix T
T = eye(4);

% Check for arguments
if nargin==3
    % x,y,z given explicitely
    T(1:3,4) = [x y z]';
elseif nargin==1
    % Test for size of the vector
    if size(x,1) == 3 
        % x is a column vector with 3 elements
        % or an array with 3 lines; in this case, the first column is taken
        % as the displacement vector
        T(1:3,4) = x(:,1);
        if size(x,2) > 1
            warning('''x'' is not a vector; only first column taken');
        end
    else
        error('Invalid size for argument ''x''');
    end
    
else
    error('Invalid arguments.')
end

% TODO: allow to express displacement vector in homogeneous coordinates.
