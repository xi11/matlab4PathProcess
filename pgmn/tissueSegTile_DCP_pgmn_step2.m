clear;
clc;
close all

src_path = '/Volumes/yuan_lab/TIER2/anthracosis/prospect/tissue_seg_airspace_DCP20_remove5000_fill1600/mask_ss1_x8';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/prospect/tissue_seg_airspace_DCP20_remove5000_fill1600/mask_ss1_x8_fill';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*.png'));
for i =1:length(files)
    file_name = files(i).name;
    if ~isfile(fullfile(dst_path, file_name))
        mask = imread(fullfile(src_path, file_name));
        mask_post = mask(:,:,1);
        mask_post1 = imfill(mask_post, 'holes');
        imwrite(mask_post1, fullfile(dst_path, file_name))
    end

end


