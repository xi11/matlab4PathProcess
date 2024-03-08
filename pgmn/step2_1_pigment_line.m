clear;
clc;
close all

%line mask - remove objects less than 1000 in ss1 and then remove objects
%with an eccentricity >=0.98 or filled in ratio >=0.98
src_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/1_cws_tiling';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/pigment_v2/ss1_line_removal1000_eccen98_ratio98';
% ref_path = 'D:\tx421_fine_tune\ss1_line_removal4000_eccen95';
if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end
    
files = dir(fullfile(src_path, '*.svs'));
for i =1:length(files)
    file_name = files(i).name;
     if ~isfile(fullfile(dst_path,[file_name, '.png']))
mask_raw = imread(fullfile(src_path, file_name,  'Ss1.jpg'));

        max_c = max(mask_raw, [],3);
        min_c = min(mask_raw, [], 3);
        mask_minus = max_c - min_c;
        mask_minus(mask_minus>50)=128;
        mask_minus(mask_minus<=50)=255;
        mask_minus(mask_minus==128)=0;
        mask_minus(min_c>=100) = 0;
        mask_post = mask_minus;
        
        mask_post1 = bwareaopen(mask_post, 1000);
%         se = strel('disk',1);
%         mask_post1 = imopen(mask_post1, se);
% figure;
%        imshow(mask_post1)
        cc = bwconncomp(mask_post1); 
stats = regionprops(cc,'Area','Eccentricity', 'EulerNumber', 'FilledArea'); 
ratio = [stats.Area]./[stats.FilledArea];
for k=1:length(stats)
    stats(k).EulerNumber = ratio(k);
end
idx = find([stats.Eccentricity] >= 0.98| [stats.EulerNumber] >= 0.98); 
BW2 = ismember(labelmatrix(cc),idx); 
  
     imwrite(255*uint8(BW2), fullfile(dst_path,[file_name, '.png']))
    end
end