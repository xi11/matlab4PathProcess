clear;
clc;
close all
%final
src_path = '/Volumes/yuan_lab/TIER2/anthracosis/prospect/ss1_Timages';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/prospect/ss1_Timages_Tbed';


if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*.jpg'));
for i =1:length(files)
    file_name = files(i).name;
    disp(file_name)
    ID = extractBefore(file_name, '_Ss1.jpg');
    %     file_name_new = extractBefore(file_name, '.jpg');
    if ~isfile(fullfile(dst_path, [ID, '_Tbed.png']))
        %if isfile(fullfile(src_path, file_name, 'Ss1.jpg'))
        mask_raw = imread(fullfile(src_path, file_name));
        
        max_c = max(mask_raw, [],3);
        % mask_g = mask_raw(:,:,2);
        min_c = min(mask_raw, [], 3);
        mask_minus = max_c - min_c;

        
        %tumor bed
        mask_post2 = mask_minus;
        mask_post2(mask_minus>20)=255;
        mask_post2(mask_minus<=20)=0;
        
        se1 = strel('disk',5);  %to set
        mask_post2 = imopen(mask_post2, se1);
        mask_post2 = imfill(mask_post2, 'holes');
        cc = bwconncomp(mask_post2);
        stats = regionprops(cc,'Area');
        idx = find([stats.Area] >= 90000);
        BW2 = ismember(labelmatrix(cc),idx);
        
        mask_final = 255*uint8(BW2);
       
        imwrite(mask_final, fullfile(dst_path,  [ID, '_Tbed.png']))
    end
end