folder = 'DanielBilder';
imageFiles = dir(fullfile(folder, '*.jpg'));

% Förbered en cell-array för att lagra bilderna
img = cell(1, numel(imageFiles)); 
noise_img=cell(1,numel(imageFiles));

% Läs in bilderna en efter en och lagra i cell-arrayen
for i = 1:numel(imageFiles)
    filename = fullfile(folder, imageFiles(i).name);  
    img{i} = imread(filename);
    noise_img{i} = imnoise(img{i},"salt & pepper",0.03);
end

%Utvärdera AIL
[ailimg, fmap_ail, logresponse_ail] = AIL(img);
figure;
imshow(ailimg);
title('AIL');
score_piqe_ail=piqe(ailimg);
score_br_ail = brisque(ailimg);
score_niqe_ail = niqe(ailimg);
disp("Piqe: "+score_piqe_ail);
disp("Brisque: "+score_br_ail);
disp("Niqe: "+score_niqe_ail);


%Utvärdera Log
[edofimg, fmap, logresponse] = fstack(img);
figure;
imshow(edofimg);
title('Log');
score_piqe_log=piqe(edofimg);
score_br_log = brisque(edofimg);
score_niqe_log = niqe(edofimg);
disp("Piqe: "+score_piqe_log);
disp("Brisque: "+score_br_log);
disp("Niqe: "+score_niqe_log);

%salt and pepar LOG
[edofimg_noise, fmap, logresponse] = fstack(noise_img);
figure;
imshow(edofimg_noise);
title('Log nosie');
score_piqe_log2=piqe(edofimg_noise);
score_br_log2 = brisque(edofimg_noise);
score_niqe_log2 = niqe(edofimg_noise);
disp("Piqe noise: "+score_piqe_log2);
disp("Brisque noise: "+score_br_log2);
disp("Niqe nosie: "+score_niqe_log2);

%Utvärdera AIG  
result= own_AIG(img);
figure;
imshow(result);
title('own AIG');
score_piqe=piqe(result);
score_br = brisque(result);
score_niqe = niqe(result);
disp("Piqe: "+score_piqe);
disp("Brisque: "+score_br);
disp("Niqe: "+score_niqe);

%salt and pepar AIG
result_noise = own_AIG(noise_img);
figure;
imshow(result_noise);
title('AIG nosie');
score_piqe_aig2=piqe(result_noise);
score_br_aig2 = brisque(result_noise);
score_niqe_aig2 = niqe(result_noise);
disp("Piqe noise: "+score_piqe_aig2);
disp("Brisque noise: "+score_br_aig2);
disp("Niqe nosie: "+score_niqe_aig2);