%%% to convert RGB mask to digital label
clear;
clc;
close all

src_path = '/Volumes/yuan_lab/TIER2/mpr_frank/validation/tmeseg_annotation/tiles_cleaned/maskPng_vis';
dst_path = '/Volumes/yuan_lab/TIER2/mpr_frank/validation/tmeseg_annotation/tiles_cleaned/maskPng';

if ~exist(dst_path, "dir")
    mkdir(dst_path)
end

rgb_values = [
    0   0   0;      % [0, 0, 0] maps to label 0
    0   0 255;      % [0, 0, 255] maps to label 1
  255   0 255;      % [255, 0, 255] maps to label 2
  128   0   0;      % [128, 0, 0] maps to label 3
  255 255   0;      % [255, 255, 0] maps to label 4
  255   0   0;      % [255, 0, 0] maps to label 5
];

files = dir(fullfile(src_path, "*.png"));
for i = 1: length(files)
    file_name = files(i).name;
    img = imread(fullfile(src_path, file_name));
    [colormap0, map] = imread(fullfile(src_path, file_name), 'png');
    rgb_img = ind2rgb(img, map)*255;
    [indexed_mask, colormap] = rgb2ind(rgb_img, size(rgb_values, 1));
    [~, labels] = ismember(colormap, rgb_values, 'rows');
    digital_labels = labels(indexed_mask + 1); % Add 1 because indexing starts from 0
    %imshow(digital_labels, []); % [] auto-scales the colormap
    imwrite(uint8(digital_labels), fullfile(dst_path, file_name));
    
end







