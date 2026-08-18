
clear;
clc;
close all
%tumor-region 11-13-15pix dilation

tme_path = '/Volumes/yuan_lab/TIER2/artemis_lei/discovery/mit-b3-finetunedBRCA-Artemis-e60-lr00001-s512-20x512/mask_ss1512_orng';
dilation_radius = 11;  % hyperparameter in pixels

dst_path = sprintf('%s_tumor%ddilate', tme_path(1:end-5), dilation_radius);

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(tme_path, '*.png'));

for i = 1:length(files)

    file_name = files(i).name(1:end-12);  % adjust if needed
    disp(file_name)

    % Read TME segmentation mask
    mask_tme = imread(fullfile(tme_path, files(i).name));

    % Extract tumor region: RGB = (128, 0, 0)
    mask_tumor = ...
        mask_tme(:,:,1) == 128 & ...
        mask_tme(:,:,2) == 0   & ...
        mask_tme(:,:,3) == 0;

    % Fill holes in tumor region
    mask_tumor = imfill(mask_tumor, 'holes');

    % Dilate tumor
    se = strel('disk', dilation_radius);
    mask_dilated = imdilate(mask_tumor, se);
    mask_dilated = imfill(mask_dilated, 'holes');

    % Output 1: tumor + dilation region
    output1 = uint8(mask_dilated) .* mask_tme;

    % Output 2: dilation region only
    %output2 = uint8(mask_dilated & ~mask_tumor) .* mask_tme;

    % Save outputs
    imwrite(output1, fullfile(dst_path, ...
        sprintf('%s_tumor_dilate%d.png', file_name, dilation_radius)));

    %imwrite(output2, fullfile(dst_path2, ...
    %    sprintf('%s_dilate%d_only.png', file_name, dilation_radius)));

end


