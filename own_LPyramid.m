function final_img = own_LPyramid(img)
<<<<<<< Updated upstream

% Check if the input is a cell array
if ~iscell(img)
    error('Input needs to be a cell array of images.')
end

% Get the size of the first image to initialize variables
first_img = img{1};
[rows, cols, channels] = size(first_img);

% Determine if the images are in color or grayscale
colorimg = (channels == 3);

% Parameters for Gaussian filtering
blendsize = 9;
blendstd = 10;   
% Normalisera alla bilder om det behövs
% avg1 = mean(first_img(:));
% for i = 2:length(img)
%     avgcur = mean(img{i}(:));
%     img{i} = img{i} + ceil(avg1 - avgcur);  % Justera ljusstyrkan
% end

% Initialize variables
pyramids = cell(1, length(img));
num_levels=5;
% Process each image
for ii = 1:length(img)
    
    
     current_img = img{ii};
       
        % Omvandla till gråskala om du vill jobba med svartvita bilder
        if ~colorimg
            current_img = rgb2gray(current_img);  % Konvertera om det är färg
        end

    pyramids{ii} = buildLaplacianPyramid(current_img, num_levels); 

  
end
%%print the different levels in the pyramid
=======
    % Kontrollera att ingången är en cell-array med bilder
    if ~iscell(img)
        error('Input needs to be a cell array of images.');
    end
    
    % Hämta storleken på den första bilden för att initiera variabler
    first_img = img{1};
    [rows, cols, channels] = size(first_img);
    
    % Parametrar för pyramidbyggnad
    num_levels = 5;
    
    % Om bilderna är i färg (3 kanaler) eller gråskala (1 kanal)
    colorimg = (channels == 3);
    
    % Initialisera pyramidstrukturen
    pyramids = cell(1, length(img));
    
    % Skapa Laplace Pyramid för varje bild
    for ii = 1:length(img)
        current_img = img{ii};
        
        % Omvandla till gråskala om du vill jobba med svartvita bilder
        % Konvertera om det är färg
        if ~colorimg
            current_img = rgb2gray(current_img); 
        end
        
        % Skapa Laplace Pyramid för aktuell bild
        pyramids{ii} = buildLaplacianPyramid(current_img, num_levels);  
    end

%-----------------  print the different levels in the pyramid ------------%
>>>>>>> Stashed changes
% for img_idx = 1:length(pyramids)
%     for level = 1:num_levels
%         current_image = pyramids{img_idx}{level};  % Extrahera bilden från pyramidens nivå
%         figure, imshow(current_image, []);  % [] används för att autoskalera bilden så att den visas korrekt
%         title(['Image ' num2str(img_idx) ' - Laplacian Level ' num2str(level)]);
%     end
% end
%-------------------------------------------------------------------------%

<<<<<<< Updated upstream
pyramid_final = cell(1, length(num_levels));
for level = 1:num_levels-1
     % Variables 
        [rows2, cols2, chennel2] = size(pyramids{1}{level});
        max_laplace_response = zeros(rows2, cols2, chennel2, 'uint8'); 
        fmap = ones(rows2, cols2, chennel2, 'single');  
        final_img = zeros(rows2, cols2, chennel2, 'uint8');
  
    for ii = 1:length(img)
        current_laplace = pyramids{ii}{level};
        % Find maximum Laplacian response for each pixel
        mask = abs(current_laplace) > max_laplace_response;
        max_laplace_response(mask) = abs(current_laplace(mask));
        fmap(mask) = ii;
    end
    
    % Update the final image based on the selected level
    for ii = 1:length(img)
        current_laplace = pyramids{ii}{level};
        mask = fmap == ii;
         mask_uint8 = uint8(mask);
        final_img = final_img + current_laplace .*mask_uint8;
        
        
    end
    

    pyramid_final{level}=final_img;
 
end

pyramid_final{num_levels}=pyramids{1}{num_levels};
%  for level = 1:length(pyramid_final) 
%     figure;
%     imshow(pyramid_final{level});
%     title([ ' Laplacian Level ' num2str(level)]);
% 
% end



final_img = reconstructFromLaplacianPyramid(pyramid_final, num_levels);
=======
%**************************** Sammanfoga Pyramiderna**********************%

% Vi skapar en ny pyramid som representerar den sammanfogade bilden
    fused_pyramid = cell(1, num_levels);
    
    for level = 1:num_levels
        % Hämta storleken för den aktuella nivåns bilder
        [rows2, cols2, channels2] = size(pyramids{1}{level});
        
        % Här lagrar vi de största Laplace-värdena för varje pixel
        max_laplace_response = zeros(rows2, cols2, channels2);
        
        % Här lagrar vi vilken bild som har det största Laplace-värdet för varje pixel
        fmap = ones(rows2, cols2, channels2, 'single');
        
        % Iterera genom varje bild och välj den med högsta Laplace-aktiviteten (absolutvärde)
        for ii = 1:length(img)
            current_laplace = pyramids{ii}{level};
            
            % Skapa en mask som väljer de pixlar där den aktuella bilden har högst Laplace-aktivitet
            mask = abs(current_laplace) > max_laplace_response;
            
            % Uppdatera max Laplace-respons och vilken bild som är "skarpast" på denna pixel
            max_laplace_response(mask) = abs(current_laplace(mask));
            fmap(mask) = ii;  % Sparar indexet för bilden som har störst värde
        end
        
        % Fyll i den sammanfogade pyramiden
        fused_level = zeros(rows2, cols2, channels2, 'like', pyramids{1}{level});
        for ii = 1:length(img)
            current_laplace = pyramids{ii}{level};
            mask = fmap == ii;  % De pixlar där den aktuella bilden valdes
            fused_level(mask) = current_laplace(mask);
            %fused_level(mask) = fused_level + current_laplace .* mask;
        end
        
        fused_pyramid{level} = fused_level;  % Lägg till denna nivå till den sammanfogade pyramiden
        figure
        imshow(fused_pyramid{level})
    
    end
    
        %******************** Rekonstruktion från Laplace-pyramiden ********************
    final_img = reconstructFromLaplacianPyramid(fused_pyramid, num_levels);    
end

function reconstructed_img = reconstructFromLaplacianPyramid(laplace_pyramid, num_levels)
    % Rekonstruera bilden från Laplace-pyramiden
    reconstructed_img = laplace_pyramid{num_levels};  % Börja från den lägsta nivån
    
    for level = num_levels-1:-1:1
        % Skala upp den nuvarande nivån till nästa högre nivå
        [rows, cols, ~] = size(laplace_pyramid{level});
        reconstructed_img = imresize(reconstructed_img, [rows, cols]);  % Uppskala
        
        % Lägg till Laplace-detaljerna från den högre nivån
        reconstructed_img = reconstructed_img + laplace_pyramid{level};
    end
    
>>>>>>> Stashed changes
end
