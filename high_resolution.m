clear;
clc;
close all

src_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/tmeseg/stroma_mask_ss1';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/tmeseg/stroma_mask_ss1_x8';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*.png'));
for i = 17:17%length(files)
    file_name = files(i).name;
    I = imread(fullfile(src_path, file_name));
    f = imresize(I, 2, 'nearest');
    imwrite(f, fullfile(dst_path, file_name));
    
end