clear
clc
close all


%src_gp_mask = 'D:\TCGA_BRCA_part\stroma\mask_ss1_update1_DCP20_21max_5_5_final';
src_gp_mask = '/Volumes/xpan7/project/tcga_tnbc/tmeseg_tcga20x384finetune/mask_ss1_post_tumor21_90000';
files = dir(fullfile(src_gp_mask, '*.png'));

tableTmp = table("",0,0,0,0,0,0,0,'VariableNames',{'ID',...
    'tumor_per', 'necrosis_per', 'stroma_per', 'fat_per', 'inflam_per', 'stroma2tumor', 'tissue'});
k = length(files);
gp_pix = zeros(k, 7);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '_Ss1.png');
   
    img = double(imread(fullfile(src_gp_mask, file_name)));
    temp = [];
    [m, n, ~] = size(img);
    mask_digit = zeros(m, n);
    mask_digit((img(:,:,1)==255 & img(:,:,2)==0 & img(:,:,3)==0)) = 1; %inflam
    mask_digit((img(:,:,1)==255 & img(:,:,2)==0 & img(:,:,3)==255)) = 2; %necrosis
    mask_digit((img(:,:,1)==128 & img(:,:,2)==0 & img(:,:,3)==0)) = 3; %tumor
    mask_digit((img(:,:,1)==255 & img(:,:,2)==255 & img(:,:,3)==0)) = 4; %stroma
    mask_digit((img(:,:,1)==128 & img(:,:,2)==128 & img(:,:,3)==0)) = 5; %fat
    
    
    for j = 1:5
        temp(j) = length(find(mask_digit(:)==j));
    end
    if max(temp)>0
    temp_per = temp./sum(temp);
    gp_pix(i, 1:5) = temp_per;  %per
   
    %gp_pix(i, 6) = temp(4)/(temp(1)+temp(4)+eps);
    gp_pix(i, 6) = temp(4)/(temp(3)+eps);
    gp_pix(i, 7) = sum(temp);
    %gp_pix(i, 8) = temp(1)/temp(3);
    end
    
    
    tableTmp.ID(i) = wsi_ID;
    tableTmp.tumor_per(i) = gp_pix(i, 3);
    tableTmp.necrosis_per(i) = gp_pix(i, 2);
    tableTmp.stroma_per(i) = gp_pix(i, 4);
    tableTmp.fat_per(i) = gp_pix(i, 5);
    tableTmp.inflam_per(i) = gp_pix(i, 1);
    tableTmp.stroma2tumor(i) = gp_pix(i, 6);
    tableTmp.tissue(i) = gp_pix(i, 7);

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
writetable(tableTmp, '/Volumes/xpan7/project/tcga_tnbc/tmeseg_tcga20x384finetune/TCGA_BRCA118_tmeTCGAfine384_tumor21_90000.xlsx')


