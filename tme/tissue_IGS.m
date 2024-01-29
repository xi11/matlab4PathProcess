clear;
clc;
close all

%%%tissue masks for IGS
src_path = 'R:\tracerx\tracerx421\erik_LUAD\cws';
dst_path = 'R:\tracerx\tracerx421\erik_LUAD\result\TMEseg\IGS_tissue_mask_DCP20_close11_remove90000';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end
    
files = dir(fullfile(src_path, '*.czi'));
for i =1:length(files)
    file_name = files(i).name;
if ~isfile(fullfile(dst_path, [file_name, '_tissue.png']))
mask_raw = imread(fullfile(src_path, file_name, 'Ss1.jpg'));

max_c = max(mask_raw, [],3);
min_c = min(mask_raw, [], 3);
mask_minus = max_c - min_c;

mask_minus(mask_minus>20)=255;
mask_minus(mask_minus<=20)=0;


mask_post = mask_minus;
se = strel('disk',11);
mask_post1 = imclose(mask_post, se);
mask_post1 = imfill(mask_post1, 'holes'); %only, ss1_mask_fill_3
mask_tissue = bwareaopen(mask_post1, 90000);


imwrite(255*uint8(mask_tissue), fullfile(dst_path, [file_name, '_tissue.png']))
end
end


