clear;
clc;
close all

src_path = '/Volumes/xpan7/project/tcga_tnbc/tmeseg_artemis/mask_ss1';
cws_path = '/Volumes/xpan7/project/tcga_tnbc/til/1_cws_tiling';
dst_path = '/Volumes/xpan7/project/tcga_tnbc/tmeseg_artemis/mask_ss1_final_matlab';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(cws_path, '*.svs'));
for i=113: length(files)
    file_name = files(i).name;
if ~isfile(fullfile(dst_path, [file_name, '_post.png']))
ss1 =fullfile(cws_path, file_name, 'Ss1.jpg');
mask_ss1 = fullfile(src_path, [file_name, '_Ss1.png']);

mask_tme = segRefine(mask_ss1, ss1);

imwrite(mask_tme, fullfile(dst_path, [file_name, '_post.png']));
end
end
    