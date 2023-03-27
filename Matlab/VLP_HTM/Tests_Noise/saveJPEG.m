%function saveJPG()
% grava todas as figuras ativas em ficheiros jpeg
% O local de gravação é o diretório corrente e o nome da figura é o seu
% número por ordem de criação

% Obter os handles de todas as figuras
fig = get(0, 'children');

% Alterar as propriedades das figuras. Resize para a resolução do ecrã e
% indicar que a imagem é para ser imprimida com o mesmo número de pixeis
% que possui no ecrã 
% screensize = get(0, 'ScreenSize');
% set(fig, 'Position',[0 0 screensize(3) screensize(4)], 'PaperPositionMode','auto');

% para cada imagem, gravar em formato jpeg
for k = 1 : length(fig)
    saveas(fig(k), ['Fig' num2str(length(fig) - k + 1) '.jpeg'], 'jpeg')
end;

% 
%     screen_size = get(0, 'ScreenSize');
%     origSize = get(handle, 'Position'); % grab original on screen size
%     set(handle, 'Position', [0 0 screen_size(3) screen_size(4) ] ); %set to scren size
%     set(handle,'PaperPositionMode','auto') %set paper pos for printing
%     saveas(handle, fileName) % save figure
%     set(handle,'Position', origSize) %set back to original dimensions
