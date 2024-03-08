clear;
clc;
close all
%final
src_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/1_cws_tiling';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/pigment_v2/ss1_tissueBed_entireDCP20close27remove1000_bedOpen5remove90000';
%ref_path = 'D:\tx421_fine_tune\ss1_tissue_mask_DCP20max2_close5_pigment';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*.svs'));
for i =1:length(files)
    file_name = files(i).name;
    disp(file_name)
    %     file_name_new = extractBefore(file_name, '.jpg');
    if ~isfile(fullfile(dst_path, [file_name, '_tissue.png']))
        %if isfile(fullfile(src_path, file_name, 'Ss1.jpg'))
        mask_raw = imread(fullfile(src_path, file_name,  'Ss1.jpg'));
        
        
        max_c = max(mask_raw, [],3);
        % mask_g = mask_raw(:,:,2);
        min_c = min(mask_raw, [], 3);
        mask_minus = max_c - min_c;
        
        mask_post = mask_minus;
        mask_post(mask_minus>20)=255; %reduce 20 to 10 will include more noises from background
        mask_post(mask_minus<=20)=0;
        %  mask_post(min_c<200 & min_c>=100)=255;
        
        
        
        %entire tissue
        se = strel('disk',27);
        mask_post1 = imclose(mask_post, se); %close opera is to connect small gaps
        mask_post1 = imfill(mask_post1, 'holes'); %only, ss1_mask_fill_3
        mask_tissue = bwareaopen(mask_post1, 1000);
        % mask_final = 255*uint8(mask_tissue);
        %  figure;
        %  imshow(mask_tissue)
        
        %tumor bed
        mask_post2 = mask_minus;
        mask_post2(mask_minus>30)=255;
        mask_post2(mask_minus<=30)=0;
        
        se1 = strel('disk',5);  %to set
        mask_post2 = imopen(mask_post2, se1);
        mask_post2 = imfill(mask_post2, 'holes');
        % figure;
        % imshow(mask_post2)
        cc = bwconncomp(mask_post2);
        stats = regionprops(cc,'Area');
        idx = find([stats.Area] >= 90000);
        BW2 = ismember(labelmatrix(cc),idx);
        % BW2 = imfill(BW2, 'holes');
        
        mask_tissue1 = 200*uint8(mask_tissue);
        mask_tissue2 = mask_tissue1;
        mask_tissue2(BW2)= 0;
        mask_tissue1(BW2) = 255;
        mask_final = cat(3,mask_tissue1, mask_tissue2, mask_tissue2);
        
        % figure;
        % imshow(mask_final)
        
        
        imwrite(mask_final, fullfile(dst_path, [file_name, '_tissue.png']))
    end
end


