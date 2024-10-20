clear;
clc;
close all

% to remove necrosis, fat and muscle identified by tme segformer
src_path1 = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/mit-b3-finetuned-TCGAbcssWsss10xLuadMacroMuscle-40x896-20x512-10x256re/mask_ss1512';
src_path2 = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/ss1x8overlay_alveoli_tbed_remove90000_revisit';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/ss1x8overlay_alveoli_tbed_remove90000_nec';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end


files = dir(fullfile(src_path1, '*.png'));
for i =1:length(files)
    file_name = files(i).name(1: end-12);
    disp(file_name)
    mask_tme = imread(fullfile(src_path1, files(i).name));
    mask_tbed_path = fullfile(src_path2, [file_name, '.svs_alveoli_tbed.png']);
    if exist(mask_tbed_path, 'file') == 2
    mask_tbed = imread(mask_tbed_path);

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
    imwrite(mask_tbed_nec, fullfile(dst_path, [file_name, '.svs_alveoli_tbed.png']));
    end
end

