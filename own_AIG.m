function final_img = own_AIG(img)

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
%Stores the maximum gradient magnitude for each pixel.
gradient_max = zeros(rows, cols);
% Stores the gradient magnitude for each pixel.
gradientresponse = zeros(rows, cols, 'single');
%Stores the index of the image with the maximum gradient magnitude at each pixel.
fmap = ones(rows, cols, 'single');
%Will store the final focused image.
final_img = zeros(rows, cols, channels, 'like', first_img);

% Process each image
for ii = 1:length(img)
    current_img = img{ii};
     

    % Convert to grayscale if necessary
    if colorimg
        gray_img = rgb2gray(current_img);
        %Equalice the britness in the pictures
        avg1 = mean(first_img(:));
        for i = 2:length(img)
            avgcur = mean(img{i}(:));
            img{i} = img{i} + ceil(avg1 - avgcur);  
        end
    else
        gray_img = current_img;
        avg1 = mean2(first_img);
        for i = 2 : length(img)
            avgcur = mean2(img{i});
            img{i} = img{i} + avg1 - avgcur;
        end
    end

    % Compute gradients
    [Gx, Gy] = imgradientxy(gray_img, 'intermediatedifference');
    abs_gradient = sqrt(Gx.^2 + Gy.^2);
    mask = abs_gradient > gradient_max;

    % Update gradient and focus map
    gradientresponse(mask) = abs_gradient(mask);
    fmap(mask) = ii;

    % Update the final image
    if colorimg
        index = repmat(mask, [1 1 3]);
        final_img(index) = current_img(index);
    else
        final_img(mask) = current_img(mask);
    end

    % Update gradient max
    gradient_max(mask) = abs_gradient(mask);
end

% Apply Gaussian filter to smooth the focus map
h = fspecial('gaussian', [blendsize blendsize], blendstd);
fmap = imfilter(fmap, h, 'same');

% Blend between focus planes
for ii = 1:length(img)-1
    index = fmap > ii & fmap < ii+1;
    if colorimg
        index = repmat(index, [1 1 3]);
        fmap_c = repmat(fmap, [1 1 3]);
        final_img(index) = (fmap_c(index) - ii).*single(img{ii+1}(index)) + ...
                           (ii + 1 - fmap_c(index)).*single(img{ii}(index));
    else
        final_img(index) = (fmap(index) - ii).*single(img{ii+1}(index)) + ...
                           (ii + 1 - fmap(index)).*single(img{ii}(index));
    end
end

end
