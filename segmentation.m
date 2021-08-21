function segmentation(originalImage, contentType, axes)

original = originalImage;
captionFontSize = 14;
originalImage = rgb2gray(originalImage);
isForest = 0;
isBuildingLandscape = 0;
buildMaskLandscape = 0;
blobMeasurements_Urban =0;
%%landspace mask
if contentType == 0
    
    % Threshold the image to get a binary image
    thresholdValue = 120;
    binaryImage = originalImage > thresholdValue; % Bright objects will be chosen if you use >.
    %get rid of any background pixels or "holes" inside the blobs.
    %%binaryImage = imfill(binaryImage, 'holes');
    
    %% find Urbans in landspace
    % into 3 separate 2D arrays, one for each color component.
    redBand = original(:, :, 1);
    greenBand = original(:, :, 2);
    blueBand = original(:, :, 3);
    
    %% Creat masks for different colors
    % Urab long distance color
    redThresholdLow = 150;
    redThresholdHigh = 180;
    greenThresholdLow = 140;
    greenThresholdHigh = 255;
    blueThresholdLow = 0;
    blueThresholdHigh = 255;
    % Now apply each color band's particular thresholds to the color band
    redMask = (redBand >= redThresholdLow) & (redBand <= redThresholdHigh);
    greenMask = (greenBand >= greenThresholdLow) & (greenBand <= greenThresholdHigh);
    blueMask = (blueBand >= blueThresholdLow) & (blueBand <= blueThresholdHigh);
    buildMaskLandscape = uint8(redMask & greenMask & blueMask);
    buildingBlobs = regionprops(buildMaskLandscape, originalImage, 'all');
    [maxArea_b,~] = max([buildingBlobs.Area]);
    if maxArea_b > 70000
        isBuildingLandscape = 1;
    end
else
    %% Urban mask
    % into 3 separate 2D arrays, one for each color component.
    redBand = original(:, :, 1);
    greenBand = original(:, :, 2);
    blueBand = original(:, :, 3);
    
    
    % houses color
    % Haus orange
    redThresholdLow_h = 155;
    redThresholdHigh_h = 197;
    greenThresholdLow_h = 85;
    greenThresholdHigh_h = 153;
    blueThresholdLow_h = 80;
    blueThresholdHigh_h = 118;
    % Now apply each color band's particular thresholds to the color band
    redMask_h = (redBand >= redThresholdLow_h) & (redBand <= redThresholdHigh_h);
    greenMask_h = (greenBand >= greenThresholdLow_h) & (greenBand <= greenThresholdHigh_h);
    blueMask_h = (blueBand >= blueThresholdLow_h) & (blueBand <= blueThresholdHigh_h);
    % Then we will have the mask of only the red parts of the image.
    % Now apply each color band's particular thresholds to the color band
    redMask_h_2 = (redBand >= 55) & (redBand <= 120);
    greenMask_h_2 = (greenBand >= 50) & (greenBand <= 90);
    blueMask_h_2 = (blueBand >= 40) & (blueBand <= 90);
    
    %% Green mask
    redMask_g = (redBand >= 24) & (redBand <= 70);
    greenMask_g = (greenBand >= 40) & (greenBand <= 86);
    blueMask_g = (blueBand >= 26) & (blueBand <= 68);
    
    %% Build the mask
    binaryImage_h = uint8(redMask_h & greenMask_h & blueMask_h);
    binaryImage_h_2 = uint8(redMask_h_2 & greenMask_h_2 & blueMask_h_2);
    binaryImage_g = uint8(redMask_g & greenMask_g & blueMask_g);
    %% find max area in green mask
    greenBlobs = regionprops(binaryImage_g, originalImage, 'all');
    [maxArea_g,~] = max([greenBlobs.Area]);
    if maxArea_g > 500000
        isForest = 1;
    end
    
    
    if isForest == 1
        binaryImage = not(binaryImage_g);
    else
        binaryImage = binaryImage_h + binaryImage_h_2;
    end
end


% Identify individual blobs by seeing which pixels are connected to each other.
labeledImage = bwlabel(binaryImage, 8);
if contentType == 0
    labeledImage = imgaussfilt(labeledImage,2);
    % try to fill holes
    labeledImage = imfill(labeledImage,"holes");
else
    labeledImage = imgaussfilt(labeledImage,1);
