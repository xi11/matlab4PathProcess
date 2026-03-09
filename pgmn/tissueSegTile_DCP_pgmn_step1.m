clear;
clc;
close all

src_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/1_cws_tiling';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/tissue_seg_airspace_DCP15_fill1600/mask_cws';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*.svs'));
for i =152:length(files)
    file_name = files(i).name;
    file_path = fullfile(dst_path, file_name);
    if ~exist(file_path, 'dir')
        mkdir(file_path)
    end

    Da_files = dir(fullfile(src_path, file_name, 'Da*'));
    for j = 1:length(Da_files)
        Da_name = Da_files(j).name;
        Da_ID = extractBefore(Da_name, '.jpg');
        if ~isfile(fullfile(file_path,[Da_ID, '.png']))
            mask_raw = imread(fullfile(src_path, file_name, Da_name));
            max_c = max(mask_raw, [], 3);
            min_c = min(mask_raw, [], 3);
            mask_dark = max_c - min_c;
            mask_dark(mask_dark>15)=255; % a threshold to be adjusted, a higher value indicates more outband tissue (airspace) will be excluded
            mask_dark(mask_dark<=15)=0;
            mask_post = mask_dark;
            %mask_post1 = imfill(mask_post, 'holes');
            
            mask_reverse = 255 - mask_post;
            cc = bwconncomp(mask_reverse);
            stats = regionprops(cc,'Area');
            idx = find([stats.Area] <= 1600);
            BW2 = ismember(labelmatrix(cc),idx);
            mask_post(BW2) = 255;

            %mask_post1 = bwareaopen(mask_post, 5000); %remove small individual componets less than 1000 pixels at ss1 level; not sure if this step is necessary for tile processing, I applied to ss1s, thus '1000' is also for ss1s and you may need to adjust it for tiles
            imwrite(mask_post, fullfile(file_path,[Da_ID, '.png']))
        end
    end
end


