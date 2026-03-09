clear;
clc;
close all


src_path = '/Volumes/yuan_lab/TIER2/melanoma_vp/pilot1_Mar2025/pgmn_segformer_stainedgeV3/mask_ss1_x8';

dst_path = '/Volumes/yuan_lab/TIER2/melanoma_vp/pilot1_Mar2025/mit-b3-finetuned-TCGAbcssWsss10xLuadMacroMuscle-40x896-20x512-10x256re';
if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

tissue_colors = {
    [128, 0, 0],     'tumor';
    [255, 255, 0],   'stroma';
    [255, 0, 0],     'inflammatory';
    [255, 0, 255],   'necrosis';
    [128, 128, 0],   'adipose';
    [0, 255, 255],   'bronchi';
    [0, 0, 255],     'microvessel';
    [128, 0, 128],   'macrophage';
    [0, 128, 0],     'alveoli';
    [0, 0, 128],     'muscle';
    [255, 255, 255], 'pigment'
    };

tissue_labels = {'tumor', 'stroma', 'inflammatory', 'necrosis', ...
    'adipose', 'bronchi', 'microvessel', ...
    'macrophage', 'alveoli', 'muscle', 'pigment', 'tme_pix'};
result_table = [];
files = dir(fullfile(src_path, '*.png'));
for i =1:length(files)
    file_name_raw = files(i).name;
    file_name = extractBefore(file_name_raw, '.svs_Ss1.png');
    disp(file_name)
    tme_mask = imread(fullfile(src_path, file_name_raw));
    region_mask = imresize(tme_mask, 0.5, 'nearest');

    region_mask_bin = rgb2gray(region_mask) >0;
    if any(region_mask_bin(:))
        R = region_mask(:,:,1);
        G = region_mask(:,:,2);
        B = region_mask(:,:,3);
        R = R(region_mask_bin);
        G = G(region_mask_bin);
        B = B(region_mask_bin);
        region_colors = [R, G, B];
        total_pixels = size(region_colors, 1);

        tissue_row = zeros(1, length(tissue_labels));
        for k = 1:length(tissue_labels)-1 % to remove tme_pix col
            ref_color = tissue_colors{k,1};
            match = all(region_colors == ref_color, 2);
            count = sum(match);
            tissue_row(k) = count / total_pixels * 100;
        end
        tissue_row(k+1) = total_pixels;
    else
        tissue_row = zeros(1, length(tissue_labels));
    end

    % Append one row: slide, region, percentages
    result_table = [result_table; [{file_name}, num2cell(tissue_row)]];

end

T = cell2table(result_table, ...
    'VariableNames', [{'ID'}, tissue_labels]);
writetable(T, fullfile(dst_path, 'TMEseg_TMEper_pgmnpix.xlsx'));




