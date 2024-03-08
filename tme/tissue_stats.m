clear;
clc;
close all

src_path = '/Volumes/xpan7-1/tmeseg/patch768_tcga20All/maskPng';
files = dir(fullfile(src_path, "*.png"));
tme_pix = zeros(length(files), 8);
for i = 1: length(files)
    file_name = files(i).name;
    img = imread(fullfile(src_path, file_name));
    for j = 0:7
        tme_pix(i, j+1) = length(find(img==j));
    end
    
end