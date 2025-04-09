clear
clc
close all


tissue_mask = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/ss1x8overlay_alveoli_tbed_remove90000_necLN';
ss1_path = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/ss1_images';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/ss1_images_tbedmask';
if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(tissue_mask, '*.png'));
k = length(files);

for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '.svs_alveoli_tbed.png');
    ss1_img = imread(fullfile(ss1_path, [wsi_ID, '_Ss1.jpg']));
    [m, n, ~] = size(ss1_img);
   
    tissue_raw = imread(fullfile(tissue_mask, [wsi_ID, '.svs_alveoli_tbed.png']));
    tissue = tissue_raw(:,:,2);

    tissue = logical(imresize(tissue, [m, n]));
    ss1_img_tissue = ss1_img .* uint8(tissue);
    
    imwrite(ss1_img_tissue, fullfile(dst_path, [file_name, '_Ss1_tissue.png']))

        
end
