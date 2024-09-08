clear
clc
close all


pgmn_mask = '/Volumes/yuan_lab/TIER2/anthracosis/prospect/pgmn_TMEsegDiv12sCE_stainedgeV3_tf2p10/mask_ss1_x8';
tissue_mask = '/Volumes/yuan_lab/TIER2/anthracosis/prospect/ss1x8overlay_tissue_tbed_remove90000LN_nec';
files = dir(fullfile(pgmn_mask, '*.png'));
tbed_corlor = [135, 133, 186];
tissue_color = [243, 205, 204];
alveoli_color = [0, 128, 0];

tableTmp = table("",0, 0, 0,0,'VariableNames',{'ID','pgmn_tbed', 'pgmn_norm', 'tumor_bed', 'tissue8'});
k = length(files);
gp_pix = zeros(k, 4);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '.svs_Ss1.png');
    pgmn = imread(fullfile(pgmn_mask, file_name));
    pgmn = logical(pgmn(:,:,2));
    tissue = imread(fullfile(tissue_mask, [wsi_ID, '.svs_tissue_tbed.png']));
    tissue = tissue(:,:,2);
    tissue_area = length(find(tissue(:) >0));
    tumor_bed_area = length(find(tissue(:) == 133));
    pgmn_tissue = tissue.* uint8(pgmn);
    pgmn_tbed_area = length(find(pgmn_tissue(:) == 133));
    pgmn_norm_area = length(find(pgmn_tissue(:) == 205));

    
    gp_pix(i, 1) = isempty(tumor_bed_area) * 0 + ~isempty(tumor_bed_area) * tumor_bed_area;
    gp_pix(i, 2) = isempty(pgmn_tbed_area) * 0 + ~isempty(pgmn_tbed_area) * pgmn_tbed_area;
    gp_pix(i, 3) = isempty(pgmn_norm_area) * 0 + ~isempty(pgmn_norm_area) * pgmn_norm_area;
    gp_pix(i, 4) = tissue_area;
    
    
    tableTmp.ID(i) = wsi_ID;
    tableTmp.pgmn_tbed(i) = gp_pix(i, 2);
    tableTmp.pgmn_norm(i) = gp_pix(i, 3);
    tableTmp.tumor_bed(i) = gp_pix(i, 1);
    tableTmp.tissue8(i) = gp_pix(i, 4);
        
end
writetable(tableTmp, '/Users/xiaoxipan/Documents/project/anthracosis/pix_TMEsegFOplaindiv12sCEv3/pix_pgmn_necrosis/prospect_pgmn_tbed_tissue.xlsx')