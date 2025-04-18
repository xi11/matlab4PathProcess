clear;
clc;
close all

% to remove LN annotated by Maria and processed by Xiaoxi for internal data
% tcga has been confirmed with Maria and annotated by Xiaoxi
src_path1 = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/LN_tcga-luad_ss1/LN_tcga_mask';
src_path2 = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/ss1x8overlay_alveoli_nonTper_tbedAlveoli81000tme_close5remove90000_nec';
dst_path1 = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/LN_tcga-luad_ss1/alveoliRE';
dst_path2 = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/LN_tcga-luad_ss1/alveoli';

if ~exist(dst_path1, 'dir')
    mkdir(dst_path1)
end

if ~exist(dst_path2, 'dir')
    mkdir(dst_path2)
end

files = dir(fullfile(src_path1, '*.png'));
for i =1:length(files)
    file_name = files(i).name(1: end-11);
    disp(file_name)
    mask_LN = imread(fullfile(src_path1, files(i).name));
    mask_tbed = imread(fullfile(src_path2, [file_name, '.svs_alveoli_tbed.png']));
    imwrite(mask_tbed, fullfile(dst_path2, [file_name, '.svs_alveoli_tbed.png']));

    [m, n, ~] = size(mask_tbed);
    mask_LN_bin = (mask_LN(:,:,1) == 255) & (mask_LN(:,:,2) == 255) & (mask_LN(:,:,3) == 255);
    cc = bwconncomp(mask_LN_bin);
    stats = regionprops(cc,'Area');
    idx = find([stats.Area] >= 10000); %dont change
    BW = ismember(labelmatrix(cc),idx);
    BW = ~BW;
    BW = imresize(BW, [m, n], 'nearest');
    mask_tbed_ln = mask_tbed .*uint8(BW);
    imwrite(mask_tbed_ln, fullfile(dst_path1, [file_name, '.svs_alveoli_tbed.png']));
end

