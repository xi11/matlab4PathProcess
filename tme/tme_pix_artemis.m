clear
clc
close all


src_gp_mask = '/Volumes/yuan_lab/TIER2/artemis_lei/discovery/TMEsegFT_div12_sCE_6class_img768_pen636/mask_ss1';

files = dir(fullfile(src_gp_mask, '*.png'));

tableTmp = table("",0,0,0,0,0,'VariableNames',{'ID',...
    'parenchyma', 'necrosis', 'tumor', 'stroma', 'fat',});
k = length(files);
gp_pix = zeros(k, 5);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '.svs_Ss1.png');
   
    img = double(imread(fullfile(src_gp_mask, file_name)));
    temp = [];
    [m, n, ~] = size(img);
    mask_digit = zeros(m, n);
    mask_digit((img(:,:,1)==0 & img(:,:,2)==255 & img(:,:,3)==0)) = 1; %parenchyma
    mask_digit((img(:,:,1)==255 & img(:,:,2)==0 & img(:,:,3)==255)) = 2; %necrosis
    mask_digit((img(:,:,1)==128 & img(:,:,2)==0 & img(:,:,3)==0)) = 3; %tumor
    mask_digit((img(:,:,1)==0 & img(:,:,2)==255 & img(:,:,3)==255)) = 4; %stroma
    mask_digit((img(:,:,1)==128 & img(:,:,2)==128 & img(:,:,3)==0)) = 5; %fat
    
    
    for j = 1:5
        temp(j) = length(find(mask_digit(:)==j));
    end
    if max(temp)>0
    temp_per = temp./sum(temp);
    gp_pix(i, 1:5) = temp;  %pix
    end
    
    
    tableTmp.ID(i) = wsi_ID;
    tableTmp.parenchyma(i) = gp_pix(i, 1);
    tableTmp.necrosis(i) = gp_pix(i, 2);
    tableTmp.tumor(i) = gp_pix(i, 3);
    tableTmp.stroma(i) = gp_pix(i, 4);
    tableTmp.fat(i) = gp_pix(i, 5);
       
        
end
writetable(tableTmp, '/Volumes/yuan_lab/TIER2/artemis_lei/discovery/TMEsegFT_div12_sCE_6class_img768_pen636/discovery_tme_pix.xlsx')