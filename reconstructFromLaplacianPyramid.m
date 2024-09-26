function img = reconstructFromLaplacianPyramid(pyramids, combined_pyramid, num_levels)

   %img = combined_pyramid{num_levels};
    
    % Stegvis uppsampla och lägg till pyramiderna för att rekonstruera
    for level = num_levels-1:-1:1
        % Hämta storleken på den nuvarande Laplacian-nivån
        %[rows, cols, ~] = size(combined_pyramid{level});
        
        % Upsampla nuvarande bild till samma storlek som nästa pyramidnivå
        upsampled_img = imresize(combined_pyramid(level-1), size(combined_pyramid(level))); 
        
        % Lägg till den nuvarande Laplacian-nivån
        img = combined_pyramid{level} + upsampled_img;
    end
 


end

