clear;
clc;
close all


% src_path = '/Volumes/yuan_lab/TIER2/anthracosis/prospect/1_cws_tiling/815996_AN001-G3L.svs/Ss1.jpg';
% he = imread(src_path);
% lab_he = rgb2lab(he);
% ab = lab_he(:,:,2:3);
% ab = im2single(ab);
% numColors = 3;
% L2 = imsegkmeans(ab,numColors);
% 
% L2(L2 == L2(1,1)) = 0;
% L2(L2 ~= L2(1,1)) = 255;
% figure;
% imshow(L2)



src_path = '/Volumes/yuan_lab/TIER2/anthracosis/prospect/1_cws_tiling';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/prospect/tissue_seg_airspace_ss1_kmeans';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*.svs'));
for i =1:length(files)
    file_name = files(i).name;


    ss1 = fullfile(src_path, file_name, 'Ss1.jpg');

    if ~isfile(fullfile(dst_path,[file_name, '_tissue_airspace.png']))
        he = imread(ss1);
        lab_he = rgb2lab(he);
        ab = lab_he(:,:,2:3);
        ab = im2single(ab);
        numColors = 3;
        L2 = imsegkmeans(ab,numColors);

        L2(L2 == L2(1,1)) = 0;
        L2(L2 ~= L2(1,1)) = 255;
        imwrite(L2, fullfile(dst_path,[file_name, '_tissue_airspace.png']))
    end

end