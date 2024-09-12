function [edofimg, varargout] = AIG(img,varargin)
% FSTACK merging images of multiple focal planes into one in-focus image.
% Using Absolute Image Gradient (AIG) instead of Laplacian of Gaussian (LoG).

if ~iscell(img)
    error('Input needs to be cell array of images.')
end

dilatesize = checkparam('dilatesize', 31);
blendsize = checkparam('blendsize', 31);
blendstd = checkparam('blendstd', 5);
threshold = checkparam('threshold', 0); % Replace 'logthreshold' with 'threshold'

function val = checkparam(param, defaultval, varargin)
    if any(strcmpi(varargin, param))
        val = varargin{find(strcmpi(varargin, param))+1};
    else
        val = defaultval;
    end
end

if (numel(size(img{1}))>2)
    imgcopy = img;
    colorimg = true;
    for ii = 1:length(imgcopy)
        img{ii} = rgb2gray(img{ii});
    end
else
    colorimg = false;
end

% Equalize brightness
if ~colorimg
    avg1 = mean2(img{1});
    for ii = 2 : length(img)
        avgcur = mean2(img{ii});
        img{ii} = img{ii} + avg1 - avgcur;
    end
else
    avg1 = mean(imgcopy{1}(:));
    for ii = 2:length(imgcopy)
        avgcur = mean(imgcopy{ii}(:));
        imgcopy{ii} = imgcopy{ii} + ceil(avg1 - avgcur);  
    end
end

imgfiltered = cell(size(img));

se = strel('ball', dilatesize, dilatesize);

for ii = 1:length(img)
    % Calculate Absolute Image Gradient
    [Gx, Gy] = gradient(single(img{ii}));
    imgfiltered{ii} = sqrt(Gx.^2 + Gy.^2); % Gradient magnitude
    imgfiltered{ii} = imdilate(imgfiltered{ii}, se, 'same');
end

fmap = ones(size(img{1}), 'single');
gradientresponse = zeros(size(img{1}), 'single') + threshold;

% Find the focal plane with the largest Absolute Image Gradient response
for ii = 1:length(img)
    index = imgfiltered{ii} > gradientresponse;
    gradientresponse(index) = imgfiltered{ii}(index);
    fmap(index) = ii;
end

% Smooth focal plane image
fmap = imfilter(fmap, fspecial('gaussian', [blendsize blendsize], blendstd));
fmap(fmap < 1) = 1;

if ~colorimg
    edofimg = img{1};
else
    edofimg = imgcopy{1};
end

% Extract in-focus pixels
for ii = 1:length(img)
    index = fmap == ii;
    if ~colorimg
        edofimg(index) = img{ii}(index);
    else
        index = repmat(index,[1 1 3]);
        edofimg(index) = imgcopy{ii}(index);
    end
end

% Blend different focal planes
for ii = 1:length(img)-1
    index = fmap > ii & fmap < ii+1;
    if ~colorimg
        edofimg(index) = (fmap(index) - ii).*single(img{ii+1}(index)) + ...
            (ii+1-fmap(index)).*single(img{ii}(index));
    else
        index = repmat(index,[1 1 3]);
        fmap_c = repmat(fmap, [1 1 3]);
        edofimg(index) = (fmap_c(index) - ii).*single(imgcopy{ii+1}(index)) + ...
            (ii + 1 - fmap_c(index)).*single(imgcopy{ii}(index));
    end
end

if nargout >= 2
    varargout{1} = fmap;
end

if nargout == 3
    varargout{2} = gradientresponse;
end

end
