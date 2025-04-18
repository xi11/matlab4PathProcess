clear
clc
close all


pgmn_mask = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/pgmn_segformer_stainedgeV3/mask_ss1_x8';
tissue_mask = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/LN_tcga-luad_ss1/LN_mask';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/pgmn_segformer_stainedgeV3/mask_ss1_x8_LN';
if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(tissue_mask, '*.png'));


tableTmp = table("",0, 0, 'VariableNames',{'ID','pgmn_LN',  'LN_tissue'});
k = length(files);
pgmn_pix = zeros(k, 4);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '.svs_LN.png');
    
    tissue_raw = imread(fullfile(tissue_mask,  file_name)); 
    tissue_area = length(find(tissue_raw(:) >0));

    pgmn = imread(fullfile(pgmn_mask, [wsi_ID, '.svs_Ss1.png']));
    pgmn = logical(pgmn(:,:,2));

    pgmn_tissue = tissue_raw .* uint8(pgmn);
    imwrite(pgmn_tissue, fullfile(dst_path, [file_name, '.svs_Ss1_tissue.png']))

    pgmn_LN_area = length(find(pgmn_tissue(:) >0));
   
    
    pgmn_pix(i, 1) = pgmn_LN_area;
    pgmn_pix(i, 2) = tissue_area;

    
    
    tableTmp.ID(i) = wsi_ID;
    tableTmp.pgmn_LN(i) = pgmn_pix(i, 1);
    tableTmp.LN_tissue(i) = pgmn_pix(i, 2);
  
        
end
writetable(tableTmp, '/Users/xiaoxipan/Documents/project/anthracosis/pix_segformerv3/pix_pgmn_necrosis_tbedRevisit/tcga_pgmn_inLN.xlsx')