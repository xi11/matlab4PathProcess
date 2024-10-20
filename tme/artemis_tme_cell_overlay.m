clear;
clc;
close all

tme_cell_dir = '/Volumes/yuan_lab/TIER2/artemis_lei/discovery/til/4_cell_class_segformerBRCAartemis/annotated_images_tmeseg/274_HE_A1_Primary.svs/Da305.png';
tme_dir = '/Volumes/yuan_lab/TIER2/artemis_lei/discovery/mit-b3-finetunedBRCA-Artemis-e60-lr00001-s512-20x512/mask_cws512_orng/274_HE_A1_Primary.svs/Da305.png';
dst_path = '/Users/xiaoxipan/Library/CloudStorage/OneDrive-InsideMDAnderson/yuanlab/Manuscripts/Artemis/fig/v4';

green = [0, 255, 0];
yellow = [255, 255, 0];
white = [255, 255, 255];
target_color = [255, 204, 0];

tme = imread(tme_dir);
tme_cell = imread(tme_cell_dir);

green_mask = tme_cell(:,:,1) == green(1) & tme_cell(:,:,2) == green(2) & tme_cell(:,:,3) == green(3);
yellow_mask = tme_cell(:,:,1) == yellow(1) & tme_cell(:,:,2) == yellow(2) & tme_cell(:,:,3) == yellow(3);
white_mask = tme_cell(:,:,1) == white(1) & tme_cell(:,:,2) == white(2) & tme_cell(:,:,3) == white(3);

total_mask = green_mask | yellow_mask | white_mask;

% Replace the colors with the target color
tme_cell(repmat(total_mask, [1, 1, 3])) = repmat(target_color, [sum(total_mask(:)), 1]);


[m, n, ~] = size(tme);
tme_binary = zeros(m ,n);
tme_binary(tme(:,:,1)==255 & tme(:,:,2)==204 &tme(:,:,3)==0) = 1;
tme_cell_filter = uint8(tme_binary) .* tme_cell;

imwrite(tme_cell_filter, fullfile(dst_path, '274_Da305_tme_cell.png'))