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

% Initialize variables
pyramids = cell(1, length(img));
num_levels=5;
% Process each image
for ii = 1:length(img)
    current_img = img{ii};

    % Convert to grayscale if necessary

%     avg1 = mean(first_img(:));
%     for i = 2:length(img)
%         avgcur = mean(img{i}(:));
%         img{i} = img{i} + ceil(avg1 - avgcur);  
%     end
    pyramids{ii} = buildLaplacianPyramid(current_img, num_levels); 

    % Compute gradients
    
end
%%print the different levels in the pyramid
% for img_idx = 1:length(pyramids)
%     for level = 1:num_levels
%         current_image = pyramids{img_idx}{level};  % Extrahera bilden från pyramidens nivå
%         figure, imshow(current_image, []);
%         title(['Image ' num2str(img_idx) ' - Laplacian Level ' num2str(level)]);
%     end
% end

%mask = zeros(rows, cols);

for level = 1:num_levels
    [rows2, cols2, channels2] = size(pyramids{1}{level});
    max_laplace_response = zeros(rows2, cols2, channels2);
    %Stores the index of the image with the maximum gradient magnitude at each pixel.
    fmap = ones(rows2, cols2, channels2,'single');
    %Will store the final focused image.
    final_img = zeros(rows2, cols2, channels2, 'like', pyramids{1}{level});
    
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
        current_laplace = double(current_laplace);
        final_img = double(final_img);
        mask = double(mask);
        
        if colorimg
            final_img(:,:,1) = final_img(:,:,1) + current_laplace(:,:,1) .* mask(:,:,1);
            final_img(:,:,2) = final_img(:,:,2) + current_laplace(:,:,2) .* mask(:,:,2);
            final_img(:,:,3) = final_img(:,:,3) + current_laplace(:,:,3) .* mask(:,:,3);
        else
            final_img = final_img + current_laplace .* mask;
        end
    end
end

final_img = reconstructFromLaplacianPyramid(pyramids, final_img, num_levels);

end
