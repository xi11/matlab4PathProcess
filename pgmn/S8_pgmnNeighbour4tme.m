clear;
clc;
close all

tme_path = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/mit-b3-finetuned-TCGAbcssWsss10xLuadMacroMuscle-40x896-20x512-10x256re/mask_ss1512';
pgmn_path = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/pgmn_segformer_stainedgeV3/mask_ss1_x8';
tbed_path = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/ss1x8overlay_alveoli_tbed_remove90000_nec';
dst_path1 = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/pgmn_segformer_stainedgeV3/mask_ss1_x8_5filter100_dilate15_4tme';
dst_path2 = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/pgmn_segformer_stainedgeV3/mask_ss1_x8_5filter100_dilate15_neighbour_4tme';
if ~exist(dst_path1, 'dir')
    mkdir(dst_path1)
end

if ~exist(dst_path2, 'dir')
    mkdir(dst_path2)
end

tbed_corlor = [135, 133, 186];
tissue_color = [0, 128, 0];  %alveoli
files = dir(fullfile(pgmn_path, '*.png'));
for i =1:length(files)
    file_name = files(i).name(1:end-12); 
    disp(file_name)
    if ~isfile(fullfile(dst_path1, [file_name, '_4tme.png']))
       
        pgmn_raw = imread(fullfile(pgmn_path, [file_name,  '.svs_Ss1.png'])); % binary mask
        tbed_raw = imread(fullfile(tbed_path, [file_name,  '.svs_alveoli_tbed.png']));
        [m, n, ~] = size(tbed_raw);

        tbed_mask = zeros(m, n);
        tbed_mask(tbed_raw(:,:,1)==tbed_corlor(1) & tbed_raw(:,:,2)==tbed_corlor(2) & tbed_raw(:,:,3)==tbed_corlor(3)) = 1;

        %pgmn_mask = pgmn_raw .* tbed_mask;
        pgmn_mask = pgmn_raw(:,:,1) > 0;
        radius_pgmn = 5;
        se1 = strel('disk', radius_pgmn);
        pgmn_neigh3 = imdilate(pgmn_mask, se1); % to eliminate noise
        pgmn_neigh3 = imfill(pgmn_neigh3 , 'holes');
        
        mask_pgmn_neigh3 = 255*uint8(pgmn_neigh3);
        imwrite(mask_pgmn_neigh3, fullfile(dst_path1, [file_name, '_4tme_dilate3.png']));

        % Get connected components
        CC = bwconncomp(pgmn_neigh3);
        component_sizes = cellfun(@numel, CC.PixelIdxList);
        
        % Find components larger than threshold
        large_components = component_sizes > 100;
        
        % Create new mask with only large components
        pgmn_filtered = false(size(pgmn_neigh3));
        pgmn_filtered(cat(1, CC.PixelIdxList{large_components})) = true;

        radius = 15; %29pixel: 98.62um
        se = strel('disk', radius);
        pgmn_neigh = imdilate(pgmn_filtered, se);
        mask_pgmn_neigh = 255*uint8(pgmn_neigh);
        imwrite(mask_pgmn_neigh, fullfile(dst_path1, [file_name, '_4tme.png']));
        
        
        pgmn_neigh_only = pgmn_neigh & ~pgmn_neigh3;
        mask_neigh = 255*uint8(pgmn_neigh_only);
        imwrite(mask_neigh, fullfile(dst_path2, [file_name, '_neighbour4tme.png']));
       
    end
end



% % Extract TME labels in the neighborhood
%         tme_vals = tme_mask(anth_neigh_only);
%         
%         % Count the frequency of each label
%         labels = unique(tme_vals);
%         counts = histc(tme_vals(:), labels);
%         
%         % Convert to proportions
%         proportions = counts / sum(counts);
%         
%         % Display result
%         disp(table(labels, counts, proportions));
% 
%         tme_raw = imread(fullfile(tme_path, [file_name,  '.svs_Ss1.png']));         % should be a labeled image
%         tme_raw_tbed = tme_raw.*tbed_mask;
%         tme_raw_tbed = imresize(tme_raw_tbed, [m, n], 'nearest');
% 
%         tumor_mask = tme_raw_tbed(:,:,1) == 128 & tme_raw_tbed(:,:,2) == 0 & tme_raw_tbed(:,:,3) == 0;
%         stroma_mask = tme_raw_tbed(:,:,1) == 255 & tme_raw_tbed(:,:,2) == 255 & tme_raw_tbed(:,:,3) == 0;
%         inflam_mask = tme_raw_tbed(:,:,1) == 255 & tme_raw_tbed(:,:,2) == 0 & tme_raw_tbed(:,:,3) == 0;
%         macrophage_mask = tme_raw_tbed(:,:,1) == 128 & tme_raw_tbed(:,:,2) == 0 & tme_raw_tbed(:,:,3) == 128;
%         bronchi_mask = tme_raw_tbed(:,:,1) == 0 & tme_raw_tbed(:,:,2) == 255 & tme_raw_tbed(:,:,3) == 255;
%         microvessel_mask = tme_raw_tbed(:,:,1) == 0 & tme_raw_tbed(:,:,2) == 0 & tme_raw_tbed(:,:,3) == 255;
%         adipose_mask = tme_raw_tbed(:,:,1) == 128 & tme_raw_tbed(:,:,2) == 128 & tme_raw_tbed(:,:,3) == 0;
% 
%         mask_tme = tumor_mask | stroma_mask | inflam_mask | macrophage_mask;
%         mask_tissue(repmat(mask_remove, [1 1 3])) = 0;
%         mask_bed = tbed_raw;
% 
% 
%         
% 
% 
%         mask_tissue = logical(rgb2gray(mask_tissue));
%         mask_tissue = imfill(mask_tissue, 'holes');
%       
%         se2 = strel('square',3);  %to set
%         mask_tissue  = imclose(mask_tissue , se2);
%         mask_tissue  = imfill(mask_tissue , 'holes');
%         mask_bed = uint8(mask_tissue) .* uint8(mask_bed);







