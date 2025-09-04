clear
clc
close all


src_gp_mask = '/Volumes/yuan_lab/TIER2/anthracosis/LungAdenocarcinomaEvolutionHE_PingMP/China/tme_RegionROIs';

files = dir(fullfile(src_gp_mask, '*.png'));
tableTmp = table("",0,0,0,0,0,0,0,0,0,0,'VariableNames',{'ID', 'tumor_pix', 'stroma_pix', 'inflam_pix', 'necrosis_pix',...
    'fat_pix', 'bronchi_pix', 'blood_pix', 'macrophage_pix', 'alveoli_pix', 'muscle_pix'});
k = length(files);
gp_pix = zeros(k, 10);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '.png'); %.svs_Ss1.png
   
    img = double(imread(fullfile(src_gp_mask, file_name)));
    temp = [];
    [m, n, ~] = size(img);
    mask_digit = zeros(m, n);
    mask_digit((img(:,:,1)==128 & img(:,:,2)==0 & img(:,:,3)==0)) = 1; %tumor
    mask_digit((img(:,:,1)==255 & img(:,:,2)==255 & img(:,:,3)==0)) = 2; %stroma
    mask_digit((img(:,:,1)==255 & img(:,:,2)==0 & img(:,:,3)==0)) = 3; %inflam
    mask_digit((img(:,:,1)==255 & img(:,:,2)==0 & img(:,:,3)==255)) = 4; %necrosis
    mask_digit((img(:,:,1)==128 & img(:,:,2)==128 & img(:,:,3)==0)) = 5; %fat
    mask_digit((img(:,:,1)==0 & img(:,:,2)==255 & img(:,:,3)==255)) = 6; %bronchi
    mask_digit((img(:,:,1)==0 & img(:,:,2)==0 & img(:,:,3)==255)) = 7; %blood
    mask_digit((img(:,:,1)==128 & img(:,:,2)==0 & img(:,:,3)==128)) = 8; %macrophage
    mask_digit((img(:,:,1)==0 & img(:,:,2)==128 & img(:,:,3)==0)) = 9; %alveoli
    mask_digit((img(:,:,1)==0 & img(:,:,2)==0 & img(:,:,3)==128)) = 10; %muscle
    
    
    for j = 1:10
        temp(j) = length(find(mask_digit(:)==j));
    end
    if max(temp)>0
    gp_pix(i, 1:10) = temp;  %pix
   
    end
    
    tableTmp.ID(i) = wsi_ID;
    tableTmp.tumor_pix(i) = gp_pix(i, 1);
    tableTmp.stroma_pix(i) = gp_pix(i, 2);
    tableTmp.inflam_pix(i) = gp_pix(i, 3);
    tableTmp.necrosis_pix(i) = gp_pix(i, 4);
    tableTmp.fat_pix(i) = gp_pix(i, 5);
    tableTmp.bronchi_pix(i) = gp_pix(i, 6);
    tableTmp.blood_pix(i) = gp_pix(i, 7);
    tableTmp.macrophage_pix(i) = gp_pix(i, 8);
    tableTmp.alveoli_pix(i) = gp_pix(i, 9);
    tableTmp.muscle_pix(i) = gp_pix(i, 10);
         
end
writetable(tableTmp, '/Volumes/yuan_lab/TIER2/anthracosis/LungAdenocarcinomaEvolutionHE_PingMP/China/tme_pix.xlsx')