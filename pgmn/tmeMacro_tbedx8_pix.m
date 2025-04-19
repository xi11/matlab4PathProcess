clear
clc
close all
% note that tme masks need to upscaled by 2 times

tme_mask = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/tme/mit-b3-finetuned-TCGAbcssWsss10xLuadMacroMuscle-40x896-20x512-10x256re/mask_ss1512';
tissue_mask = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/ss1x8overlay_alveoli_nonTper_tbedAlveoli81000tme_close5remove90000_necLN';
files = dir(fullfile(tme_mask, '*.png'));
tbed_corlor = [135, 133, 186];
tissue_color = [243, 205, 204];
alveoli_color = [0, 128, 0];

tableTmp = table("",0, 0, 0, 0, 0, 0,'VariableNames',{'ID','inflam_tbed', 'inflam_norm', 'macro_tbed', 'macro_norm', 'tumor_tbed', 'stroma_tbed'});
k = length(files);
gp_pix = zeros(k, 6);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '.svs_Ss1.png');
    tme = imread(fullfile(tme_mask, file_name));
    tissue = imread(fullfile(tissue_mask, [wsi_ID, '.svs_alveoli_tbed.png']));
    tissue = tissue(:,:,2);
    [m, n] = size(tissue);
    tme = imresize(tme, [m, n], "nearest"); 

    inflam_mask = (tme(:,:,1) == 255) & (tme(:,:,2) == 0) & (tme(:,:,3) == 0);
    macro_mask = (tme(:,:,1)==128) & (tme(:,:,2)==0) & (tme(:,:,3)==128);
    tumor_mask = (tme(:,:,1)==128) & (tme(:,:,2)==0) & (tme(:,:,3)==0);
    stroma_mask = (tme(:,:,1)==255) & (tme(:,:,2)==255) & (tme(:,:,3)==0);
    inflam_tissue = tissue.* uint8(inflam_mask);
    macro_tissue = tissue.* uint8(macro_mask);
    tumor_tissue = tissue.* uint8(tumor_mask);
    stroma_tissue = tissue.* uint8(stroma_mask);

    inflam_tbed_area = length(find(inflam_tissue(:) == 133));
    inflam_norm_area = length(find(inflam_tissue(:) == 128));
    macro_tbed_area = length(find(macro_tissue(:) == 133));
    macro_norm_area = length(find(macro_tissue(:) == 128));
    tumor_tbed_area = length(find(tumor_tissue(:) == 133));
    stroma_tbed_area = length(find(stroma_tissue(:) == 133));

    
    gp_pix(i, 1) = isempty(inflam_tbed_area) * 0 + ~isempty(inflam_tbed_area) * inflam_tbed_area;
    gp_pix(i, 2) = isempty(inflam_norm_area) * 0 + ~isempty(inflam_norm_area) * inflam_norm_area;
    gp_pix(i, 3) = isempty(macro_tbed_area) * 0 + ~isempty(macro_tbed_area) * macro_tbed_area;
    gp_pix(i, 4) = isempty(macro_norm_area) * 0 + ~isempty(macro_norm_area) * macro_norm_area;
    gp_pix(i, 5) = isempty(tumor_tbed_area) * 0 + ~isempty(tumor_tbed_area) * tumor_tbed_area;
    gp_pix(i, 6) = isempty(stroma_tbed_area) * 0 + ~isempty(stroma_tbed_area) * stroma_tbed_area;
    
    
    tableTmp.ID(i) = wsi_ID;
    tableTmp.inflam_tbed(i) = gp_pix(i, 1);
    tableTmp.inflam_norm(i) = gp_pix(i, 2);
    tableTmp.macro_tbed(i) = gp_pix(i, 3);
    tableTmp.macro_norm(i) = gp_pix(i, 4);
    tableTmp.tumor_tbed(i) = gp_pix(i, 5);
    tableTmp.stroma_tbed(i) = gp_pix(i, 6);
        
end
writetable(tableTmp, '/Volumes/yuan_lab/TIER2/anthracosis/tcga-luad/tme/mit-b3-finetuned-TCGAbcssWsss10xLuadMacroMuscle-40x896-20x512-10x256re/tcga_tmex8_tbedRefine_alveoliLN.xlsx')


