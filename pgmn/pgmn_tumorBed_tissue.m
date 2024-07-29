clear;
clc;
close all
%final, image processing to filter out pgmn outside tissue
src_path = '/Volumes/yuan_lab/public_data/TCGA_luad/til/1_cws_tiling';
ref_path = '/Volumes/yuan_lab/public_data/TCGA_luad/pigment/pgmn_TMEsegDiv12sCE/mask_ss1_x8';
pgmn_refine = '/Volumes/yuan_lab/public_data/TCGA_luad/pigment/pgmn_TMEsegDiv12sCE/mask_ss1_x8_notTMEerode51';
dst_path = '/Volumes/yuan_lab/public_data/TCGA_luad/pigment/ss1x8_tissueBed_entireDCP10close27remove90000_bedDCP20Open5remove90000_erode51';


if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

if ~exist(pgmn_refine, 'dir')
    mkdir(pgmn_refine)
end

files = dir(fullfile(src_path, '*.svs'));
for i =1:length(files)
    file_name = files(i).name;
    disp(file_name)
    %     file_name_new = extractBefore(file_name, '.jpg');
    if ~isfile(fullfile(dst_path, [file_name, '_tissue_tumorBed.png']))
        %if isfile(fullfile(src_path, file_name, 'Ss1.jpg'))
        mask_raw = imread(fullfile(src_path, file_name,  'Ss1.jpg'));
        mask_pgmn = imread(fullfile(ref_path, [file_name, '_Ss1.png']));
        [m, n, ~] = size(mask_pgmn);
        
        max_c = max(mask_raw, [],3);
        % mask_g = mask_raw(:,:,2);
        min_c = min(mask_raw, [], 3);
        mask_minus = max_c - min_c;

        %entire tissue
        mask_post = mask_minus;
        mask_post(mask_minus>10)=255; %reduce 20 to 10 will include more noises from background
        mask_post(mask_minus<=10)=0;
        %  mask_post(min_c<200 & min_c>=100)=255;
        
        se = strel('disk',27);
        mask_post1 = imclose(mask_post, se); %close opera is to connect small gaps
        mask_post1 = imfill(mask_post1, 'holes'); %only, ss1_mask_fill_3
        mask_tissue = bwareaopen(mask_post1, 90000);
        mask_tissue = imresize(mask_tissue, [m, n], 'nearest');
        
        se3 = strel('disk',51);  %to set
        mask_tissue  = imerode(mask_tissue , se3);
        mask_pgmn_re = mask_pgmn .*uint8(mask_tissue);
        imwrite(mask_pgmn_re, fullfile(pgmn_refine, [file_name, '_Ss1.png']))
        
        %tumor bed
        mask_post2 = mask_minus;
        mask_post2(mask_minus>20)=255;
        mask_post2(mask_minus<=20)=0;
        
        se1 = strel('disk',5);  %to set
        mask_post2 = imopen(mask_post2, se1);
        mask_post2 = imfill(mask_post2, 'holes');
        % figure;
        % imshow(mask_post2)
        cc = bwconncomp(mask_post2);
        stats = regionprops(cc,'Area');
        idx = find([stats.Area] >= 90000);
        BW2 = ismember(labelmatrix(cc),idx);
        BW2 = imresize(BW2, [m, n], 'nearest');

        
        
        mask_tissue1 = 128*uint8(mask_tissue);
        mask_tissue2 = 0*uint8(mask_tissue);
        mask_tissue3 = 128*uint8(mask_tissue);
        mask_tissue1(BW2) = 255;
        mask_tissue3(BW2) = 0;
        mask_final = cat(3,mask_tissue1, mask_tissue2, mask_tissue3);
       
        %mask_pgmn = mask_pgmn(:,:,1);
        %mask_pgmn = logical(mask_pgmn).*mask_tissue;
        %mask_final(repmat(logical(mask_pgmn), [1, 1, 3])) = 255;
        
        imwrite(mask_final, fullfile(dst_path, [file_name, '_tissue_tumorBed.png']))
    end
end


