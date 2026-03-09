clear;
clc;
close all

src_path = '/Volumes/xpan7/tmesegK8/patch512artemis/maskPng_discovery';
files = dir(fullfile(src_path, "*.png"));
tme_pix = zeros(length(files), 6);
for i = 1: length(files)
    file_name = files(i).name;
    img = imread(fullfile(src_path, file_name));
    for j = 0:5
        tme_pix(i, j+1) = length(find(img==j));
    end
    
end
sum(tme_pix)