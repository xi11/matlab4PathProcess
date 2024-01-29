clear;
clc;
close all

src_path = '/Users/xiaoxipan/Documents/project/artemis/annotation/patch768/patch768_Dec8/patch768mask';
dst_path = '/Users/xiaoxipan/Documents/project/artemis/annotation/patch768/patch768_Dec8/patch768digital';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*.png'));
for i =1:length(files)
    file_name = files(i).name;
    disp(file_name)
    mask = imread(fullfile(src_path, file_name));
    imwrite(mask, fullfile(dst_path, file_name));
end