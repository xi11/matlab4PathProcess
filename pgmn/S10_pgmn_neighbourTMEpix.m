clear;
clc;
close all


src_path1 = '/Volumes/yuan_lab/TIER2/anthracosis/TMA5/pgmn_segformer_stainedgeV3/mask_ss1_x8_4tme_tbed';
src_path2 = '/Volumes/yuan_lab/TIER2/anthracosis/TMA5/pgmn_segformer_stainedgeV3/mask_ss1_x8_4tme_lung';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/TMA5/pgmn_segformer_stainedgeV3/tme_per';
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
        CC = bwconncomp(region_mask_bin);
        props = regionprops(CC, 'PixelIdxList');
        result_table = [];

        for j = 1:length(props)
            idx = props(j).PixelIdxList;

            % Extract RGB triplets for pixels in this component
            R = region_mask(:,:,1);
            G = region_mask(:,:,2);
            B = region_mask(:,:,3);
            region_colors = [R(idx), G(idx), B(idx)];
            total_pixels = size(region_colors, 1);

            % Initialize tissue percentage row
            tissue_row = zeros(1, length(tissue_labels));

            % Check for each tissue color
            for k = 1:length(tissue_labels)
                ref_color = tissue_colors{k, 1};
                match = all(region_colors == ref_color, 2);
                count = sum(match);
                tissue_row(k) = count / total_pixels * 100;
            end

            % Append to results
            result_table = [result_table; [{file_name, j, char(region_type)}, num2cell(tissue_row)]];
        end




    end
    T = cell2table(result_table, ...
        'VariableNames', [{'file_name', 'component_id', 'region_type'}, ...
        strcat(tissue_labels, '_per')]);

    writetable(T, fullfile(dst_path, [file_name '_merged_components.xlsx']));


end




