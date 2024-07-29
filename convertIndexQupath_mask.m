clear;
clc;
close all

src_path = '/Users/xiaoxipan/Documents/project/public_data/bcss/luad_annotation_xp/patch512_mpp44muscle/hardcrop';
dst_path = '/Users/xiaoxipan/Documents/project/public_data/bcss/luad_annotation_xp/patch512_mpp44muscle/hardcrop';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*-labelled.png'));
for i =1:length(files)
    file_name = files(i).name;
    disp(file_name)
    mask = imread(fullfile(src_path, file_name));
    %%mask(mask==5) = 10; %update muscle class to 10
    %mask(mask==5) = 8;
    %mask(mask==6) = 9;
    imwrite(mask, fullfile(dst_path, ['mask_',file_name(1:end-13), '.png']));
end


%color code for tcga-luad annotaed by xp in June to resolve macrophage
%issue
%0	    0	0  background: 0
%0.5	0	0  tumor: 1
%1	    1	0  stroma:2
%1	    0	0  inflam:3
%1	    0	1  necrosis: 4
%0.5   0.5  0 fat: 5
%0      1   1  normalepithelial:6
%0	    0	1   vessel:7
%0.5	0	0.5 macrophage: 8
%0	    0.5	0   alveoli: 9
%0      0   0.5 muscle: 10