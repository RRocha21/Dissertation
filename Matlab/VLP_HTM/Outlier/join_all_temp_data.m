clear

load('cluster_new_53_1.mat','clustering')
clustering1=clustering;

load('cluster_new_53_2.mat','clustering')
clustering2=clustering;

load('cluster_new_53_3.mat','clustering')
clustering3=clustering;

load('cluster_new_53_4.mat','clustering')
clustering4=clustering;





for x_index=1:13
    for y_index=1:13
        clustering4(x_index,y_index)=clustering1(x_index,y_index);
    end

    for y_index=14:26
        clustering4(x_index,y_index)=clustering2(x_index,y_index);
    end
end


for x_index=14:26
    for y_index=1:13
        clustering4(x_index,y_index)=clustering3(x_index,y_index);
    end
end


clustering = clustering4;
