clear
clc
close all


src_gp_mask = '/Volumes/yuan_lab/TIER2/artemis_lei/discovery/mit-b3-finetuned-tmeTCGA-60-lr00001-s512-20x768/mask_ss1512_post_tumor15_900_tbed_orng';

files = dir(fullfile(src_gp_mask, '*.png'));

tableTmp = table("",0,0,0,0,0,0,0,'VariableNames',{'ID',...
    'tumor_pix', 'necrosis_pix', 'stroma_pix', 'fat_pix', 'parenchyma_pix', 'blood_pix', 'inflam_pix'});
k = length(files);
gp_pix = zeros(k, 7);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '_Ss1.png');
   
    img = double(imread(fullfile(src_gp_mask, file_name)));
    temp = [];
    [m, n, ~] = size(img);
    mask_digit = zeros(m, n);
    mask_digit((img(:,:,1)==255 & img(:,:,2)==0 & img(:,:,3)==255)) = 1; %necrosis
    mask_digit((img(:,:,1)==128 & img(:,:,2)==0 & img(:,:,3)==0)) = 2; %tumor
    mask_digit((img(:,:,1)==255 & img(:,:,2)==204 & img(:,:,3)==0)) = 3; %stroma
    mask_digit((img(:,:,1)==128 & img(:,:,2)==128 & img(:,:,3)==0)) = 4; %fat
    mask_digit((img(:,:,1)==0 & img(:,:,2)==255 & img(:,:,3)==255)) = 5; %parenchyma
    %%added for model trained with tcga only
    mask_digit((img(:,:,1)==0 & img(:,:,2)==0 & img(:,:,3)==255)) = 6; %blood
    mask_digit((img(:,:,1)==255 & img(:,:,2)==0 & img(:,:,3)==0)) = 7; %inflam

    
    for j = 1:7
        temp(j) = length(find(mask_digit(:)==j));
    end
    if max(temp)>0
    
    gp_pix(i, 1:7) = temp;  %pix
   
    end
    
    
    tableTmp.ID(i) = wsi_ID;
    tableTmp.tumor_pix(i) = gp_pix(i, 2);
    tableTmp.necrosis_pix(i) = gp_pix(i, 1);
    tableTmp.stroma_pix(i) = gp_pix(i, 3);
    tableTmp.fat_pix(i) = gp_pix(i, 4);
    tableTmp.parenchyma_pix(i) = gp_pix(i, 5);
    tableTmp.blood_pix(i) = gp_pix(i, 6);
    tableTmp.inflam_pix(i) = gp_pix(i, 7);
 


%           
end
writetable(tableTmp, '/Volumes/yuan_lab/TIER2/artemis_lei/discovery/mit-b3-finetuned-tmeTCGA-60-lr00001-s512-20x768/discovery_post_tme_tbed_pix.xlsx')