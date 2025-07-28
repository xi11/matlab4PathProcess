clear;
clc;
close all

%remove line in the tile processing, should be the final version

src_path = '/Volumes/yuan_lab/TIER2/anthracosis/pgmnModel/stain_edge/HE_tile';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/pgmnModel/stain_edge/mask_DCP30minC70_dilate1_remove64_pen100000_line98_ratio98';
% src_path = 'R:\tracerx\tracerx421\HE_diagnostic_LUSC\cws';
% dst_path = 'D:\tx421_fine_tune\LUSC_pigment_DCP30minC50_dilate1_remove64_pen100000_line98_ratio98';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

% mask_target = imread('D:\gp_lattice_2\Darwin_83_Da543.png');
files = dir(fullfile(src_path, '*.svs'));
for i =1:length(files)
    file_name = files(i).name;
    disp(file_name)
    file_path = fullfile(dst_path, file_name);
    if ~exist(file_path, 'dir')
        mkdir(file_path)
    end
    
    Da_files = dir(fullfile(src_path, file_name, '*.jpg'));
    for j = 1:length(Da_files)
        Da_name = Da_files(j).name;
        Da_name_new = extractBefore(Da_name, '.jpg');
        %if ~isfile(fullfile(file_path,[Da_name_new, '.png']))
            mask_raw = imread(fullfile(src_path, file_name, Da_name));
            %mask_raw = uint8(255*NormReinhard(mask_raw_source, mask_target));
            max_c = max(mask_raw, [],3);
            min_c = min(mask_raw, [], 3);
            mask_minus = max_c - min_c;
            mask_minus(mask_minus>30)=128;
            mask_minus(mask_minus<=30)=255;
            mask_minus(mask_minus==128)=0;
            mask_minus(min_c>70) = 0;
            mask_post = mask_minus;
            
            se = strel('disk',1);
            mask_post1 = imdilate(mask_post, se);
            
            %remove small
            mask_post1 = bwareaopen(mask_post1, 64); %for dark staining images as lyms are darker, then the entire lyms would be detected, set as 10um
            %remove big - pen marker
            
            cc = bwconncomp(mask_post1);
            stats = regionprops(cc,'Area','Eccentricity', 'EulerNumber', 'FilledArea');
            ratio = [stats.Area]./[stats.FilledArea];
            for k=1:length(stats)
                stats(k).EulerNumber = ratio(k);
            end
            idx = find([stats.Eccentricity] >= 0.98| ([stats.Area]>100000 &[stats.EulerNumber] >= 0.98));
            BW2 = ismember(labelmatrix(cc),idx);
            mask_post1 =  mask_post1 - BW2;
            
            
            imwrite(255*uint8(mask_post1), fullfile(file_path,[Da_name_new, '.png']))
        %end
    end
end


