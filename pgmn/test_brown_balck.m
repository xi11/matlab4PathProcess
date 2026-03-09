clear
clc
close all

src_path = '/Volumes/yuan_lab/TIER2/melanoma_vp/pilot1_Mar2025/1_cws_tiling/0CFCOT_164405.svs';

files = dir(fullfile(src_path, 'Da10*.jpg'));

k = length(files);

for i = 1:k
    file_name = files(i).name;

    img= imread(fullfile(src_path, file_name));

    img(:,:,1) = img(:,:,3);
    %img(:,:,2) = img(:,:,2)*0.9;
    
    figure;
    imshow(img)
end

