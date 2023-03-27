function [ Y nu ] = vlpRecIndication( Emit, Rec, Bw, Z, s_i, s_v, Z_p, Theta )
%VLPRECINDICATION Computes the signal received by a photodiode sensor
%
%   [ Y nu ] = vlpRecIndication( Emit, Rec, Bw, Z, s_i, s_v, Z_p, Theta )
%   
%   Simulates a set of photo-diodes (receivers) generating a signal in
%   response to the optical power received from a set of light emitters.
%   The output corresponds to the electrical signal at the output of the
%   conditioning circuit that amplifies the photo current.
%
%
%     Emit -    Struct array of Emitters
%     Rec -     Struct array of Receivers
%     Bw -      Bandwidth of receiver circuit
%     Z -       Vector with the transimpedance feedback resistors
%     s_i -     Vector with the operational amplifiers current PSD
%     s_v -     Vector with the operational amplifiers voltage PSD
%     Z_p -     Vector with the photo-diode equivalent impedances
%     Theta -   Thermodynamic temperature of feedback resistor, in Kelvin
% 
%   Output:
%     Y -       Matrix with the signal amplitude detected at every receiver
%               resulting from light coming from every emitter
%     nu -      Vector with the noise power at every receiver (referred to
%               the circuit output).
%
%   The model is described in DOI: 10.13140/RG.2.2.31780.58248 

% Check for input sanity
assert(isstruct(Emit),'Emit must be a struct.');
assert(isstruct(Rec),'Rec must be a struct.');
assert(isfloat(Bw),'Bw must be real valued.');
assert(isfloat(Z),'Z must be real valued.');
assert(numel(Z)==numel(Rec),'Size of Z must be the size of Rec.');
assert(isfloat(s_i),'s_i must be real valued.');
assert(numel(s_i)==numel(Rec),'Size of s_i must be the size of Rec.');
assert(isfloat(s_v),'s_v must be real valued.');
assert(numel(s_v)==numel(Rec),'Size of s_v must be the size of Rec.');
assert(isfloat(Z_p),'Z_p must be real valued.');
assert(numel(Z_p)==numel(Rec),'Size of Z_p must be the size of Rec.');
assert(isfloat(Theta) & Theta>0,'Theta must be real valued and positive.');

% Constants:
q = 1.602176487e-19;    % Electron charge
k_B = 1.38064852e-23;   % Boltzmann constant


% Number of receivers
n_Rec = numel(Rec);

% Check for size of Z, s_i, s_v and Z_p
% TODO: Check for size of Z, s_i, s_v and Z_p

% Transform Z into a diagonal matrix
Zm = diag(Z);

% Compute A, B and F matrices
A = Receiver2A(Rec);
B = Emitter2B(Emit);
F = EmitRec2F(Emit,Rec);
H = A*F*B;

% Compute the received power

% Get emitter power components 
Pb_v = [Emit.Pb];       % Vector with the Pb values
Pb_v = Pb_v(:);         % Make sure Pb_v is a column vector
Ps_v = [Emit.Ps];       % Vector with the Ps values

% Create Pt matrix
Pt = [ Pb_v(:) diag(Ps_v) ];

% Compute received power, Pr
% Pr is of the form [ nb | Q ] where nb is the noise component and Q a
% diagonal matrix containing the power associated to the signal components.
nb = H * Pb_v;
Q  = H * diag(Ps_v);

Pr = [nb Q ];

% Create a vector with receivers' Responsivity
R_v = [ Rec.R ];

R = diag(R_v);

% Compute Y, signal detected (without noise)
Y = Zm*R*Q;

% Compute noise level vector
nu = (Zm*Zm*(2*q*R*nb + s_i.^2) + 4*k_B*Theta*Z + ...
  (abs(1+Z./Z_p).*s_v).^2)*Bw;

end

