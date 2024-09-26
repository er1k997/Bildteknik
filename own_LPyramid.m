function final_img = own_LPyramid(img)

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
% for img_idx = 1:length(pyramids)
%     for level = 1:num_levels
%         current_image = pyramids{img_idx}{level};  % Extrahera bilden från pyramidens nivå
%         figure, imshow(current_image, []);
%         title(['Image ' num2str(img_idx) ' - Laplacian Level ' num2str(level)]);
%     end
% end

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
end
