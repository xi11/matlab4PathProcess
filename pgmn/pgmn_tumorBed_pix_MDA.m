clear
clc
close all


pgmn_mask = '/Volumes/yuan_lab/TIER2/anthracosis/TMA5/pgmn_TMEsegDiv12sCE/mask_ss1_x8';
tissue_mask = '/Volumes/yuan_lab/TIER2/anthracosis/TMA5/ss1x8_tme_tissue21_90000_tumorBed5_DCP20_90000_segformerTCGA512';
files = dir(fullfile(pgmn_mask, '*.png'));

tableTmp = table("",0, 0, 0,0,'VariableNames',{'ID','pgmn_tbed', 'pgmn_norm', 'tumor_bed', 'tissue8'});
k = length(files);
gp_pix = zeros(k, 4);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '.svs_Ss1.png');
    pgmn = imread(fullfile(pgmn_mask, file_name));
    pgmn = logical(pgmn(:,:,1));
    tissue = imread(fullfile(tissue_mask, [wsi_ID, '.svs_tme_tumorBed.png']));
    tumor_bed = tissue(:,:,1);
    tissue_area = length(find(tumor_bed(:) >0));
    tumor_bed_area = length(find(tumor_bed(:) == 255));
    pgmn_tumor_mask = tumor_bed.* uint8(pgmn);
    pgmn_tumor_area = length(find(pgmn_tumor_mask(:) == 255));
    pgmn_tissue_area = length(find(pgmn_tumor_mask(:) == 128));

    
    gp_pix(i, 1) = isempty(tumor_bed_area) * 0 + ~isempty(tumor_bed_area) * tumor_bed_area;
    gp_pix(i, 2) = isempty(pgmn_tumor_area) * 0 + ~isempty(pgmn_tumor_area) * pgmn_tumor_area;
    gp_pix(i, 3) = isempty(pgmn_tissue_area) * 0 + ~isempty(pgmn_tissue_area) * pgmn_tissue_area;
    gp_pix(i, 4) = tissue_area;
    
    
    tableTmp.ID(i) = wsi_ID;
    tableTmp.pgmn_tbed(i) = gp_pix(i, 2);
    tableTmp.pgmn_norm(i) = gp_pix(i, 3);
    tableTmp.tumor_bed(i) = gp_pix(i, 1);
    tableTmp.tissue8(i) = gp_pix(i, 4);
        
end
writetable(tableTmp, '/Users/xiaoxipan/Documents/project/anthracosis/pix_TMEsegFOplaindiv12sCE/pix_pgmn/TMA5_pgmn_tumorBed_TME.xlsx')