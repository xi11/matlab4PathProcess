
clear;
clc;
close all
%final
src_path = '/Volumes/yuan_lab/TIER2/anthracosis/TbedModel/train512_prospectT_noEdge/image_rereremask';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/TbedModel/train512_prospectT_noEdge/remask_post_DCP10_open5_remove10000';


if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*.png'));
for i =1:length(files)
    file_name = files(i).name;
    disp(file_name)
    file_name_new = extractBefore(file_name, '.png');
    if ~isfile(fullfile(dst_path, [file_name_new, '_tbed.png']))
        mask_raw = imread(fullfile(src_path, file_name));

        max_c = max(mask_raw, [],3);
        min_c = min(mask_raw, [], 3);
        mask_minus = max_c - min_c;

        
        
        %tumor bed
        mask_post2 = mask_minus;
        mask_post2(mask_minus>10)=255;
        mask_post2(mask_minus<=10)=0;
        
        se1 = strel('disk',5);  %to set
        mask_post2 = imopen(mask_post2, se1);
        %mask_post2 = imfill(mask_post2, 'holes');
        
        cc = bwconncomp(mask_post2);
        stats = regionprops(cc,'Area');
        idx = find([stats.Area] >= 10000);
        BW2 = ismember(labelmatrix(cc),idx);
        
        mask_final = uint8(BW2)*255;
        imwrite(mask_final, fullfile(dst_path, [file_name_new, '_tbed.png']))
    end
end


