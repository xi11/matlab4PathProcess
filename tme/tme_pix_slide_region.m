clear
clc
close all


src_gp_mask = 'R:\tracerx\tracerx421\HE_region_specific\results\TMEseg\stroma_mask_ss1';

files = dir(fullfile(src_gp_mask, '*.png'));

tableTmp = table("",0,0,0,0,0,'VariableNames',{'ID', 'tumor', 'necrosis', 'inflam', 'reactive', 'inactive'});
k = length(files);
gp_pix = zeros(k, 5);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '.ndpi_Ss1.png');
   
    img = double(imread(fullfile(src_gp_mask, file_name)));
    temp = [];
    [m, n, ~] = size(img);
    mask_digit = zeros(m, n);
    mask_digit((img(:,:,1)==255 & img(:,:,2)==0 & img(:,:,3)==255)) = 2; %micropapillary
    mask_digit((img(:,:,1)==128 & img(:,:,2)==0 & img(:,:,3)==0)) = 3; %solid
    mask_digit((img(:,:,1)==255 & img(:,:,2)==255 & img(:,:,3)==0)) = 4; %papillary
    mask_digit((img(:,:,1)==255 & img(:,:,2)==0 & img(:,:,3)==0)) = 5; %acinar
    mask_digit((img(:,:,1)==0 & img(:,:,2)==0 & img(:,:,3)==255)) = 1; %lepidic
    
    for j = 1:5
        temp(j) = length(find(mask_digit(:)==j));
    end
    if max(temp)>0
    %temp_per = temp./sum(temp);
    gp_pix(i, 1:5) = temp;  %per
   
    end
    
    
    tableTmp.ID(i) = wsi_ID;
    tableTmp.tumor(i) = gp_pix(i, 3);
    tableTmp.necrosis(i) = gp_pix(i, 2);
    tableTmp.inflam(i) = gp_pix(i, 5);
    tableTmp.reactive(i) = gp_pix(i, 4);
    tableTmp.inactive(i) = gp_pix(i, 1);
   
end
writetable(tableTmp, 'R:\tracerx\tracerx421\HE_region_specific\results\TMEseg\tx_region1824_TMEmatlabSs1.xlsx')