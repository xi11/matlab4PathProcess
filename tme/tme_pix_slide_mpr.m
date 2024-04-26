clear
clc
close all


src_gp_mask = '/Volumes/yuan_lab/TIER2/mpr_frank/mpr2949/mit-b3-finetuned-tmeTCGAbrcaLUAD-e60-lr00001-s512-20x768-10x512rere/mask_ss1768_final';

files = dir(fullfile(src_gp_mask, '*.png'));

tableTmp = table("",0,0,0,0,0,0,0,0,'VariableNames',{'ID',...
    'tumor_pix', 'necrosis_pix', 'stroma_pix', 'fat_pix', 'inflam_pix', 'parenchyma_pix', 'blood_pix', 'alveolar_pix'});
k = length(files);
gp_pix = zeros(k, 8);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '_tumorBed.png');
   
    img = double(imread(fullfile(src_gp_mask, file_name)));
    temp = [];
    [m, n, ~] = size(img);
    mask_digit = zeros(m, n);
    mask_digit((img(:,:,1)==255 & img(:,:,2)==0 & img(:,:,3)==0)) = 1; %inflam
    mask_digit((img(:,:,1)==255 & img(:,:,2)==0 & img(:,:,3)==255)) = 2; %necrosis
    mask_digit((img(:,:,1)==128 & img(:,:,2)==0 & img(:,:,3)==0)) = 3; %tumor
    mask_digit((img(:,:,1)==255 & img(:,:,2)==255 & img(:,:,3)==0)) = 4; %stroma
    mask_digit((img(:,:,1)==128 & img(:,:,2)==128 & img(:,:,3)==0)) = 5; %fat
    mask_digit((img(:,:,1)==0 & img(:,:,2)==255 & img(:,:,3)==255)) = 6; %parenchyma
    mask_digit((img(:,:,1)==0 & img(:,:,2)==0 & img(:,:,3)==255)) = 7; %blood
    mask_digit((img(:,:,1)==0 & img(:,:,2)==128 & img(:,:,3)==0)) = 8; %blood

    
    for j = 1:8
        temp(j) = length(find(mask_digit(:)==j));
    end
    if max(temp)>0
    
    gp_pix(i, 1:8) = temp;  %pix
   
    end
    
    
    tableTmp.ID(i) = wsi_ID;
    tableTmp.tumor_pix(i) = gp_pix(i, 3);
    tableTmp.necrosis_pix(i) = gp_pix(i, 2);
    tableTmp.stroma_pix(i) = gp_pix(i, 4);
    tableTmp.fat_pix(i) = gp_pix(i, 5);
    tableTmp.inflam_pix(i) = gp_pix(i, 1);
    tableTmp.parenchyma_pix(i) = gp_pix(i, 6);
    tableTmp.blood_pix(i) = gp_pix(i, 7);
    tableTmp.alveolar_pix(i) = gp_pix(i, 8);
 

%     tableTmp.tumor_per(i) = gp_pix(i, 3);
%     tableTmp.necrosis_per(i) = gp_pix(i, 2);
%     tableTmp.inflam_per(i) = gp_pix(i, 5);
%     tableTmp.reactive_per(i) = gp_pix(i, 4);
%     tableTmp.inactive_per(i) = gp_pix(i, 1);
%     tableTmp.reactive2stroma(i) = gp_pix(i, 6);
%     tableTmp.reactive2tumor(i) = gp_pix(i, 7);
%     tableTmp.inactive2tumor(i) = gp_pix(i, 8);
%           
end

writetable(tableTmp, '/Volumes/yuan_lab/TIER2/mpr_frank/mpr2949/mit-b3-finetuned-tmeTCGAbrcaLUAD-e60-lr00001-s512-20x768-10x512rere/mpr2949_segformer768_tbed.xlsx')