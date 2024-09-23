function [result, depthMap] = own_Laplace(img)
% img: cell-array med bilder

% Check if the input is a cell array
if ~iscell(img)
    error('Input needs to be a cell array of images.')
end

% Antal bilder i fokusstacken
numImages = numel(img);

% Initiera en variabel för den slutgiltiga bilden
result = zeros(size(img{1}), 'like', img{1});

% Initiera djupkartan (distance map)
[rows, cols, ~] = size(img{1});
depthMap = zeros(rows, cols);  % Djupkartan baseras på Laplace-respons

% Skapa en variabel för att spara den maximala Laplace-responsen
maxLaplace = zeros(rows, cols);

% Gå igenom varje bild och tillämpa Laplaceoperatorn
for i = 1:numImages
    % Omvandla bilden till gråskala (om det är en RGB-bild)
    grayImg = rgb2gray(img{i});

    % Tillämpa Laplaceoperatorn för att hitta skarpa kanter
    laplaceResp = imfilter(double(grayImg), fspecial('laplacian', 0), 'replicate', 'conv');

    % Hitta skarpa områden i resultatbilden
    mask = abs(laplaceResp) > maxLaplace;
    result(repmat(mask, [1, 1, 3])) = img{i}(repmat(mask, [1, 1, 3])); % Applicera masken på alla RGB-kanaler

    % Uppdatera maxLaplace-responsen och djupkartan
    maxLaplace(mask) = abs(laplaceResp(mask));
    depthMap(mask) = i;  % Spara indexet av bilden där skärpan är bäst
end
end