clear;
clc;
close all

src_path = '/Volumes/yuan_lab/TIER2/barrett/1_cws_tiling';
dst_path = '/Volumes/yuan_lab/TIER2/barrett/ss1_tissue';
dst_path1 = '/Volumes/yuan_lab/TIER2/barrett/ss1_tissue_fill'; % using imfill

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

if ~exist(dst_path1, 'dir')
    mkdir(dst_path1)
end

files = dir(fullfile(src_path, '*.ndpi'));
for i =1:length(files)
    file_name = files(i).name;

    mask_raw = imread(fullfile(src_path, file_name, 'Ss1.jpg'));

    max_c = max(mask_raw, [],3);
    min_c = min(mask_raw, [], 3);

    mask = max_c - min_c;

    mask(mask>40)=255;
    mask(mask<=40)=0;

    imwrite(mask, fullfile(dst_path, [file_name, '.png']))

    %to refine the tissue mask
    mask_post = imfill(mask, 'holes'); %only, ss1_mask_fill_3
    [m, n] = size(mask_post);
    mask_post1=remove_small(mask_post, m, n, 50);      %50 can be adjusted
    mask_post1 = bwmorph(mask_post1, 'thicken', 20);    %20 can be adjusted
    mask_post1 = bwmorph(mask_post1, 'majority', 50);     % 50 can be adjusted
    imwrite(mask_post1, fullfile(dst_path1, [file_name, '.png']))
end

% remove small components that less than a number of pixels, num is the
% threshold
function I = remove_small(mask_digit, m, n, num)
bw = zeros(m, n);
bw(mask_digit>0) = 1;
mask_post = bwareaopen(bw, num);
I=mask_post;
end