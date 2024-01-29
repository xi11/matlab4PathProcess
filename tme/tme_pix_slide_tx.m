clear
clc
close all


src_gp_mask = '/Volumes/yuan_lab/TIER2/mpr_frank/mpr2582/tmeseg/stroma_mask_ss1_final';

files = dir(fullfile(src_gp_mask, '*.png'));

tableTmp = table("",0,0,0,0,0,0,0,0,0,0,0,0,0,'VariableNames',{'ID',...
    'tumor', 'necrosis', 'inflam', 'reactive', 'inactive','tumor_per', 'necrosis_per', 'inflam_per', 'reactive_per','inactive_per', 'reactive2stroma', 'reactive2tumor', 'inactive2tumor'});
k = length(files);
gp_pix = zeros(k, 8);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '.svs_post.png');
   
    img = double(imread(fullfile(src_gp_mask, file_name)));
    temp = [];
    [m, n, ~] = size(img);
    mask_digit = zeros(m, n);
    mask_digit((img(:,:,1)==255 & img(:,:,2)==0 & img(:,:,3)==255)) = 2; %necrosis
    mask_digit((img(:,:,1)==128 & img(:,:,2)==0 & img(:,:,3)==0)) = 3; %tumor
    mask_digit((img(:,:,1)==255 & img(:,:,2)==255 & img(:,:,3)==0)) = 4; %reactive
    mask_digit((img(:,:,1)==255 & img(:,:,2)==0 & img(:,:,3)==0)) = 5; %inflam
    mask_digit((img(:,:,1)==0 & img(:,:,2)==0 & img(:,:,3)==255)) = 1; %inactive
    
    for j = 1:5
        temp(j) = length(find(mask_digit(:)==j));
    end
    if max(temp)>0
    temp_per = temp./sum(temp);
    gp_pix(i, 1:5) = temp;  %per
   
    gp_pix(i, 6) = temp(4)/(temp(1)+temp(4)+eps);
    gp_pix(i, 7) = temp(4)/temp(3);
    gp_pix(i, 8) = temp(1)/temp(3);
    end
    
    
    tableTmp.ID(i) = wsi_ID;
    tableTmp.tumor(i) = gp_pix(i, 3);
    tableTmp.necrosis(i) = gp_pix(i, 2);
    tableTmp.inflam(i) = gp_pix(i, 5);
    tableTmp.reactive(i) = gp_pix(i, 4);
    tableTmp.inactive(i) = gp_pix(i, 1);
    tableTmp.tumor_per(i) = temp_per(3);
    tableTmp.necrosis_per(i) = temp_per(2);
    tableTmp.inflam_per(i) = temp_per(5);
    tableTmp.reactive_per(i) = temp_per(4);
    tableTmp.inactive_per(i) = temp_per(1);
    tableTmp.reactive2stroma(i) = gp_pix(i, 6);
    tableTmp.reactive2tumor(i) = gp_pix(i, 7);
    tableTmp.inactive2tumor(i) = gp_pix(i, 8);
        
end
writetable(tableTmp, '/Volumes/yuan_lab/TIER2/mpr_frank/mpr2582/tmeseg/score/mpr_2582.xlsx')