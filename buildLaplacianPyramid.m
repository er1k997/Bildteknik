function laplace_pyramid = buildLaplacianPyramid(image, num_levels)
    % buildLaplacianPyramid - Builds a Laplacian pyramid for a given image
    % img - The input image
    % num_levels - Number of pyramid levels
    % laplacianPyramid - Cell array of Laplacian pyramid levels
    

    %------------------- Skapa Gaussisk Pyramid först --------------------%

    gaussian_pyramid = cell(num_levels, 1);
    % Create the first level of the Gaussian pyramid (the original image)
    gaussian_pyramid{1} = image;
    
    for i = 2:num_levels
        % Minska storleken och sudda bilden (gaussisk filtrering)
        gaussian_pyramid{i} = imgaussfilt(gaussian_pyramid{i-1}, 2); % Gaussisk blur
        gaussian_pyramid{i} = imresize(gaussian_pyramid{i}, 0.5);    % Downsampling
    end


    %---------------------- Skapa Laplace Pyramid ------------------------% 
  
    laplace_pyramid = cell(num_levels, 1);
    
    % Build the Laplacian pyramid
    for i = 1:num_levels-1
        % Ta skillnaden mellan Gaussisk nivå och nästa nivå (uppskalad)
        [rows, cols, ~] = size(gaussian_pyramid{i});  % Hämta storleken på föregående nivå
        next_gaussian = imresize(gaussian_pyramid{i+1}, [rows, cols]);  % Ändra storlek till föregående nivåns storlek
        laplace_pyramid{i} = gaussian_pyramid{i} - next_gaussian;
    end
    
    % The final level of the Laplacian pyramid is just the lowest resolution Gaussian image
    laplace_pyramid{num_levels} = gaussian_pyramid{num_levels}; % Sista nivån
end
