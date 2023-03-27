function [ fn ] = createResultFilename( resultsdir, resultfn, m, Np, Nm, Psi, Nrep)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
fn = [resultsdir resultfn '_' num2str(m) '_' ...
  num2str(Np) '_' num2str(Nm) '_' ...
  num2str(round(180/pi*Psi)) '_' ...
  num2str(Nrep) '.mat'];


end

