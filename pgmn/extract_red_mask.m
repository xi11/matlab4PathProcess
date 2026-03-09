close all
clear
clc

% Set input (where your segmented masks are) and output folders
inputFolder = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/tme/mit-b3-finetuned-TCGAbcssWsss10xLuadMacroMuscle-40x896-20x512-10x256re/mask_ss1512';
outputFolder = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/tme/mit-b3-finetuned-TCGAbcssWsss10xLuadMacroMuscle-40x896-20x512-10x256re/mask_ss1512_red';

% Create the output folder if it doesn't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Get a list of all PNG images (change '*.png' if your masks are in a different format)
fileList = dir(fullfile(inputFolder, '*.png'));

for i = 1:length(fileList)
    % Read the original segmentation image
    inFile = fullfile(fileList(i).folder, fileList(i).name);
    segImage = imread(inFile);
    
    % Check that the image is RGB (3 channels). If it's indexed or grayscale, handle accordingly.
    if size(segImage, 3) < 3
        warning('Image %s is not an RGB image. Skipping...', fileList(i).name);
        continue;
    end
    
    % Extract purely red pixels: R=255, G=0, B=0
    redMask = (segImage(:,:,1) == 255) & (segImage(:,:,2) == 0) & (segImage(:,:,3) == 0);
    
    % Create an all-black RGB image the same size as segImage
    redOnlyImage = zeros(size(segImage), 'uint8');
    
    % Keep only the red pixels from the original, everything else black
    % Option 1: Force the extracted region to [255, 0, 0]
    %   redOnlyImage(:,:,1) = uint8(redMask) * 255;
    
    % Option 2: Copy the original red color
    %   for just pure red, these approaches are identical. But if you'd like
    %   to preserve some shading, you'd do something else.
    %
    % Here, we'll simply color them (255,0,0):
    redOnlyImage(:,:,1) = uint8(redMask) * 255;
    
    % Build output filename
    [~, baseName, ~] = fileparts(fileList(i).name);
    outFile = fullfile(outputFolder, sprintf('%s_red.png', baseName));
    
    % Save the red-only image
    imwrite(redOnlyImage, outFile);
    
    fprintf('Saved red-only mask for %s -> %s\n', fileList(i).name, outFile);
end
