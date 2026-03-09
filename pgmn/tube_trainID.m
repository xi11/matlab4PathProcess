clear
clc
close all


src_gp_mask = '/Volumes/yuan_lab/TIER2/anthracosis/tcga-lusc/tbed_annotation4train_issueMulti/ss1_images_match';

files = dir(fullfile(src_gp_mask, '*.jpg'));

tableTmp = table("",'VariableNames',{'ID'});
k = length(files);

for i = 1:k
    file_name = files(i).name;
    wsi_ID = extractBefore(file_name, '_Ss1.jpg');

    tableTmp.ID(i) = wsi_ID;
        
end

writetable(tableTmp, '/Volumes/yuan_lab/TIER2/anthracosis/tcga-lusc/tbed_annotation4train_issueMulti/luscID_old.xlsx')