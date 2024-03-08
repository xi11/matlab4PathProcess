clear;
clc;
close all
%final version

src_path = '/Volumes/yuan_lab/TIER2/anthracosis/pigment_v2/mask_ss1_8_v2'; %stiched images, generated from python
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/pigment_v2/mask_ss1_8_v2_post';
%dst_path1 = 'R:\tracerx\tracerx421\HE_diagnostic_LUAD\result\pigment_v2\ss1_tissue_entireDCP20close27remove1000_post';
tissue_path = '/Volumes/yuan_lab/TIER2/anthracosis/pigment_v2/ss1_tissueBed_entireDCP20close27remove1000_bedOpen5remove90000';
line_path = '/Volumes/yuan_lab/TIER2/anthracosis/pigment_v2/ss1_line_removal1000_eccen98_ratio98';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

% if ~exist(dst_path1, 'dir')
%     mkdir(dst_path1)
% end
    
files = dir(fullfile(src_path, '*.png'));
for i =1:length(files)
    file_name = files(i).name;
    file_name_new = extractBefore(file_name, '_Ss1.png');
    if ~isfile(fullfile(dst_path, [file_name_new, '_pigment.png']))
mask_pigment = imread(fullfile(src_path, file_name));
mask_tissue = imread(fullfile(tissue_path, [file_name_new, '_tissue.png']));
mask_line = imread(fullfile(line_path, [file_name_new, '.png']));


% mask_tissue_post = max(mask_tissue - mask_line, 0);
% mask_tissue_post = bwareaopen(mask_tissue_post, 10000);
% imwrite(mask_tissue_post, fullfile(dst_path1, [file_name_new, '_tissue.png']))
mask_tissue = im2gray(mask_tissue);
mask_tissue(mask_tissue>0) = 1;
mask_line(mask_line>0) = 1;

mask_tissue_post = max(mask_tissue - mask_line, 0);
mask_tissue_post = imresize(mask_tissue_post, 2, 'nearest');
[m, n] = size(mask_tissue_post);
%[m, n,~] = size(mask_pigment);
mask_pigment= mask_pigment(:,:,1);

mask_pigment_post = mask_pigment(1:m, 1:n).*mask_tissue_post;
% mask_pigment_post = mask_pigment_post - mask_line;
% mask_pigment_post = max(mask_pigment_post, 0);

imwrite(mask_pigment_post, fullfile(dst_path, [file_name_new, '_pigment.png']))
    end
end


