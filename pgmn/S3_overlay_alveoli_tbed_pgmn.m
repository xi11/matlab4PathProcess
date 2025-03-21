clear;
clc;
close all

%to overlay tissue, tumor-bed
tme_path = '/Volumes/yuan_lab/TIER2/anthracosis/visium_TMA5primary2014/HE40x_tif/mit-b3-finetuned-TCGAbcssWsss10xLuadMacroMuscle-40x896-20x512-10x256re/mask_ss1x512';
tbed_path = '/Volumes/yuan_lab/TIER2/anthracosis/visium_TMA5primary2014/HE40x_tif/tbed1536_ss1/maskLuadLusc_tmeMacro_tumor5per_remove10000';
pgmn_path = '/Volumes/yuan_lab/TIER2/anthracosis/visium_TMA5primary2014/HE40x_tif/pgmn_segformer_stainedgeV3/mask_ss1_x8';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/visium_TMA5primary2014/HE40x_tif/ss1x8overlay_pgmn_alveoli_tbedraw_remove90000';  %default ss1x8overlay_alveoli_tbed_remove90000
 
if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end
tbed_corlor = [135, 133, 186];
tissue_color = [0, 128, 0];  %alveoli
files = dir(fullfile(tbed_path, '*.png'));
for i =1:length(files)
    file_name = files(i).name(1: end-13); %-13 / -9
    disp(file_name)
        mask_tbed = imread(fullfile(tbed_path, [file_name, '_tme_tbed.png'])); %_tme_tbed.png / _tbed.png
        mask_tme = imread(fullfile(tme_path, [file_name, '.tif_Ss1.png']));
        mask_pgmn = imread(fullfile(pgmn_path, [file_name, '.tif_Ss1.png']));
        [m, n, ~] = size(mask_pgmn);
        mask_tbed = imresize(mask_tbed, [m, n], 'nearest');

        %%%%tissue
        mask_tissue0 = logical(rgb2gray(mask_tme));
        mask_tissue  = imfill(mask_tissue0 , 'holes');
        se1 = strel('disk',21);  %to set
        %mask_tissue  = imopen(mask_tissue , se1);
        mask_tissue  = imclose(mask_tissue , se1);
        mask_tissue  = imfill(mask_tissue , 'holes');

        cc2 = bwconncomp(mask_tissue);
        stats2 = regionprops(cc2,'Area');
        idx2 = find([stats2.Area] >= 90000); %dont change
        BW2 = ismember(labelmatrix(cc2),idx2);
        BW2 = imresize(BW2, [m, n], 'nearest');
        mask_tissue0 = imresize(mask_tissue0, [m, n], 'nearest');
        
        mask_pgmn_re = mask_pgmn .*uint8(BW2);
        mask_alveoli = mask_tissue0 .*BW2;

        BW3 = logical(mask_tbed(:,:,1));
        mask_tissue1 = tissue_color(1) *uint8(mask_alveoli);
        mask_tissue2 = tissue_color(2) *uint8(mask_alveoli);
        mask_tissue3 = tissue_color(3) *uint8(mask_alveoli);

        mask_tme = imresize(mask_tme, [m, n], 'nearest');
        %mask_tme1 = mask_tme(:,:,1);
        %mask_tme2 = mask_tme(:,:,2);
        %mask_tme3 = mask_tme(:,:,3);
        mask_tissue1(BW3) = tbed_corlor(1); %mask_tme1(BW3); 
        mask_tissue2(BW3) = tbed_corlor(2); %mask_tme2(BW3);
        mask_tissue3(BW3) = tbed_corlor(3); %mask_tme3(BW3); 
        mask_final = cat(3,mask_tissue1, mask_tissue2, mask_tissue3);
        
        %%for better visualization
        mask_pgmn_re = mask_pgmn_re(:,:,1);
        mask_final(repmat(logical(mask_pgmn_re), [1, 1, 3])) = 255;
        %mask_final = imresize(mask_final,2,'nearest');

        imwrite(mask_final, fullfile(dst_path, [file_name, '.tif_alveoli_tbed.png']))
   
end