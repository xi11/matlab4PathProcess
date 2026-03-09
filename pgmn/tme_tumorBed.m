clear;
clc;
close all

tme_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/tmesegproTcgaDiv12/mask_ss1';
tbed_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/ss1x8_tissueBed_entireDCP10close27remove90000_bedDCP20Open5remove90000';

dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/tmesegproTcgaDiv12/mask_ss1_tbed';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end


files = dir(fullfile(tme_path, '*.png'));
for i =1:length(files)
    file_name = files(i).name;
    disp(file_name)
     file_name_new = extractBefore(file_name, '_Ss1.png');
    if ~isfile(fullfile(dst_path, [file_name_new, '_tumorBed_tme.png']))
        %if isfile(fullfile(src_path, file_name, 'Ss1.jpg'))
        
        mask_tme = imread(fullfile(tme_path, file_name));
        mask_raw = imread(fullfile(tbed_path, [file_name_new,  '_tissue_tumorBed.png']));
        [m, n, ~] = size(mask_raw);
        mask_tme = imresize(mask_tme, [m, n], 'nearest');
        
        mask_digit = zeros(m, n);
        mask_digit((mask_raw(:,:,1)==255 & mask_raw(:,:,2)==0 & mask_raw(:,:,3)==0)) = 1; % t-beb
        
        mask_final = mask_tme.*uint8(mask_digit);
        
        imwrite(mask_final, fullfile(dst_path, [file_name_new, '_tumorBed_tme.png']))
    end
end