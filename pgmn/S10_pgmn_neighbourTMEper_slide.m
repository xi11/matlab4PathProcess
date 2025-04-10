clear;
clc;
close all


src_path1 = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/pgmn_segformer_stainedgeV3/mask_ss1_x8_4tme_tbed';
src_path2 = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/pgmn_segformer_stainedgeV3/mask_ss1_x8_4tme_lung';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/pgmn_segformer_stainedgeV3';
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
    };

tissue_labels = {'tumor', 'stroma', 'inflammatory', 'necrosis', ...
    'adipose', 'bronchi', 'microvessel', ...
    'macrophage', 'alveoli', 'muscle'};
result_table = [];
files = dir(fullfile(src_path1, '*.png'));
for i =1:length(files)
    file_name_raw = files(i).name;
    file_name = extractBefore(file_name_raw, '_pgmnNeighbour_tme_tbed.png');
    disp(file_name)

    pgmn_tme_tbed = imread(fullfile(src_path1, file_name_raw));
    pgmn_tme_lung = imread(fullfile(src_path2, [file_name, '_pgmnNeighbour_tme_lung.png']));
    
    for region_type = ["tbed", "lung"]
        if region_type == "tbed"
            region_mask = pgmn_tme_tbed;
        else
            region_mask = pgmn_tme_lung;
        end

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
            for k = 1:length(tissue_labels)
                ref_color = tissue_colors{k,1};
                match = all(region_colors == ref_color, 2);
                count = sum(match);
                tissue_row(k) = count / total_pixels * 100;
            end
        else
            tissue_row = zeros(1, length(tissue_labels));
        end

        % Append one row: slide, region, percentages
        result_table = [result_table; [{file_name, char(region_type)}, num2cell(tissue_row)]];


    end

end

T = cell2table(result_table, ...
    'VariableNames', [{'file_name', 'region_type'}, tissue_labels]);
writetable(T, fullfile(dst_path, 'tma5_pgmnNeighbour_TMEper.xlsx'));




