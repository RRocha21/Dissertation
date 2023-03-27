%VLPRECINDICATIONVERIFY Short example of vlpRecIndication usage

addpath('./../../projgeom/');

n_Em = 4;
n_Rec = 6;

testEm = CreateEmittersArray2(n_Em,.5,.25,1,2,2,3);
testRec = CreateReceiversArray2(n_Rec,25e-6,1,1,pi/2,1,2,2);

nRec_v = ones(n_Rec,1);

s_i = 1e-15*nRec_v;
s_v = 1e-9*nRec_v;
Z = 1e5*nRec_v;
Z_p = 1e7*nRec_v;

Bw = 1e8;
Theta = 300;

[Y nu] = vlpRecIndication(testEm, testRec, Bw, Z, s_i, s_v,Z_p,Theta)
