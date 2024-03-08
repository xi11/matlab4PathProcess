clear;
clc;
close all
%final
src_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/1_cws_tiling';
ref_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/pgmn_TMEsegDiv12sCE/mask_ss1_x8';
ref_path2 = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/tissue_seg_airspace_DCP15_fill1600/mask_ss1_x8';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/prospect_ss1x8_tissueBed_airspace_bedDCP30Open5remove90000';


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
        mask_pgmn = imread(fullfile(ref_path, [file_name, '_Ss1.png']));
        mask_tissue = imread(fullfile(ref_path2, [file_name, '_Ss1.png']));
        mask_tissue = logical(mask_tissue(:,:,1));
        [m, n, ~] = size(mask_pgmn);
        
        max_c = max(mask_raw, [],3);
        % mask_g = mask_raw(:,:,2);
        min_c = min(mask_raw, [], 3);
        mask_minus = max_c - min_c;

        
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
        BW2 = imresize(BW2, [m, n], 'nearest');
        
        mask_tissue1 = 128*uint8(mask_tissue);
        mask_tissue2 = 0*uint8(mask_tissue);
        mask_tissue3 = 128*uint8(mask_tissue);
        mask_tissue1(BW2) = 255;
        mask_tissue3(BW2) = 0;
        mask_final = cat(3,mask_tissue1, mask_tissue2, mask_tissue3);
       
        mask_pgmn = mask_pgmn(:,:,1);
        mask_pgmn = logical(mask_pgmn).*mask_tissue;
        
        mask_final(repmat(logical(mask_pgmn), [1, 1, 3])) = 255;
        
        imwrite(mask_final, fullfile(dst_path, [file_name, '_pgmn_tumorBed.png']))
    end
end


