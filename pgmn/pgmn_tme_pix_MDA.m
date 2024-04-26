clear
clc
close all

% unfinished yet
pgmn_mask = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker_multi/pgmn_TMEsegDiv12sCE/mask_ss1_x8';
tme_mask = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker_multi/mit-b3-finetuned-tmeTCGAbrcaLUAD-e60-lr00001-s512-20x768-10x512rere/mask_ss1768';
files = dir(fullfile(pgmn_mask, '*.png'));

tableTmp = table("",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'VariableNames',{'ID','pgmn_tumor', 'pgmn_necrosis', 'pgmn_stroma', 'pgmn_inflam', 'pgmn_fat', 'pgmn_parenchyma', 'pgmn_vessel', 'pgmn_alveolar', ...
    'tumor', 'necrosis', 'stroma', 'inflam', 'fat', 'parenchyma', 'vessel', 'alveolar'});
k = length(files);
pgmn_pix = zeros(k, 16);
tme_pix = zeros(k, 16);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '.svs_Ss1.png');
    pgmn = imread(fullfile(pgmn_mask, file_name));
    [m ,n ,~] = size(pgmn);
    pgmn = logical(pgmn(:,:,1));
    tme = imread(fullfile(tme_mask, [wsi_ID, '.svs_Ss1.png']));
    tme = imresize(tme, [m, n], 'nearest');
    
    % haven't changed the following
    tumor_bed = tme(:,:,1);
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
    tableTmp.tissue(i) = gp_pix(i, 4);
        
end
writetable(tableTmp, '/Users/xiaoxipan/Documents/project/anthracosis/pix_TMEsegFOplaindiv12sCE/tcga-lusc_pgmn_tumorBed.xlsx')