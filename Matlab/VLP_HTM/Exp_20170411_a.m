% Compute the received power in a set of receivers from a set of emitters using A, B and F matrices.

clearvars

% Sets with the number of emitters and receivers
% n_Ev = [ 2 4 10 20 40 100 ];
% n_Rv = [ 2 4 10 20 40 100 200 400 ];
n_Ev = [ 2 4 10 ];
n_Rv = [ 2 4 10 ];

% Setup the environment conditions
DefineSpace;

% Emitters data
Pt = 1;
m = 10;

% Receivers data
Ts = 1;
n = 1;
Psi = pi/2;
R = 1;

ind = 0;
for n_E = n_Ev
    
    i_e = find(n_E == n_Ev);
    
    for n_R = n_Rv
        
        i_r = find(n_R == n_Rv);
        
        ind = ind+1;
        
        clearvars Emitters Receivers A B F Pr
        
        % Create the emitters set
        Emitters = CreateEmittersArray2 (n_E, Pt, m, Lx, Ly, Lz);
        
        % Create the receivers set
        Receivers = CreateReceiversArray2 (n_R, dx*dy, Ts, n, Psi, R, Lx, Ly);
        
        tic
        % Create the matrices
        A = Receiver2A(Receivers);
        t(1,i_e,i_r)=toc;
        
        B = Emitter2B(Emitters);
        t(2,i_e,i_r)=toc;
        
        F = EmitRec2F(Emitters, Receivers);
        t(3,i_e,i_r)=toc;
        
        % Compute the received power
        
        Pr = A*F*B*[Emitters.Pt]';
        t(4,i_e,i_r)=toc;
        
    end
end

time_frac = squeeze((t(4,:,:)- t(3,:,:))./t(4,:,:));
time_total = squeeze(t(4,:,:));

% to contains the time per each operation
to = [  t(1,:,:)
        diff(t) ];
