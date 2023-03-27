function [ res params] = shapeResults( resultsdir, resultfn, m, Np, Nm, Psi, Nrep)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


resultsfilename = createResultFilename( resultsdir, resultfn, m, Np, Nm, Psi, Nrep);

if exist(resultsfilename) ~= 2
  % Try with Psi in degrees
  resultsfilename = createResultFilenamed( resultsdir, resultfn, m, Np, Nm, Psi, Nrep);
  if exist(resultsfilename) ~= 2 
    error('File "%s" not found! Check filename.\n',resultsfilename);
  end
end

load(resultsfilename);

% Position in x and y
xloc = 0:params.Wstep:params.W;
yloc = 0:params.Lstep:params.L;

nWsteps = numel(xloc);
nLsteps = numel(yloc);

res.locerroravg = reshape([results.locerroravg],nWsteps,nLsteps);
res.locerrorstd = reshape([results.locerrorstd],nWsteps,nLsteps);
res.locerrormax = reshape([results.locerrormax],nWsteps,nLsteps);

res.raderroravg = reshape([results.raderroravg],nWsteps,nLsteps);
res.raderrorstd = reshape([results.raderrorstd],nWsteps,nLsteps);
res.raderrormax = reshape([results.raderrormax],nWsteps,nLsteps);


end

