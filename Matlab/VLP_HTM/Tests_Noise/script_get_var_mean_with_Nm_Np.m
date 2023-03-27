%% script to plot the relationship between Np*Nm and the variance of the group locations calculated

load(['results\data_WACOWCmulti2_Ng_3.mat'])
params=data(1).params;
NmNp= params.NmNp;
Psi_v = params.Psi_v;

x_index = 10;
y_index = 25;
test_number =53;

% for test_number=1:65
    Np(test_number) = data(test_number).params.Np;
    Nm(test_number) = data(test_number).params.Nm;
    Psi(test_number) = data(test_number).params.Psi;
    
    plot(data(test_number).export(x_index,y_index).locations(1,:),data(test_number).export(x_index,y_index).locations(2,:),'*')
    hold on
    plot(params.Wstep*(x_index-1),params.Lstep*(y_index-1),'og')
%     error = 

    real_pos =[params.Wstep*(x_index-1),params.Lstep*(y_index-1)];
    
    % in x=13 y=13
    a=data(test_number).export(x_index,y_index).locations;
    b= a(find(a>=0 & a<=4));
%     b=ones(size(a))*params.Wstep*13;
    
%     b(find(a>=0 & a<=4))= a(find(a>=0 & a<=4));
    b=reshape(b,2,numel(b)/2)';
    valor_var = var(b);
    valor_medio = mean(b);
    error_da_media = norm(real_pos - valor_medio)
    
    
    
    plot(valor_medio(1),valor_medio(2),'*m');
    
    viscircles(valor_medio,max(valor_var));
    axis([0 4 0 4])
%     axis equal
% end
%%
% 
% valor_var
%     valor_medio
% 
% % % 
% % % figure(1)
% % % for index = 1 :13
% % % plot(Psi(5*index-1:5*index),valor_var(5*index-1:5*index,1))
% % % hold on
% % % end
% % % % plot(Nm.*Np,valor_var(:,2),'o')
% % % legend('Variancia X', 'Variancia Y');
% % % xlabel('Nm*Np')
% % % ylabel('Valor variancia')
% % % 
% % % figure(2)
% % % val =reshape(valor_var(:,1), 5,13);
% % % surf( NmNp(:,1).*NmNp(:,2),Psi_v', val)
% % % xlabel('Nm*Np')
% % % ylabel('Psi_v')
% % % 
% % % 
% % % % figure(3)
% % % % plot(Nm.*Np,error_da_media(:,1))
% % % % hold on
% % % % plot(Nm.*Np,error_da_media(:,2))
% % % 
% % % 
% % % 
% % % 
