function img = reconstructFromLaplacianPyramid(combined_pyramid, num_levels)
      
    % Start with the finest level of the pyramid (may be grayscale)
    img = combined_pyramid{num_levels};
    
    % Stegvis uppsampla och lägg till pyramiderna för att rekonstruera
    for level = num_levels-1:-1:1
        % Get the size of the current level
        [row, column, ~] = size(combined_pyramid{level});
        % Upsample current image to the size of the current level
        upsampled_img = imresize(img, [row, column]);

        % Add the upsampled image to the current Laplacian level
        img = combined_pyramid{level} + upsampled_img;
      
    end
end
