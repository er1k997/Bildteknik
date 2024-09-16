folder = 'DanielBilder';
imageFiles = dir(fullfile(folder, '*.jpg'));

% Förbered en cell-array för att lagra bilderna
img = cell(1, numel(imageFiles)); 

% Läs in bilderna en efter en och lagra i cell-arrayen
for i = 1:numel(imageFiles)
    filename = fullfile(folder, imageFiles(i).name);  % Fullständig sökväg till bilden
    img{i} = imread(filename);  % Läs in bilden och lägg i cell-array
end

% Använd fstack-funktionen för att skapa en all-in-focus bild
%[edofimg, fmap, logresponse] = fstack(img);

%imshow(edofimg);
%imshow(fmap);
%imshow(logresponse);


%[edofimg, fmap, logresponse] = AIL(img);
result= own_AIG(img);
imshow(result);
score_piqe=piqe(result);
score_br = brisque(result);
score_niqe = niqe(result);
disp("Piqe: "+score_piqe);
disp("Brisque: "+score_br);
disp("Niqe: "+score_niqe);