function [ location ] = trilateration_group_em( Emitters, radii )
%TRILATERATION_GROUP_EM Calculate the position by trilateration base on the
% data given

warning('off','all')

if( numel(radii)>= 3) 
    % Get the emitters position
    temp = [Emitters.HTM];
    pos_Em = temp(1:2,4:4:end);
    %Consider only accepted positions
    % pos_Em=pos_Em(:,group);
    % pos_Em = posEm(:,accepted);
    
    Xx = pos_Em(1,:);
    Yy = pos_Em(2,:);
    
    A=[ Xx(2:end)'-Xx(1) Yy(2:end)'-Yy(1)];
    B=0.5*((radii(1)^2-radii(2:end)'.^2) + (Xx(2:end)'.^2+Yy(2:end)'.^2) - (Xx(1)^2 + Yy(1)^2));
    
    location = (A'*A)^(-1)*A'*B;

end

end