end
% binarize the now blurried image with filled holes
labeledImage = imbinarize(labeledImage, 0.1);


%% Only when there is Urban in the landspace maps
if isBuildingLandscape == 1
    labeledImage_Urban = bwlabel(buildMaskLandscape, 8);
    labeledImage_Urban = imgaussfilt(labeledImage_Urban,1);
    % binarize the now blurried image with filled holes
    labeledImage_Urban = imbinarize(labeledImage_Urban, 0.1);
    % Get all the blob properties.
    blobMeasurements_Urban = regionprops(labeledImage_Urban, originalImage, 'all');
end


% Get all the blob properties.
blobMeasurements = regionprops(labeledImage, originalImage, 'all');
zeroColorArea = regionprops(not(labeledImage),originalImage, 'all' );
numberOfBlobs = size(blobMeasurements, 1);
%numberofZeroAreas= size(zeroColorArea,1)


% Plot the borders .

imagesc(axes,original);

hold(axes,'on');
boundaries = bwboundaries(labeledImage);
numberOfBoundaries = size(boundaries, 1);
for k = 1 : numberOfBoundaries
    thisBoundary = boundaries{k};
    plot(axes,thisBoundary(:,2), thisBoundary(:,1), 'r', 'LineWidth', 2);
    
end

%% plot Urban area

if isBuildingLandscape == 1
    boundaries = bwboundaries(labeledImage_Urban);
    numberOfBoundaries = size(boundaries, 1);
    for k = 1 : numberOfBoundaries
        thisBoundary = boundaries{k};
        plot(axes, thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 1);
        
    end
end
if contentType == 0
    %plot Urban in landspcae maps
    if isBuildingLandscape == 1
        [maxArea_U,max_index_U] = max([blobMeasurements_Urban.Area]);
        max_centroid_U = cat(1,blobMeasurements_Urban(max_index_U).Centroid);
        % Put the "blob number" labels on the "boundaries" grayscale image.
        
        text(axes, max_centroid_U(:,1), max_centroid_U(:,2), 'Urban', 'FontSize', 16, 'FontWeight', 'Bold', 'Color','g');
    end
    
    %% Plot the Sea in the max zeroColor area
    [maxArea,max_index] = max([zeroColorArea.Area]);
    max_centroid_s = cat(1,zeroColorArea(max_index).Centroid);
    % Put the "blob number" labels on the "boundaries" grayscale image.
    
    text(axes, max_centroid_s(:,1), max_centroid_s(:,2), 'Sea', 'FontSize', 16, 'FontWeight', 'Bold', 'Color','k');
    
    %% Plot The Empty earth
    [maxArea,max_index] = max([blobMeasurements.Area]);
    max_centroid_e = cat(1,blobMeasurements(max_index).Centroid);
    % Put the "blob number" labels on the "boundaries" grayscale image.
    text(axes, max_centroid_e(:,1), max_centroid_e(:,2), 'Land', 'FontSize', 16, 'FontWeight', 'Bold', 'Color','k');
    
else
    
    %% Plot image structure
    %Mask
    [maxArea,max_index] = max([blobMeasurements.Area]);
    max_centroid_u = cat(1,blobMeasurements(max_index).Centroid);
    % ZeroColor mask
    [maxArea_N,max_index_N] = max([zeroColorArea.Area]);
    max_centroid_u_N = cat(1,zeroColorArea(max_index_N).Centroid);
    
    if isForest == 0
        if maxArea_N > 950000
            text(axes, max_centroid_u_N(:,1), max_centroid_u_N(:,2), 'Empty area', 'FontSize', 16, 'FontWeight', 'Bold', 'Color','k');
            
        end
        %Put the "blob number" labels on the "boundaries" grayscale image.
        text(axes, max_centroid_u(:,1), max_centroid_u(:,2), 'Buildings', 'FontSize', 16, 'FontWeight', 'Bold', 'Color','k');
    else
        if maxArea_N > 950000
            text(axes, max_centroid_u_N(:,1), max_centroid_u_N(:,2), 'Forest', 'FontSize', 16, 'FontWeight', 'Bold', 'Color','k');
        end
        text(axes, max_centroid_u(:,1), max_centroid_u(:,2), 'Empty Forest', 'FontSize', 16, 'FontWeight', 'Bold', 'Color','k');
    end
    
    hold(axes, 'off');
    
end