clc;
clear;
close all

% Step 1: Read image and mask
img = imread('/Volumes/yuan_lab/TIER2/artemis_lei/discovery/til/1_cws_tiling/112_HE_A1_Primary.svs/Da174.jpg');        % original image
mask1 = imread('/Volumes/yuan_lab/TIER2/artemis_lei/discovery/til/4_cell_class/annotated_images/112_HE_A1_Primary.svs/Da174.png');        % corresponding mask
mask2 = imread('/Volumes/yuan_lab/TIER2/artemis_lei/discovery/til/4_cell_class_segformerBRCAartemis/annotated_images/112_HE_A1_Primary.svs/Da174.png');        % corresponding mask

dst_path = '/Users/xiaoxipan/Library/CloudStorage/OneDrive-InsideMDAnderson/yuanlab/Manuscripts/Artemis/fig/v7/fig1_cellclass';

% Step 2: Manually select ROI from the image
figure;
imshow(img);
title('Select region to crop');
rect = getrect;  % returns [x, y, width, height]

% Step 3: Round the rectangle values
x1 = round(rect(1));
y1 = round(rect(2));
w  = round(rect(3));
h  = round(rect(4));

% Step 4: Crop both image and mask
img_crop = imcrop(img, [x1 y1 w h]);
mask1_crop = imcrop(mask1, [x1 y1 w h]);
mask2_crop = imcrop(mask2, [x1 y1 w h]);


% Step 6: Save the cropped files
imwrite(img_crop, fullfile(dst_path, 'cropped_he_Da174.png'));
imwrite(mask1_crop, fullfile(dst_path,'cropped_raw_Da174.png'));
imwrite(mask2_crop, fullfile(dst_path,'cropped_refine_Da174.png'));
