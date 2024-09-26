function laplacianPyramid = buildLaplacianPyramid(img,num_levels)

    % buildLaplacianPyramid - Builds a Laplacian pyramid for a given image
    % img - The input image
    % num_levels - Number of pyramid levels
    % laplacianPyramid - Cell array of Laplacian pyramid levels

    % Initialize the Gaussian pyramid
    gaussianPyramid = cell(1, num_levels);
    laplacianPyramid = cell(1, num_levels);

    % Create the first level of the Gaussian pyramid (the original image)
    gaussianPyramid{1} = img;

    % Build the Gaussian pyramid by downsampling the image at each level
    for i = 2:num_levels
        % Apply Gaussian blur and downsample
        gaussianPyramid{i} = imresize(imgaussfilt(gaussianPyramid{i-1}, 2), 0.5);
    end

    % Build the Laplacian pyramid
    for i = 1:num_levels-1
      
        % Upsample the coarser level of the Gaussian pyramid
        upsampled_img = imresize(gaussianPyramid{i+1}, size(gaussianPyramid{i}(:,:,1)));

        % Calculate the Laplacian by subtracting the upsampled image from the finer level
        laplacianPyramid{i} = gaussianPyramid{i} - upsampled_img;
       
    end
    
    % The final level of the Laplacian pyramid is just the lowest resolution Gaussian image
    laplacianPyramid{num_levels} = gaussianPyramid{num_levels};


end

