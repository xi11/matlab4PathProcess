
clear;
clc;
close all

% not use eventually
src_path = '/Volumes/yuan_lab/TIER2/anthracosis/LNmodel/CAMELYON16/mit-b3-finetuned-TCGAbcssWsss10xLuadMacroMuscle-40x896-20x512-10x256re/train_ss1mask';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/LNmodel/CAMELYON16/train_mask_tme_remove40000_close5_fill';


if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*.png'));
for i =1:length(files)
    file_name = files(i).name;
    disp(file_name)
    file_name_new = extractBefore(file_name, '_Ss1.png');
    if ~isfile(fullfile(dst_path, [file_name(1: end-12), '_LN.png']))
        %if isfile(fullfile(src_path, file_name, 'Ss1.jpg'))
        mask_tme = imread(fullfile(src_path, file_name));
        [m, n, ~] = size(mask_tme);
        mask_tumor = zeros(m, n);
        mask_tumor(mask_tme(:,:,1)==128 & mask_tme(:,:,2)==0 &mask_tme(:,:,3)==0) = 255;
        mask_tumor(mask_tme(:,:,1)==255 & mask_tme(:,:,2)==0 &mask_tme(:,:,3)==0) = 255;

        %open operation to remove noise and disconnects small objects
        %se1 = strel('disk', 5);  %to set
        %mask_LN1 = imclose(mask_tumor, se1);

        cc = bwconncomp(mask_tumor);
        stats = regionprops(cc,'Area');
        idx = find([stats.Area] >= 40000);
        BW2 = ismember(labelmatrix(cc),idx);
        
        %close operation to Fills holes, connects broken structures, preserves larger objects
        mask_LN2 = imfill(BW2, 'holes');
        se1 = strel('disk', 5);  %to set
        mask_LN2 = imclose(mask_LN2, se1);
        mask_LN2 = imfill(mask_LN2, 'holes');

        

        mask_final = 255*uint8(mask_LN2);
        imwrite(mask_final, fullfile(dst_path, [file_name(1: end-12), '_LN.png']))
    end
end


