
clear;
clc;
close all

% this is to refine masks from ss1x8overlay_alveoli_tbed_remove90000LN_nec
% directly, then no need to go through LN necrosis etc removal and tbed
% revisit.


% Oct 23, to refine the overcall of tumor bed with non-alveoli tissue,
% basically take out non-alveoli, then fill in the holes, then multiply
% with raw tbed mask, then go to the tumor% checking

%to incorporate tme masks from tme-seg to guide more accurate tissue
%segmentation, mainly reduce the influence of artefacts from backgound,
%compress lung, which can be removed by overlaying tme-seg masks, basically
%if an individual component doesn't have tumor detected, then remove.

src_path = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/ss1x8overlay_alveoli_tbed_remove90000_nec';
tme_path = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/mit-b3-finetuned-TCGAbcssWsss10xLuadMacroMuscle-40x896-20x512-10x256re/mask_ss1512';
%dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/visium_TMA5primary2014/HE40x_tif/tbed1536_ss1/maskLuadLusc_tmeMacro_nonAlveoli_tumor5per_remove10000';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/ss1x8overlay_alveoli_tbedAlveoli_remove90000_nec';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end
tbed_corlor = [135, 133, 186];
tissue_color = [0, 128, 0];  %alveoli
files = dir(fullfile(src_path, '*.png'));
for i =1:length(files)
    file_name = files(i).name(1:end-21); 
    disp(file_name)
    if ~isfile(fullfile(dst_path, [file_name, '.svs_alveoli_tbed.png']))
        mask_raw = imread(fullfile(src_path, [file_name,  '.svs_alveoli_tbed.png'])); % /8
        [m1, n1, ~] = size(mask_raw);
        tbed_raw = zeros(m1, n1);
        tbed_raw(mask_raw(:,:,1)==135 & mask_raw(:,:,2)==133 & mask_raw(:,:,3)==186) = 1;
        
        %if isfile(fullfile(src_path, file_name, 'Ss1.jpg'))
        mask_tme = imread(fullfile(tme_path, [file_name, '.svs_Ss1.png']));
        [m, n, ~] = size(mask_tme);
        tbed_raw = imresize(tbed_raw, [m, n], 'nearest');
        
        %%%%%%%%%%%%%%%tumor-bed with tmesegMacro%%%%%%%%%%%%%%%%%%%%%
        %%% refine with alveoli
        mask_tissue = mask_tme;
        alveoli_mask = mask_tissue(:,:,1) == 0 & mask_tissue(:,:,2) == 128 & mask_tissue(:,:,3) == 0;
        muscle_mask = mask_tissue(:,:,1) == 0 & mask_tissue(:,:,2) == 0 & mask_tissue(:,:,3) == 128;
        fat_mask = mask_tissue(:,:,1) == 128 & mask_tissue(:,:,2) == 128 & mask_tissue(:,:,3) == 0;
        mask_remove = alveoli_mask | muscle_mask | fat_mask;
        mask_tissue(repmat(mask_remove, [1 1 3])) = 0;
        mask_bed = tbed_raw;
        mask_tissue = logical(rgb2gray(mask_tissue));
        mask_tissue = imfill(mask_tissue, 'holes');
      
        se2 = strel('square',3);  %to set
        mask_tissue  = imclose(mask_tissue , se2);
        mask_tissue  = imfill(mask_tissue , 'holes');
        mask_bed = uint8(mask_tissue) .* uint8(mask_bed);
        

        %%% refine with tumor
        mask_tumor = zeros(m, n);
        mask_tumor(mask_tme(:,:,1)==128 & mask_tme(:,:,2)==0 &mask_tme(:,:,3)==0) = 1;
        mask_bin = bwlabel(mask_bed);
        cc1 = bwconncomp(mask_bin);
        stats = regionprops(cc1,'Area', 'PixelIdxList');
        for j = 1:numel(stats)
            componentArea = stats(j).Area;
            componentPixels = stats(j).PixelIdxList;
            % Calculate the tumor area in the current component
            tumorArea = sum(mask_tumor(componentPixels));
    
            % Calculate the tumor area percentage
            tumorPer = tumorArea / componentArea;
            % If tumor area is less than 5%, remove the component
            if tumorPer < 0.05 
                mask_bed(componentPixels) = 0;  % Set the pixels to black (or any background color)
            end

            if componentArea < 10000
                mask_bed(componentPixels) = 0;  % Set the pixels to black (or any background color)
            end
        end
       
        mask_tbed_refine = uint8(mask_bed) .* uint8(tbed_raw);  %refined tumor bed
        mask_tbed_refine  = imresize(mask_tbed_refine , [m1, n1], 'nearest');

        %%%%tissue
        mask_tissue0 = logical(rgb2gray(mask_tme));
        mask_tissue1  = imfill(mask_tissue0 , 'holes');
        se1 = strel('disk',21);  %to set
        mask_tissue1  = imclose(mask_tissue1 , se1);
        mask_tissue1  = imfill(mask_tissue1 , 'holes');

        cc2 = bwconncomp(mask_tissue1);
        stats2 = regionprops(cc2,'Area');
        idx2 = find([stats2.Area] >= 90000); %dont change
        BW2 = ismember(labelmatrix(cc2),idx2);
        BW2 = imresize(BW2, [m1, n1], 'nearest');
        mask_tissue0 = imresize(mask_tissue0, [m1, n1], 'nearest');
        mask_alveoli = mask_tissue0 .*BW2;

        BW3 = logical(mask_tbed_refine);
        tissue1 = tissue_color(1) *uint8(mask_alveoli);
        tissue2 = tissue_color(2) *uint8(mask_alveoli);
        tissue3 = tissue_color(3) *uint8(mask_alveoli);

        tissue1(BW3) = tbed_corlor(1); 
        tissue2(BW3) = tbed_corlor(2); 
        tissue3(BW3) = tbed_corlor(3); 
        mask_final = cat(3,tissue1, tissue2, tissue3);
        mask_final = mask_final .* uint8(logical(rgb2gray(mask_raw)));

        imwrite(mask_final, fullfile(dst_path, [file_name, '_tme_tbed.png']))
    end
end


