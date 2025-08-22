clear
clc
close all


src_gp_mask = '/Volumes/yuan_lab/TIER2/anthracosis/LungAdenocarcinomaEvolutionHE_PingMP/USA/pgmn_RegionROIs';
files = dir(fullfile(src_gp_mask, '*.png'));

tableTmp = table("",0,'VariableNames',{'ID','pigment8'});
k = length(files);
gp_pix = zeros(k, 1);
for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '.png');
   
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
writetable(tableTmp, '/Volumes/yuan_lab/TIER2/anthracosis/LungAdenocarcinomaEvolutionHE_PingMP/USA/rawRes_pigment.xlsx')