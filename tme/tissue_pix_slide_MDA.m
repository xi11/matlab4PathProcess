clear
clc
close all


% src_gp_mask = '/Users/xiaoxipan/Documents/project/anthracosis/NS_ss1x2_tissueBed_entireDCP10close27remove90000_bedOpen5remove90000';
% files = dir(fullfile(src_gp_mask, '*.png'));
% 
% tableTmp = table("",0,'VariableNames',{'ID','tissue8'});
% k = length(files);
% gp_pix = zeros(k, 1);
% for i = 1:k
%     file_name = files(i).name;
%     wsi_ID = extractBefore(file_name, '.svs_pgmn_tumorBed.png');
%    
%     img = double(imread(fullfile(src_gp_mask, file_name)));
%     img = im2gray(img);
%     area8 = length(find(img(:)>0));
%     if area8
%     gp_pix(i, 1) = area8;  
%     else
%         gp_pix(i, 1) = 0;
%     end
%     
%     
%     tableTmp.ID(i) = wsi_ID;
%     tableTmp.tissue8(i) = gp_pix(i, 1);
%         
% end
% writetable(tableTmp, '/Users/xiaoxipan/Documents/project/anthracosis/pix_TMEsegFOplaindiv12sCE/NS_tissue8.xlsx')




clear
clc
close all


airspace_mask = '/Volumes/yuan_lab/TIER2/anthracosis/prospect/tissue_seg_airspace_DCP15_fill1600/mask_ss1_x8';
tissue_mask = '/Volumes/yuan_lab/TIER2/anthracosis/prospect/tissue_ss1x8_entireDCP10close27remove90000';
files = dir(fullfile(airspace_mask, '*.png'));

tableTmp = table("",0, 0, 0,'VariableNames',{'ID','airspace_tissue8', 'tissue8', 'airspace_tissueRefine8'});
k = length(files);
gp_pix = zeros(k, 3);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '.svs_Ss1.png');
    img = imread(fullfile(airspace_mask, file_name));
    tissue = imread(fullfile(tissue_mask, [wsi_ID, '.svs_tissue.png']));
    img_refine = img(tissue);
    img = img(:,:,1);
    airspace_area8 = length(find(img(:) > 0));
    if airspace_area8
    gp_pix(i, 1) = airspace_area8; 
    gp_pix(i, 2) = sum(tissue(:));
    gp_pix(i, 3) = length(find(img_refine(:) >0));

    else
        gp_pix(i, 1:3) = 0;
    end
    
    
    tableTmp.ID(i) = wsi_ID;
    tableTmp.airspace_tissue8(i) = gp_pix(i, 1);
    tableTmp.tissue8(i) = gp_pix(i, 2);
    tableTmp.airspace_tissueRefine8(i) = gp_pix(i, 3);
        
end
writetable(tableTmp, '/Users/xiaoxipan/Documents/project/anthracosis/prospect_tissue_airspaceDCP15.xlsx')