clear;
clc;
close all
%final
src_path = '/Volumes/yuan_lab/TIER2/mpr_frank/mpr2949/til/1_cws_tiling';
ref_path = '/Volumes/yuan_lab/TIER2/mpr_frank/mpr2949/mit-b3-finetuned-tmeTCGAbrcaLUAD-e60-lr00001-s512-20x768-10x512rere/mask_ss1768';
dst_path = '/Volumes/yuan_lab/TIER2/mpr_frank/mpr2949/mit-b3-finetuned-tmeTCGAbrcaLUAD-e60-lr00001-s512-20x768-10x512rere/mask_ss1768_final';


if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*.svs'));
for i =1:length(files)
    file_name = files(i).name;
    disp(file_name)
    %     file_name_new = extractBefore(file_name, '.jpg');
    if ~isfile(fullfile(dst_path, [file_name, '_tissue.png']))
        %if isfile(fullfile(src_path, file_name, 'Ss1.jpg'))
        mask_raw = imread(fullfile(src_path, file_name,  'Ss1.jpg'));
        mask_tme = imread(fullfile(ref_path, [file_name, '_Ss1.png']));
        [m, n, ~] = size(mask_tme);
        
        max_c = max(mask_raw, [],3);
        % mask_g = mask_raw(:,:,2);
        min_c = min(mask_raw, [], 3);
        mask_minus = max_c - min_c;

%         %entire tissue
%         mask_post = mask_minus;
%         mask_post(mask_minus>10)=255; %reduce 20 to 10 will include more noises from background
%         mask_post(mask_minus<=10)=0;
%         %  mask_post(min_c<200 & min_c>=100)=255;
%         
%         se = strel('disk',27);
%         mask_post1 = imclose(mask_post, se); %close opera is to connect small gaps
%         mask_post1 = imfill(mask_post1, 'holes'); %only, ss1_mask_fill_3
%         mask_tissue = bwareaopen(mask_post1, 90000);
%         mask_tissue = imresize(mask_tissue, [m, n], 'nearest');
        
        %tumor bed
        mask_post2 = mask_minus;
        mask_post2(mask_minus>20)=255;
        mask_post2(mask_minus<=20)=0;
        
        se1 = strel('disk',5);  %to set
        mask_post2 = imopen(mask_post2, se1);
        mask_post2 = imfill(mask_post2, 'holes');
        cc = bwconncomp(mask_post2);
        stats = regionprops(cc,'Area');
        idx = find([stats.Area] >= 90000);
        BW2 = ismember(labelmatrix(cc),idx);
        BW2 = imresize(BW2, [m, n], 'nearest');
        
        mask_final = mask_tme.*uint8(BW2);
       
        
        imwrite(mask_final, fullfile(dst_path, [file_name, '_tumorBed.png']))
    end
end


