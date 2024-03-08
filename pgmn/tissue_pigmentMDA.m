clear;
clc;
close all
%final-
src_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/1_cws_tiling';
ref_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/pgmn_TMEsegDiv12sCE/mask_ss1_x8';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/tissue_ss1x8_entireDCP10close27remove90000';


if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*.svs'));
for i =1: length(files)
    file_name = files(i).name;
    disp(file_name)
    %     file_name_new = extractBefore(file_name, '.jpg');
    if ~isfile(fullfile(dst_path, [file_name, '_tissue.png']))
        %if isfile(fullfile(src_path, file_name, 'Ss1.jpg'))
        mask_raw = imread(fullfile(src_path, file_name,  'Ss1.jpg'));
        mask_pgmn = imread(fullfile(ref_path, [file_name, '_Ss1.png']));
        [m, n, ~] = size(mask_pgmn);
        
        max_c = max(mask_raw, [],3);
        % mask_g = mask_raw(:,:,2);
        min_c = min(mask_raw, [], 3);
        mask_minus = max_c - min_c;

        
        mask_post = mask_minus;
        mask_post(mask_minus>10)=255; %reduce 20 to 10 will include more noises from background
        mask_post(mask_minus<=10)=0;
        %  mask_post(min_c<200 & min_c>=100)=255;
        %mask_post1 = imfill(mask_post, 'holes'); 
        
        %entire tissue
        se = strel('disk',27); % large value will incorparte small areas into the bulk, small value will bring more fragmented tissue, previous is 27
        mask_post = imclose(mask_post, se); %close opera is to connect small gaps
        mask_post1 = imfill(mask_post, 'holes'); 
        mask_tissue = bwareaopen(mask_post1, 90000);
        mask_tissue = imresize(mask_tissue, [m, n], 'nearest');
        
        imwrite(mask_tissue, fullfile(dst_path, [file_name, '_tissue.png']))
    end
end


