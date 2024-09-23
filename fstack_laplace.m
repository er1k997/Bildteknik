function [focusedImage, varargout] = fstack_laplace(images, varargin)
    % FOCUSSTACKLAPLACE merges images from multiple focal planes into one sharp image.
    if ~iscell(images)
        error('Input must be a cell array of images.');
    end

    % Parse parameters
    params = parseParameters(varargin);

    % Convert to grayscale if needed
    if size(images{1}, 3) > 1
        imagesGray = cellfun(@(img) rgb2gray(img), images, 'UniformOutput', false);
        colorImages = true;
    else
        imagesGray = images;
        colorImages = false;
    end

    % Normalize image brightness
    imagesGray = normalizeImageBrightness(imagesGray);

    % Apply Laplacian filter and dilation
    filteredImages = cellfun(@(img) applyLaplacianAndDilate(img, params.filterSize, params.dilateSize), imagesGray, 'UniformOutput', false);

    % Compute focus map and Laplacian response
    [focusMap, laplaceResponse] = computeFocusMap(filteredImages, params.laplaceThreshold);

    % Blend images based on the focus map
    focusedImage = blendImages(images, focusMap, colorImages);

    if nargout >= 2
        varargout{1} = focusMap;
    end
    if nargout == 3
        varargout{2} = laplaceResponse;
    end
end

% Parse parameters
function params = parseParameters(args)
    defaultParams = struct('filterSize', 3, 'dilateSize', 31, 'blendSize', 31, ...
                           'blendStd', 5, 'laplaceThreshold', 0);
    params = defaultParams;
    if ~isempty(args)
        for i = 1:2:length(args)
            param = lower(args{i});
            if isfield(params, param)
                params.(param) = args{i+1};
            end
        end
    end
end

% Normalize brightness
function images = normalizeImageBrightness(images)
    avgFirst = mean(images{1}(:));
    images = cellfun(@(img) img + (avgFirst - mean(img(:))), images, 'UniformOutput', false);
end

% Apply Laplacian and dilation
function filteredImage = applyLaplacianAndDilate(image, filterSize, dilateSize)
    laplaceFilter = fspecial('laplacian', 0) * (filterSize / 3);
    filteredImage = imfilter(double(image), laplaceFilter);
    se = strel('ball', dilateSize, dilateSize);
    filteredImage = imdilate(filteredImage, se, 'same');
end

% Compute focus map
function [focusMap, laplaceResponse] = computeFocusMap(filteredImages, threshold)
    imgSize = size(filteredImages{1});
    numImages = length(filteredImages);
    focusMap = ones(imgSize, 'single');
    laplaceResponse = zeros(imgSize, 'single') + threshold;

    for i = 1:numImages
        mask = filteredImages{i} > laplaceResponse;
        laplaceResponse(mask) = filteredImages{i}(mask);
        focusMap(mask) = i;
    end

    % Ensure focusMap values are valid image indices (1 to numImages)
    focusMap = min(max(focusMap, 1), numImages);
end

% Blend images based on focus map
function blendedImage = blendImages(images, focusMap, colorImages)
    blendedImage = images{1}; % Start with the first image

    for i = 1:length(images) - 1
        mask = focusMap > i & focusMap < i + 1;
        if colorImages
            mask = repmat(mask, [1 1 3]);
        end
        if any(mask(:))
            % Linear interpolation between images based on focus map
            blendedImage(mask) = (focusMap(mask) - i) .* double(images{i + 1}(mask)) + ...
                                (i + 1 - focusMap(mask)) .* double(images{i}(mask));
        end
    end
end
