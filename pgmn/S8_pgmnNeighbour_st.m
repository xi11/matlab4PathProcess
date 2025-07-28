clear;
clc;
close all


pgmn_path = '/Volumes/yuan_lab/TIER2/anthracosis/10x_xenium/pgmn_segformer_stainedgeV3/mask_ss1_x1'; % 20x, 0.44mpp
dst_path1 = '/Volumes/yuan_lab/TIER2/anthracosis/10x_xenium/pgmn_segformer_stainedgeV3/mask_ss1_x1_filter0fill_dilate227'; % 23pix: 10um; 45pix: 20um; 91pix: 40um; 114pix: 50um; 136pix: 60um; 182pix: 80um
if ~exist(dst_path1, 'dir')
    mkdir(dst_path1)
end

files = dir(fullfile(pgmn_path, '*.png'));
for i =1:length(files)
    file_name = files(i).name(1:end-12); 
    disp(file_name)
       
        pgmn_raw = imread(fullfile(pgmn_path, [file_name,  '.tif_Ss1.png'])); % binary mask

        pgmn_mask = pgmn_raw(:,:,1) > 0;
        pgmn_neigh3 = imfill(pgmn_mask, 'holes');
        % Get connected components
        CC = bwconncomp(pgmn_neigh3);
        component_sizes = cellfun(@numel, CC.PixelIdxList);
        
        % Find components larger than threshold
        large_components = component_sizes > 0; % decide no to filter since there could be dispersed carbon particles, 
        
        % Create new mask with only large components
        pgmn_filtered = false(size(pgmn_neigh3));
        pgmn_filtered(cat(1, CC.PixelIdxList{large_components})) = true;

        radius = 227; %23pix: 10um; 45pix: 20um; 91pix: 40um; 114pix: 50um; 136pix: 60um; 182pix: 80um; 227pix: 100um
        se = strel('disk', radius);
        pgmn_neigh = imdilate(pgmn_filtered, se);
        mask_pgmn_neigh = 255*uint8(pgmn_neigh);
        imwrite(mask_pgmn_neigh, fullfile(dst_path1, [file_name, '_dilate.png']));
      
       
end




