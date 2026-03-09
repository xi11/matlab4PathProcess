clear;
clc;
close all

src_path = '/Users/xiaoxipan/Documents/project/barretts/train224';
dst_path = '/Users/xiaoxipan/Documents/project/barretts/tissue_patch';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end


patchs = dir(fullfile(src_path, '*.png'));

for i = 32:36
    patch_name = patchs(i).name
    img = imread(fullfile(src_path, patch_name));
    [m, n, ~] = size(img);
    max_c = max(img, [],3);
    min_c = min(img, [], 3);
    mask_minus = max_c - min_c;

    mask_minus(mask_minus>30)=255;
    mask_minus(mask_minus<=30)=0;
    figure;
    imshow(mask_minus)

    %area = sum(mask_minus(:));
    %if area < m*n*0.8
        imwrite(mask_minus, fullfile(dst_path, patch_name))
    %end
end





