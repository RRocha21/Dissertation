function  [] = saveImg(directory, extension)
% saveImg -  Saves all open images to the desired format
%
% USAGE 
%   [] = saveImg(type, name)
% 
% INPUT
%   NONE
%
% PARAMETERS
%   directory : The directory to save images
%   extension : Image extension type 
%
% OUTPUT
%   NONE
%
%
% SUPPORTED EXTENSIONS 
%  'fig', 'png', 'jpeg', 'eps', 'pdf', 'bmp', 'ems', 'tif'
% 

validExt = {'fig', 'png', 'jpeg', 'eps', 'pdf', 'bmp', 'ems', 'tif'};

% Get all open figures
h = get(0,'children');

% Assert valid extension type
assert(sum(strcmp(extension, validExt)) == 1, [extension ' is not a supported figure extension.'])

for k=1:length(h)
    saveas(h(k), [directory + 'Fig ' num2str(length(h)+1-k)], extension);
end

