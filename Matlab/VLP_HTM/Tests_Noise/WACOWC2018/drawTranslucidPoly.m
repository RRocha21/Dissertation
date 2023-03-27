function [ f1 ] = drawTranslucidPoly( poly,color,alpha )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
f1 = fill3(poly(1,:),poly(2,:), poly(3,:),color);
set(f1,'facealpha',alpha)


end

