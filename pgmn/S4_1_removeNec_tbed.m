clear;
clc;
close all

% to remove necrosis, fat and muscle identified by tme segformer
% non-use
src_path1 = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/tme/mit-b3-finetuned-TCGAbcssWsss10xLuadMacroMuscle-40x896-20x512-10x256re/mask_ss1512';
src_path2 = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/ss1x8overlay_tissue_tbed_remove90000';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/ss1x8overlay_tissue_tbed_remove90000_nec';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end


files = dir(fullfile(src_path1, 'TCGA-05-4410*.png'));
for i =1:length(files)
    file_name = files(i).name(1: end-12);
    disp(file_name)
    mask_tme = imread(fullfile(src_path1, files(i).name));
    mask_tbed = imread(fullfile(src_path2, [file_name, '.svs_tissue_tbed.png']));

    [m, n, ~] = size(mask_tbed);
    mask_nec = (mask_tme(:,:,1) == 255) & (mask_tme(:,:,2) == 0) & (mask_tme(:,:,3) == 255);
    mask_fat = (mask_tme(:,:,1) == 128) & (mask_tme(:,:,2) == 128) & (mask_tme(:,:,3) == 0);
    mask_muscle = (mask_tme(:,:,1) == 0) & (mask_tme(:,:,2) == 0) & (mask_tme(:,:,3) == 128);
    mask_union = mask_nec | mask_fat |mask_muscle;
    cc = bwconncomp(mask_union);
    stats = regionprops(cc,'Area');
    idx = find([stats.Area] > 1849); % 43*43, 0.3*0.3; 71*71 pix, 0.5*0.5mm;
    BW = ismember(labelmatrix(cc),idx);
    BW = ~BW;
    BW = imresize(BW, [m, n], 'nearest');
    mask_tbed_nec = mask_tbed .*uint8(BW);
    imwrite(mask_tbed_nec, fullfile(dst_path, [file_name, '.svs_tissue_tbed.png']));
end

