clear;
clc;
close all
%to conver ss1 tissue mask to tile tissue mask

tissue_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/pigment_v2/ss1_tissueBed_entireDCP20close27remove1000_bedOpen5remove90000';
line_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/pigment_v2/ss1_line_removal1000_eccen98_ratio98';

dst_path1 = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/pigment_v2/ss1_tissue_post'; %output path
dst_path2 = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/pigment_v2/tile_tissue_post'; %output path


if ~exist(dst_path1, 'dir')
    mkdir(dst_path1)
end

if ~exist(dst_path2, 'dir')
    mkdir(dst_path2)
end
    
files = dir(fullfile(line_path, '*.png'));
for i =1:length(files)
    file_name = files(i).name;
    file_name_new = extractBefore(file_name, '.png');
    tile_tissue_path = fullfile(dst_path2, file_name_new);
    if ~exist(tile_tissue_path, 'dir')
    mkdir(tile_tissue_path)
    end
    
mask_line = imread(fullfile(line_path, file_name));
mask_tissue = imread(fullfile(tissue_path, [file_name_new, '_tissue.png']));

mask_tissue = im2gray(mask_tissue);
mask_tissue(mask_tissue>0) = 1;
mask_line(mask_line>0) = 1;
mask_tissue_post = max(mask_tissue - mask_line, 0);
imwrite(255*mask_tissue_post, fullfile(dst_path1, [file_name_new, '_tissue.png']))

[w, h] = size(mask_tissue_post);
I = mask_tissue_post;
tile = 0;
for u = 1:125:w
    for v = 1:125:h
        if u+125-1<w && v+125-1<h
        f = I(u:u+125-1, v:v+125-1,:);
        elseif  u+125-1<w && v+125-1>h
            f = I(u:u+125-1, v:h,:);
        elseif u+125-1>w && v+125-1<h
            f = I(u:w, v:v+125-1,:);
        else
            f = I(u:w, v:h,:);
        end
        f = imresize(f, 16, 'nearest');
        imwrite(255*f, fullfile(tile_tissue_path, ['Da',num2str(tile),'.png']))
        tile = tile+1;
    end
end


end


