
clear;
clc;
close all
%to incorporate tme masks from tme-seg to guide more accurate tissue
%segmentation, mainly reduce the influence of artefacts from backgound, but
%not sure for prospect-pilot tumor-bed, it's DCP30, while DCP20 for
%never-smoker pilot, it's DCP20. W/ or w/o pgmn is for whether overlaying
%pgmn on the tumor-bed or tissue
src_path = '/Volumes/yuan_lab/public_data/TCGA_luad/til/1_cws_tiling';
tme_path = '/Volumes/yuan_lab/public_data/TCGA_luad/tme/mit-b3-finetuned-tmeTCGAbrcaLUAD-e60-lr00001-s512-20x768-10x512rere/mask_ss1768';
ref_path = '/Volumes/yuan_lab/public_data/TCGA_luad/pigment/pgmn_TMEsegDiv12sCE/mask_ss1_x8';
pgmn_refine = '/Volumes/yuan_lab/public_data/TCGA_luad/pigment/pgmn_TMEsegDiv12sCE/mask_ss1_x8_erode21';
dst_path = '/Volumes/yuan_lab/public_data/TCGA_luad/pigment/ss1x8_tme_tissue21_90000_tumorBed5_DCP20_90000_segformerTCGA768_erode21';


if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

if ~exist(pgmn_refine, 'dir')
    mkdir(pgmn_refine)
end

files = dir(fullfile(src_path, 'TCGA-55*.svs'));
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
        mask_post2(mask_minus>20)=255; %20 is better for architecture pattern, lepidic, papillary
        mask_post2(mask_minus<=20)=0;
        
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
        se2 = strel('disk',21);  %to set
        mask_tissue  = imclose(mask_tissue , se2);
        mask_tissue  = imfill(mask_tissue , 'holes');
        mask_tissue = imresize(mask_tissue, [m, n], 'nearest');
        

        cc2 = bwconncomp(mask_tissue);
        stats2 = regionprops(cc2,'Area');
        idx2 = find([stats2.Area] >= 90000);
        BW2 = ismember(labelmatrix(cc2),idx2);

        se3 = strel('disk',21);  %to set
        BW2  = imerode(BW2 , se3);
        mask_pgmn_re = mask_pgmn .*uint8(BW2);
        imwrite(mask_pgmn_re, fullfile(pgmn_refine, [file_name, '_Ss1.png']))


        BW3 = logical(uint8(BW1).*uint8(BW2));
        mask_tme = imresize(mask_tme, [m, n], 'nearest');
        mask_tme1 = mask_tme(:,:,1);
        mask_tme2 = mask_tme(:,:,2);
        mask_tme3 = mask_tme(:,:,3);

        mask_tissue1 = 128*uint8(BW2);
        mask_tissue2 = 0*uint8(BW2);
        mask_tissue3 = 128*uint8(BW2);
        mask_tissue1(BW3) =  255; %mask_tme1(BW3);
        mask_tissue3(BW3) =  0; %mask_tme3(BW3);
        mask_tissue2(BW3) = 0; %mask_tme2(BW3); %
        mask_final = cat(3,mask_tissue1, mask_tissue2, mask_tissue3);
        

        %mask_pgmn = mask_pgmn(:,:,1);
        %mask_pgmn = logical(mask_pgmn).*mask_tissue;
        %mask_final(repmat(logical(mask_pgmn), [1, 1, 3])) = 255;
       
        imwrite(mask_final, fullfile(dst_path, [file_name, '_tme_tumorBed.png']))
    end
end


