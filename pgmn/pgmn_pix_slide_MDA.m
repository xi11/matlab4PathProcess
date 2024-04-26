clear
clc
close all


src_gp_mask = '/Volumes/yuan_lab/public_data/TCGA_luad/pigment/pgmn_TMEsegDiv12sCE/mask_ss1_x8_notTMEerode51';
files = dir(fullfile(src_gp_mask, '*.png'));

tableTmp = table("",0,'VariableNames',{'ID','pigment8'});
k = length(files);
gp_pix = zeros(k, 1);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '.svs_Ss1.png');
   
    img = double(imread(fullfile(src_gp_mask, file_name)));
    img = img(:,:,1);
    area8 = length(find(img(:)>0));
    if area8
    gp_pix(i, 1) = area8;  
    else
        gp_pix(i, 1) = 0;
    end
    
    
    tableTmp.ID(i) = wsi_ID;
    tableTmp.pigment8(i) = gp_pix(i, 1);
        
end
writetable(tableTmp, '/Users/xiaoxipan/Documents/project/anthracosis/pix_TMEsegFOplaindiv12sCE/tcga-luad_pigment8_notTMEerode51.xlsx')