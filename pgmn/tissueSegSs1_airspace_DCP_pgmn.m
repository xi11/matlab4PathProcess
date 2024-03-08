clear;
clc;
close all

src_path = '/Volumes/yuan_lab/TIER2/anthracosis/prospect/1_cws_tiling';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/prospect/tissue_seg_airspace_ss1_DCP20_remove5000_fill1600';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*.svs'));
for i =6:10%length(files)
    file_name = files(i).name;
    

    ss1 = fullfile(src_path, file_name, 'Ss1.jpg');
        
        if ~isfile(fullfile(dst_path,[file_name, '_tissue_airspace.png']))
            mask_raw = imread(ss1);
            max_c = max(mask_raw, [], 3);
            min_c = min(mask_raw, [], 3);
            mask_dark = max_c - min_c;
            mask_dark(mask_dark>20)=255; % a threshold to be adjusted, a higher value indicates more outband tissue (airspace) will be excluded
            mask_dark(mask_dark<=20)=0;
            mask_post = mask_dark;
            figure;
            imshow(mask_post)
            %mask_post1 = imfill(mask_post, 'holes');
            
            mask_reverse = 255 - mask_post;
            cc = bwconncomp(mask_reverse);
            stats = regionprops(cc,'Area');
            idx = find([stats.Area] <= 1600);
            BW2 = ismember(labelmatrix(cc),idx);
            mask_post(BW2) = 255;
            figure;
            imshow(mask_post)

            mask_post1 = bwareaopen(mask_post, 5000); %remove small individual componets less than 1000 pixels at ss1 level; not sure if this step is necessary for tile processing, I applied to ss1s, thus '1000' is also for ss1s and you may need to adjust it for tiles
            figure;
            imshow(mask_post1)
            %imwrite(mask_post1, fullfile(dst_path,[file_name, '_tissue_airspace.png']))
        end
    
end


