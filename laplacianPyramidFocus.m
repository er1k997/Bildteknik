function totalFocusImage = laplacianPyramidFocus(imgSeq)
    % imgSeq är en cell-array med sekvensen av bilder med olika fokus
    num_images = numel(imgSeq);
    levels = 4;  % Antal nivåer i Laplacian Pyramid

    % Förbered pyramider för alla bilder
    laplacianPyramids = cell(num_images, 1);
    gaussianPyramids = cell(num_images, 1);
    
    % Skapa Gaussian och Laplacian pyramider för varje bild
    for i = 1:num_images
        [gaussianPyramids{i}, laplacianPyramids{i}] = createPyramids(imgSeq{i}, levels);
    end
    
    % Identifiera den bästa fokusnivån för varje pixel baserat på Laplacian energi
    [height, width, ~] = size(imgSeq{1});
    totalFocusPyramid = cell(levels, 1);
    
    for level = 1:levels
        focusMask = zeros(height, width);
        totalFocusPyramid{level} = zeros(height, width, 3); % RGB-bild för detta nivå
        
        for i = 1:num_images
            % Beräkna energin av Laplacian för varje pixel
            laplaceEnergy = sum(laplacianPyramids{i}{level}.^2, 3);  % Energi är summan av kvadraterna
            focusMask = max(focusMask, laplaceEnergy);
        end
        
        % Skapa total focus pyramid genom att ta det bäst fokuserade området från varje bild
        for i = 1:num_images
            laplaceEnergy = sum(laplacianPyramids{i}{level}.^2, 3);
            mask = (laplaceEnergy == focusMask);  % Mask för att identifiera den skarpaste bilden
            
            % Konvertera mask och laplacianPyramid till double för att möjliggöra multiplikation
            totalFocusPyramid{level} = totalFocusPyramid{level} + double(laplacianPyramids{i}{level}) .* double(mask);
        end
    end
    
    % Återskapa den fullständigt fokuserade bilden genom att summera pyramiden
    totalFocusImage = reconstructFromPyramid(totalFocusPyramid);
end

function [gaussianPyramid, laplacianPyramid] = createPyramids(img, levels)
    % Skapa Gaussian och Laplacian Pyramid för en bild
    gaussianPyramid = cell(levels, 1);
    laplacianPyramid = cell(levels, 1);
    
    % Första nivån av Gaussian Pyramid är originalbilden, konverterad till double
    gaussianPyramid{1} = im2double(img);  % Konvertera till double
    
    % Bygg Gaussian Pyramid
    for i = 2:levels
        gaussianPyramid{i} = impyramid(gaussianPyramid{i-1}, 'reduce');
    end
    
    % Bygg Laplacian Pyramid
    for i = 1:levels-1
        expanded = impyramid(gaussianPyramid{i+1}, 'expand');
        
        % Få dimensionerna för nuvarande nivå
        [rows, cols, ~] = size(gaussianPyramid{i});
        [expandedRows, expandedCols, ~] = size(expanded);
        
        % Om den expanderade bilden är större än nuvarande nivå, klipp till rätt storlek
        if expandedRows > rows
            expanded = expanded(1:rows, :, :);
        end
        if expandedCols > cols
            expanded = expanded(:, 1:cols, :);
        end
        
        % Om den expanderade bilden är mindre än nuvarande nivå, fyll med nollor
        if expandedRows < rows
            expanded(rows, :, :) = 0;  % Lägg till extra rader
        end
        if expandedCols < cols
            expanded(:, cols, :) = 0;  % Lägg till extra kolumner
        end
        
        % Beräkna Laplacian som skillnaden mellan Gaussian-nivån och den expanderade bilden
        laplacianPyramid{i} = gaussianPyramid{i} - expanded;  % Båda är nu av typen double
    end
    
    % Den sista nivån i Laplacian Pyramid är samma som den sista Gaussian-nivån
    laplacianPyramid{levels} = gaussianPyramid{levels};
end

function img = reconstructFromPyramid(laplacianPyramid)
    % Återkonstruera bilden från Laplacian Pyramid
    levels = numel(laplacianPyramid);
    img = laplacianPyramid{levels};  % Börja med den sista nivån
    
    for i = levels-1:-1:1
        expanded = impyramid(img, 'expand');
        % Se till att storleken matchar den aktuella nivån
        if size(expanded, 1) ~= size(laplacianPyramid{i}, 1)
            expanded = expanded(1:size(laplacianPyramid{i}, 1), :, :);
        end
        if size(expanded, 2) ~= size(laplacianPyramid{i}, 2)
            expanded = expanded(:, 1:size(laplacianPyramid{i}, 2), :);
        end
        img = expanded + laplacianPyramid{i};
    end
end
