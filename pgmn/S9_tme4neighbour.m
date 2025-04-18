clear;
clc;
close all

pgmn_neighbour = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/pgmn_segformer_stainedgeV3/mask_ss1_x8_1filter0fill_dilate5_neighbour_4tme';
tme_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/mit-b3-finetuned-TCGAbcssWsss10xLuadMacroMuscle-40x896-20x512-10x256re/mask_ss1512';
tbed_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/ss1x8overlay_alveoli_nonTper_tbedAlveoli81000tme_close5remove90000LN_nec';
dst_path1 = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/pgmn_segformer_stainedgeV3/mask_ss1_x8_1filter0fill_dilate5_4tme_tbed';
dst_path2 = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/pgmn_segformer_stainedgeV3/mask_ss1_x8_1filter0fill_dilate5_4tme_lung';

if ~exist(dst_path1, 'dir')
    mkdir(dst_path1)
end

if ~exist(dst_path2, 'dir')
    mkdir(dst_path2)
end

tbed_color = [135, 133, 186];
tissue_color = [0, 128, 0];  %alveoli
files = dir(fullfile(pgmn_neighbour, '*.png'));
for i =1:length(files)
    file_name = files(i).name(1:end-18); 
    disp(file_name)
    
    pgmn_raw = imread(fullfile(pgmn_neighbour, files(i).name)); % binary mask
    tbed_raw = imread(fullfile(tbed_path, [file_name,  '.svs_alveoli_tbed.png']));
    tme_raw = imread(fullfile(tme_path, [file_name,  '.svs_Ss1.png']));
    [m, n, ~] = size(tbed_raw);
    tme_mask = imresize(tme_raw, [m, n], 'nearest');
    pgmn_mask = pgmn_raw > 0; %logical

    tbed_mask = tbed_raw(:,:,1) == tbed_color(1) & ...
                tbed_raw(:,:,2) == tbed_color(2) & ...
                tbed_raw(:,:,3) == tbed_color(3);

    lung_mask = tbed_raw(:,:,1) == tissue_color(1) & ...
                tbed_raw(:,:,2) == tissue_color(2) & ...
                tbed_raw(:,:,3) == tissue_color(3); % ~tbed_mask will incorporate necrosis and LN

    % Extract tme values within pgmn & tbed
    pgmn_tme_tbed = tme_mask .* uint8(pgmn_mask & tbed_mask);
    imwrite(pgmn_tme_tbed, fullfile(dst_path1, [file_name, '_pgmnNeighbour_tme_tbed.png']));

    % Extract tme values within pgmn & not tbed
    pgmn_tme_lung = tme_mask .* uint8(pgmn_mask & lung_mask);
    imwrite(pgmn_tme_lung, fullfile(dst_path2, [file_name, '_pgmnNeighbour_tme_lung.png']));
end




