clear
clc
close all


pgmn_mask = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/pgmn_segformer_stainedgeV3/mask_ss1_x8';
tissue_mask = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/ss1x8overlay_alveoli_tbed_remove90000_necLN';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/pgmn_segformer_stainedgeV3/mask_ss1_x8_tbedmask';
if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(pgmn_mask, '*.png'));
tbed_corlor = [135, 133, 186];
tissue_color = [243, 205, 204];
alveoli_color = [0, 128, 0];

tableTmp = table("",0, 0, 0,0,'VariableNames',{'ID','pgmn_tbed', 'pgmn_norm', 'tumor_bed', 'tissue8'});
k = length(files);
pgmn_pix = zeros(k, 4);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '.svs_Ss1.png');
    pgmn = imread(fullfile(pgmn_mask, file_name));
    pgmn = logical(pgmn(:,:,2));
    tissue_raw = imread(fullfile(tissue_mask, [wsi_ID, '.svs_alveoli_tbed.png']));
    tissue = tissue_raw(:,:,2);
    tissue_area = length(find(tissue(:) >0));
    tumor_bed_area = length(find(tissue(:) == 133));
    pgmn_tissue = tissue_raw .* uint8(pgmn);
    imwrite(pgmn_tissue, fullfile(dst_path, [file_name, '.svs_Ss1_tissue.png']))

    pgmn_tbed_area = length(find(pgmn_tissue(:) == 133));
    pgmn_norm_area = length(find(pgmn_tissue(:) == 128));

    
    pgmn_pix(i, 1) = isempty(tumor_bed_area) * 0 + ~isempty(tumor_bed_area) * tumor_bed_area;
    pgmn_pix(i, 2) = isempty(pgmn_tbed_area) * 0 + ~isempty(pgmn_tbed_area) * pgmn_tbed_area;
    pgmn_pix(i, 3) = isempty(pgmn_norm_area) * 0 + ~isempty(pgmn_norm_area) * pgmn_norm_area;
    pgmn_pix(i, 4) = tissue_area;
    
    
    tableTmp.ID(i) = wsi_ID;
    tableTmp.pgmn_tbed(i) = pgmn_pix(i, 2);
    tableTmp.pgmn_norm(i) = pgmn_pix(i, 3);
    tableTmp.tumor_bed(i) = pgmn_pix(i, 1);
    tableTmp.tissue8(i) = pgmn_pix(i, 4);
        
end
%writetable(tableTmp, '/Users/xiaoxipan/Documents/project/anthracosis/pix_segformerv3/pix_pgmn_necrosis_tbedRevisit/tcga_pgmn_tbed_alveoli_LN.xlsx')