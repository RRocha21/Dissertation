function [ f1 ] = drawPoly( poly,color)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
f1 = plot3(poly(1,:),poly(2,:), poly(3,:),color,'LineWidth',1);


end

