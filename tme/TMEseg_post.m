clear;
clc;
close all

src_path = 'R:\tracerx\tracerx421\erik_LUAD\result\TMEseg\stroma_mask_ss1';
cws_path = 'R:\tracerx\tracerx421\erik_LUAD\cws';
dst_path = 'R:\tracerx\tracerx421\erik_LUAD\result\stroma_mask_ss1_final';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(cws_path, '*.czi'));
for i=1: length(files)
    file_name = files(i).name;
if ~isfile(fullfile(dst_path, [file_name, '_post.png']))
ss1 =fullfile(cws_path, file_name, 'Ss1.jpg');
mask_ss1 = fullfile(src_path, [file_name, '_Ss1.png']);

mask_tme = segRefine(mask_ss1, ss1);

imwrite(mask_tme, fullfile(dst_path, [file_name, '_post.png']));
end
end
    