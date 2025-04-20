
clear;
clc;
close all

%%%%for ST data, Apr 20
% Oct 23, to refine the overcall of tumor bed with non-alveoli tissue,
% basically take out non-alveoli, then fill in the holes, then multiply
% with raw tbed mask, then go to the tumor% checking

%to incorporate tme masks from tme-seg to guide more accurate tissue
%segmentation, mainly reduce the influence of artefacts from backgound,
%compress lung, which can be removed by overlaying tme-seg masks, basically
%if an individual component doesn't have tumor detected, then remove.

src_path = '/Volumes/yuan_lab/TIER2/anthracosis/visium_TMA5primary2014/HE40x_tif/tbed1536_ss1/maskLuadLusc';
tme_path = '/Volumes/yuan_lab/TIER2/anthracosis/visium_TMA5primary2014/HE40x_tif/mit-b3-finetuned-TCGAbcssWsss10xLuadMacroMuscle-40x896-20x512-10x256re/mask_ss1x512';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/visium_TMA5primary2014/HE40x_tif/tbed1536_ss1/maskLuadLusc_nonTper_nonAlveoli_remove10000';

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
        mask_tme = imread(fullfile(tme_path, [file_name, '.tif_Ss1.png']));
        [m, n, ~] = size(mask_tme);
        [m1, n1, ~] = size(mask_raw);
        mask_raw(m1:m, n1:n,:) = 0;
        %%%%%%%%%%%%%%%tumor-bed with tmesegMacro%%%%%%%%%%%%%%%%%%%%%
        %%% refine with alveoli
        mask_tissue = mask_tme;
        alveoli_mask = mask_tissue(:,:,1) == 0 & mask_tissue(:,:,2) == 128 & mask_tissue(:,:,3) == 0;
        muscle_mask = mask_tissue(:,:,1) == 0 & mask_tissue(:,:,2) == 0 & mask_tissue(:,:,3) == 128;
        fat_mask = mask_tissue(:,:,1) == 128 & mask_tissue(:,:,2) == 128 & mask_tissue(:,:,3) == 0;
        mask_remove = alveoli_mask | muscle_mask | fat_mask;
        mask_tissue(repmat(mask_remove, [1 1 3])) = 0;
        mask_bed = mask_raw(:,:,1);
        mask_bed(mask_bed > 0) = 1;
        mask_tissue = logical(rgb2gray(mask_tissue));
        mask_tissue = imfill(mask_tissue, 'holes');
      
        se2 = strel('square',3);  %to set
        mask_tissue  = imclose(mask_tissue , se2);
        mask_tissue  = imfill(mask_tissue , 'holes');
        mask_bed = uint8(mask_tissue) .* mask_bed;
        

        %%% refine with tumor
        mask_tumor = zeros(m, n);
        mask_tumor(mask_tme(:,:,1)==128 & mask_tme(:,:,2)==0 &mask_tme(:,:,3)==0) = 1;
        %mask_bed = mask_raw(:,:,1);
        %mask_bed(mask_bed > 0) = 1;
        %mask_tissue = logical(rgb2gray(mask_tme));
        %mask_tissue  = imfill(mask_tissue , 'holes');
        %se2 = strel('disk',15);  %to set
        %mask_tissue  = imdilate(mask_tissue , se2);
        %mask_tissue  = imfill(mask_tissue , 'holes');
        %mask_bed = uint8(mask_tissue) .* mask_bed;
        %%mask_bed  = imfill(mask_tme_bed , 'holes');

        mask_bin = bwlabel(mask_bed);
        cc1 = bwconncomp(mask_bin);
        stats = regionprops(cc1,'Area', 'PixelIdxList');
        for j = 1:numel(stats)
            componentArea = stats(j).Area;
            componentPixels = stats(j).PixelIdxList;
            % Calculate the tumor area in the current component
            tumorArea = sum(mask_tumor(componentPixels));

    
%             % Calculate the tumor area percentage; %%%removed in
%             S7_tbedrefineS4_pro.m
%             tumorPer = tumorArea / componentArea;
%             % If tumor area is less than 5%, remove the component
%             if tumorPer < 0.05 
%                 mask_bed(componentPixels) = 0;  % Set the pixels to black (or any background color)
%             end

            if componentArea < 10000
                mask_bed(componentPixels) = 0;  % Set the pixels to black (or any background color)
            end


        end

        mask_bed = imgaussfilt(double(mask_bed), 30); %30 is the final to use
        mask_bed = mask_bed > 0.5;
       
        mask_final = uint8(mask_bed) .* mask_raw;
        imwrite(mask_final, fullfile(dst_path, [file_name, '_tme_tbed.png']))
    %end
end


