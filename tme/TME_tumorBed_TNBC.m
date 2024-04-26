
clear;
clc;
close all
%final
src_path = '/Volumes/xpan7-1/project/tcga_tnbc/mit-b3-finetuned-tmeTCGAbrca-e60-lr00001-s512-20x768/mask_ss1512';
dst_path = '/Volumes/xpan7-1/project/tcga_tnbc/mit-b3-finetuned-tmeTCGAbrca-e60-lr00001-s512-20x768/mask_ss1512_post_tumor21_90000';


if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*.png'));
for i =1:length(files)
    file_name = files(i).name;
    disp(file_name)
    file_name_new = extractBefore(file_name, '_Ss1.png');
    if ~isfile(fullfile(dst_path, [file_name, '_tme_tumorBed.png']))
        %if isfile(fullfile(src_path, file_name, 'Ss1.jpg'))
        mask_tme = imread(fullfile(src_path, file_name));
        [m, n, ~] = size(mask_tme);
        mask_tumor = zeros(m, n);
        mask_tumor(mask_tme(:,:,1)==128 & mask_tme(:,:,2)==0 &mask_tme(:,:,3)==0) = 255;
        %mask_tumor(mask_tme(:,:,1)==255 & mask_tme(:,:,2)==0 &mask_tme(:,:,3)==0) = 255;
        %mask_tumor(mask_tme(:,:,1)==255 & mask_tme(:,:,2)==0 &mask_tme(:,:,3)==255) = 255;

        mask_tumor = imfill(mask_tumor, 'holes');
        se1 = strel('disk', 21);  %to set
        mask_tumor = imclose(mask_tumor, se1);
        mask_tumor = imfill(mask_tumor, 'holes');

        cc = bwconncomp(mask_tumor);
        stats = regionprops(cc,'Area');
        idx = find([stats.Area] >= 90000);
        BW2 = ismember(labelmatrix(cc),idx);

        mask_final = uint8(BW2).*mask_tme(1:m, 1:n,:);
        imwrite(mask_final, fullfile(dst_path, [file_name, '_tme_tumorBed.png']))
    end
end


