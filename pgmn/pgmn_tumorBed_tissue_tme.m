
clear;
clc;
close all
%final
src_path = '/Volumes/yuan_lab/TIER2/anthracosis/prospect_pilot10/1_cws_tiling';
tme_path = '/Volumes/yuan_lab/TIER2/anthracosis/prospect_pilot10/tmesegproDiv12v2/mask_ss1';
ref_path = '/Volumes/yuan_lab/TIER2/anthracosis/prospect_pilot10/pgmn_TMEsegDiv12sCE/mask_ss1_x8';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/prospect_pilot10/ss1x8_pgmn_tissue21_90000_tumorBed5_DCP30_90000';


if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*.svs'));
for i =1:length(files)
    file_name = files(i).name;
    disp(file_name)
    if ~isfile(fullfile(dst_path, [file_name, '_tme_tumorBed.png']))
        mask_raw = imread(fullfile(src_path, file_name,  'Ss1.jpg'));
        %if isfile(fullfile(src_path, file_name, 'Ss1.jpg'))
        mask_tme = imread(fullfile(tme_path, [file_name, '_Ss1.png']));
        mask_pgmn = imread(fullfile(ref_path, [file_name, '_Ss1.png']));
        [m, n, ~] = size(mask_pgmn);
        %[m, n, ~] = size(mask_tme);

        %%%%%%%tumor bed with DCP%%%%%%%%%%%%%
        max_c = max(mask_raw, [],3);
        mask_g = mask_raw(:,:,2);
        min_c = min(mask_raw, [], 3);
        mask_minus = max_c - min_c;
        mask_post2 = mask_minus;
        mask_post2(mask_minus>30)=255;
        mask_post2(mask_minus<=30)=0;
        
        se1 = strel('disk',5);  %to set
        mask_post2 = imopen(mask_post2, se1);
        mask_post2 = imfill(mask_post2, 'holes');
        cc1 = bwconncomp(mask_post2);
        stats1 = regionprops(cc1,'Area');
        idx1 = find([stats1.Area] >= 90000);
        BW1 = ismember(labelmatrix(cc1),idx1);
        BW1 = imresize(BW1, [m, n], 'nearest');



        %%%%%%%%%%%%%%%not works for non-sloid tumors%%%%%%%%%%%%%%%%%%%%%
%         mask_tumor = zeros(m, n);
%         mask_tumor(mask_tme(:,:,1)==128 & mask_tme(:,:,2)==0 &mask_tme(:,:,3)==0) = 255;
%         mask_tumor = imfill(mask_tumor, 'holes');
%         se1 = strel('disk',3);  %to set
%         mask_tumor = imclose(mask_tumor, se1);
%         mask_tumor = imfill(mask_tumor, 'holes');
%         
%         cc1 = bwconncomp(mask_tumor);
%         stats1 = regionprops(cc1,'Area');
%         idx1 = find([stats1.Area] >= 40000);
%         BW1 = ismember(labelmatrix(cc1),idx1);
        %%%%%%%%%%%%%%%not works for non-sloid tumors%%%%%%%%%%%%%%%%%%%%%



        mask_tissue = logical(rgb2gray(mask_tme));
        mask_tissue  = imfill(mask_tissue , 'holes');
        se1 = strel('disk',21);  %to set
        mask_tissue  = imclose(mask_tissue , se1);
        mask_tissue  = imfill(mask_tissue , 'holes');
        mask_tissue = imresize(mask_tissue, [m, n], 'nearest');

        cc2 = bwconncomp(mask_tissue);
        stats2 = regionprops(cc2,'Area');
        idx2 = find([stats2.Area] >= 90000);
        BW2 = ismember(labelmatrix(cc2),idx2);

        mask_tissue1 = 128*uint8(BW2);
        mask_tissue2 = 0*uint8(BW2);
        mask_tissue3 = 128*uint8(BW2);
        mask_tissue1(BW1) = 255;
        mask_tissue3(BW1) = 0;
        mask_final = cat(3,mask_tissue1, mask_tissue2, mask_tissue3);

        mask_pgmn = mask_pgmn(:,:,1);
        mask_pgmn = logical(mask_pgmn).*mask_tissue;
        mask_final(repmat(logical(mask_pgmn), [1, 1, 3])) = 255;
       
        imwrite(mask_final, fullfile(dst_path, [file_name, '_tme_tumorBed.png']))
    end
end


