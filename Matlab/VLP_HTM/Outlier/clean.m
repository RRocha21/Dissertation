%% remove Inf and NaN
function  [locations_new]= clean( locations )
[r,c]=size(locations);
j=1;
        while j<=c
            if  locations(1,j)==Inf || isnan(locations(1,j))==1
                locations(:,j)=0;
            end
            j=j+1;
        end
        for j=1:c
            if j<length(locations) && (locations(1,j)==0 && locations(2,j)==0)  
                locations(:,j)=[];
            else if j<length(locations) && (isnan(locations(1,j))==1) 
                 locations(:,j)=[];
            end
        end
        locations_new=locations;
end