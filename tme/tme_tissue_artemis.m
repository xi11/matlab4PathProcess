clear;
clc;
close all
%final-
src_path = '/Volumes/yuan_lab/TIER2/artemis_lei/discovery/til/1_cws_tiling';
ref_path = '/Volumes/yuan_lab/TIER2/artemis_lei/discovery/tmeseg_artemisTCGA_finetune20xPen_K8div12v2/mask_ss1';
dst_path1 = '/Volumes/yuan_lab/TIER2/artemis_lei/discovery/tissue_seg';
dst_path2 = '/Volumes/yuan_lab/TIER2/artemis_lei/discovery/tme_tissue';

if ~exist(dst_path1, 'dir')
    mkdir(dst_path1)
end

if ~exist(dst_path2, 'dir')
    mkdir(dst_path2)
end


files = dir(fullfile(src_path, '*.svs'));
for i =1: length(files)
    file_name = files(i).name;
    disp(file_name)
    %     file_name_new = extractBefore(file_name, '.jpg');
    if ~isfile(fullfile(dst_path1, [file_name, '_tissue.png']))
        
        mask_raw = imread(fullfile(src_path, file_name,  'Ss1.jpg'));
        mask_tme = imread(fullfile(ref_path, [file_name, '_Ss1.png']));
        [m, n, ~] = size(mask_tme);
        
        max_c = max(mask_raw, [],3);
        min_c = min(mask_raw, [], 3);
        mask_minus = max_c - min_c;

        
        mask_post = mask_minus;
        mask_post(mask_minus>10)=255; %reduce 20 to 10 will include more noises from background
        mask_post(mask_minus<=10)=0;
   
        
        %entire tissue
        se = strel('disk',21); % large value will incorparte small areas into the bulk, small value will bring more fragmented tissue, previous is 27
        mask_post = imclose(mask_post, se); %close opera is to connect small gaps
        mask_post1 = imfill(mask_post, 'holes'); 
        mask_tissue = bwareaopen(mask_post1, 900);
        mask_tissue = imresize(mask_tissue, [m, n], 'nearest');
        mask_tme = mask_tme.*uint8(mask_tissue);
        
        imwrite(mask_tissue, fullfile(dst_path1, [file_name, '_tissue.png']))
        imwrite(mask_tme, fullfile(dst_path2, [file_name, '_Ss1.png']))
    end
end


