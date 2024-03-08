clear;
clc;
close all
%to multiply tile tissue mask with tile pigment


src_path = '/Users/xiaoxipan/Documents/Anthracosis/pilot16/tile_tissue_post';
pigment_path = '/Users/xiaoxipan/Documents/Anthracosis/pilot16/DCP30minC70_dilate1_remove64_pen100000_line98_ratio98';
cws_path = '/Volumes/plm5/TMP-IL/0_TMP-IL Projects/001TMP_IL Digital Pathology Group/Anthracosis project/cws_tiles';
dst_path1 = '/Users/xiaoxipan/Documents/Anthracosis/pilot16/post_DCP30minC50_dilate1_remove100_pen100000_line98_ratio98';
dst_path2 = '/Users/xiaoxipan/Documents/Anthracosis/pilot16/HE_DCP30minC50_dilate1_remove100_pen100000_line98_ratio98';

if ~exist(dst_path1, 'dir')
    mkdir(dst_path1)
end

if ~exist(dst_path2, 'dir')
    mkdir(dst_path2)
end
    
files = dir(fullfile(src_path, '*.svs'));
for i =1:length(files)
    file_name = files(i).name;
    tile_HE_path = fullfile(dst_path2, file_name);
    if ~exist(tile_HE_path, 'dir')
    mkdir(tile_HE_path)
    end
    
    tile_pigment_path = fullfile(dst_path1, file_name);
    if ~exist(tile_pigment_path, 'dir')
    mkdir(tile_pigment_path)
    end
    
    Da_files = dir(fullfile(src_path, file_name, 'Da*'));
    for j = 1:length(Da_files)
        Da_name = Da_files(j).name;
        tile_tissue = imread(fullfile(src_path, file_name, Da_name));
        Da_ID = extractBefore(Da_name, '.png');
        tile_pigment = imread(fullfile(pigment_path, file_name, Da_name));
       
        tile_tissue(tile_tissue>0)=1;
        [m, n] = size(tile_tissue);
        tile_pigment_post = tile_pigment(1:m, 1:n).*tile_tissue;
        tile_pigment_post = logical(tile_pigment_post);
        tile_pigment_post = bwareaopen(tile_pigment_post, 100);
        tile_pigment_post = imfill(tile_pigment_post, 'holes');
        imwrite(tile_pigment_post, fullfile(tile_pigment_path, Da_name));
        
        tile_cws = imread(fullfile(cws_path, file_name, [Da_ID, '.jpg']));
        tile_edge = edge(tile_pigment_post);
        
        tile_cws_r = tile_cws(:,:,1);
        tile_cws_g = tile_cws(:,:,2);
        tile_cws_b = tile_cws(:,:,3);
        
       tile_cws_r(tile_edge) = 0;
       tile_cws_g(tile_edge) = 255;
       tile_cws_b(tile_edge) = 255;
       
       tile_cws_new = cat(3, tile_cws_r, tile_cws_g, tile_cws_b);
       imwrite(tile_cws_new, fullfile(tile_HE_path, Da_name));
       
    
     
       
    end
end


