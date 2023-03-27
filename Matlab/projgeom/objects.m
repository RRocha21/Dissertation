% Objects to be used in experience1

%% Set #1

% M1: Cube centered in (0,0,0) and length 2
M1 = [  -1 -1  2  1
        -1  1  2  1
         1 -1  2  1
         1  1  2  1 ]';
         
M1 = [M1 M1];

M1(3,5:8) = [4 4 4 4];
        
%% Set #2

% M2: 16 points grid in the vertical plane y=0

M2=zeros(4,16);

for i = 1:4
    for j = 1:4
        M2(:,i+(j-1)*4) = [ (i-1) 0 (j-1) 1]';
    end
end

% M2a: 14 points prid: M2 with 1 point removed

% Array with points
M2a = [ M2(:,1:9) M2(:,11:16)];

% Links between points
links2a = [ 1 2
2 3
3 4
1 5
2 6
3 7
4 8
5 6
6 7
7 8
5 9
7 10
8 11
10 11
9 12
10 14
11 15
12 13
13 14
14 15]';

% M2b: "thick" M2a

M2b = [M2a M2a];
npoints = size(M2b,2)

M2b(2,npoints/2+1:npoints)=1;

links2b = [links2a links2a+npoints/2 [1:npoints/2;npoints/2+1:npoints] ];

