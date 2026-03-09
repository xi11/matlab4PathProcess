clear
clc
close all


src_gp_mask = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/AIgrading/mask_ss1_final';

files = dir(fullfile(src_gp_mask, '*.png'));

tableTmp = table("",0,0,0,0,0,0,'VariableNames',{'ID',...
    'cri_pix', 'mic_pix', 'sol_pix', 'pap_pix', 'aci_pix', 'lep_pix'});
k = length(files);
gp_pix = zeros(k, 6);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '.svs_Ss1.png');
   
    img = double(imread(fullfile(src_gp_mask, file_name)));
    temp = [];
    [m, n, ~] = size(img);
    mask_digit = zeros(m, n);
    mask_digit((img(:,:,1)==0 & img(:,:,2)==255 & img(:,:,3)==0)) = 1; %cri
    mask_digit((img(:,:,1)==255 & img(:,:,2)==0 & img(:,:,3)==255)) = 2; %mic
    mask_digit((img(:,:,1)==128 & img(:,:,2)==0 & img(:,:,3)==0)) = 3; %sol
    mask_digit((img(:,:,1)==255 & img(:,:,2)==255 & img(:,:,3)==0)) = 4; %pap
    mask_digit((img(:,:,1)==255 & img(:,:,2)==0 & img(:,:,3)==0)) = 5; %aci
    mask_digit((img(:,:,1)==0 & img(:,:,2)==0 & img(:,:,3)==255)) = 6; %lep

    
    for j = 1:6
        temp(j) = length(find(mask_digit(:)==j));
    end
    if max(temp)>0
    
    gp_pix(i, 1:6) = temp;  %pix
   
    end
    
    
    tableTmp.ID(i) = wsi_ID;
    tableTmp.cri_pix(i) = gp_pix(i, 1);
    tableTmp.mic_pix(i) = gp_pix(i, 2);
    tableTmp.sol_pix(i) = gp_pix(i, 3);
    tableTmp.pap_pix(i) = gp_pix(i, 4);
    tableTmp.aci_pix(i) = gp_pix(i, 5);
    tableTmp.lep_pix(i) = gp_pix(i, 6);
 
%           
end

writetable(tableTmp, '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/AIgrading/GP_pix_x16.xlsx')