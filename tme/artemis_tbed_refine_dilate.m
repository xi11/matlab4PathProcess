
clear;
clc;
close all
%to incorporate tme masks from tme-seg to guide more accurate tissue
%segmentation, mainly reduce the influence of artefacts from backgound,
%compress lung, which can be removed by overlaying tme-seg masks, basically
%if an individual component doesn't have tumor detected, then remove.
src_path = '/Volumes/yuan_lab/TIER2/artemis_lei/IMPRESS_TNBC/tbed1536_ss1/maskLuadLusc_2use';
tme_path = '/Volumes/yuan_lab/TIER2/artemis_lei/IMPRESS_TNBC/mit-b3-finetunedBRCA-Artemis-e60-lr00001-s512-20x512/mask_ss1512';
dst_path = '/Volumes/yuan_lab/TIER2/artemis_lei/IMPRESS_TNBC/tbed1536_ss1/maskLuadLusc_tmeArtemis_tumor15dilate';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end


files = dir(fullfile(src_path, '*.png'));
for i =1:length(files)
    file_name = files(i).name(1:end-9);
    disp(file_name)
    %if ~isfile(fullfile(dst_path, [file_name, '_tme_tbed.png']))
        mask_raw = imread(fullfile(src_path, [file_name,  '_tbed.png']));
        %if isfile(fullfile(src_path, file_name, 'Ss1.jpg'))
        mask_tme = imread(fullfile(tme_path, [file_name, '.svs_Ss1.png']));
        [m, n, ~] = size(mask_tme);
        [m1, n1, ~] = size(mask_raw);
        mask_raw(m1:m, n1:n,:) = 0;
        %%%%%%%%%%%%%%%tumor-bed with tmesegMacro%%%%%%%%%%%%%%%%%%%%%
        mask_tumor = zeros(m, n);
        mask_tumor(mask_tme(:,:,1)==128 & mask_tme(:,:,2)==0 &mask_tme(:,:,3)==0) = 1;
        mask_bed = mask_raw(:,:,1);
        mask_bed(mask_bed > 0) = 1;

        mask_tissue = logical(mask_tumor);
        mask_tissue  = imfill(mask_tissue , 'holes');
        se2 = strel('disk',15);  %to set
        mask_tissue  = imdilate(mask_tissue , se2);
        mask_tissue  = imfill(mask_tissue , 'holes');
        mask_bed = uint8(mask_tissue) .* mask_bed;
       
        mask_final = mask_bed .* mask_raw;
        imwrite(mask_final, fullfile(dst_path, [file_name, '_tme_tbed.png']))
    %end
end


