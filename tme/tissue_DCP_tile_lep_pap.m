clear;
clc;
close all

src_path = 'path_to_H&E_images';
dst_path = 'path_to_corrected_annotations';
if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end
pattern = 'lep'; %to change to 'pap' for papillary


lep = [0, 0, 255];
pap = [255, 255, 0];
mic = [255, 0, 255];
files = dir(fullfile(src_path, '*.ndpi')); % to change to svs
for i =1:length(files)
    file_name = files(i).name;
    file_path = fullfile(dst_path, file_name);
    if ~exist(file_path, 'dir')
        mkdir(file_path)
    end
    
    Da_files = dir(fullfile(src_path, file_name, 'Da*')); %to check
    for j = 1:length(Da_files)
        Da_name = Da_files(j).name;
        Da_ID = extractBefore(Da_name, '.jpg'); %to check
        %if ~isfile(fullfile(file_path,[Da_ID, '.png']))
            mask_raw = imread(fullfile(src_path, file_name, Da_name));
            max_c = max(mask_raw, [], 3);
            min_c = min(mask_raw, [], 3);
            mask_dark = max_c - min_c;
            mask_dark(mask_dark>20)=255; % a threshold to be adjusted, a higher value indicates more outband tissue (airspace) will be excluded
            mask_dark(mask_dark<=20)=0;
            mask_post1 = bwareaopen(logical(mask_dark), 5000); %remove small individual componets less than 5000 pixels, e.g., floating blood cells; need to tweak for micropapillary
            mask_post_reverse = 1 - mask_post1;
            mask_post_reverse = bwareafilt(logical(mask_post_reverse), [0,3000]);  %keep small objects; as it performs on the reverse mask, then here is to keep small holes 
            mask_post2 = regionfill(uint8(255*mask_post1), mask_post_reverse); %fill in small holes
            mask_post2 = uint8(imbinarize(mask_post2));
            switch pattern
                case 'lep'
                    rgbImg = cat(3, lep(1)* mask_post2, ...
                        lep(2)*mask_post2, ...
                        lep(3)*mask_post2);
                    imwrite(rgbImg, fullfile(file_path,[Da_ID, '.png']))
                case 'pap'
                    rgbImg = cat(3, pap(1)* mask_post2, ...
                        pap(2)*mask_post2, ...
                        pap(3)*mask_post2);
                    imwrite(rgbImg, fullfile(file_path,[Da_ID, '.png']))
                case 'mic'
                    rgbImg = cat(3, mic(1)* mask_post2, ...
                        mic(2)*mask_post2, ...
                        mic(3)*mask_post2);
                    imwrite(rgbImg, fullfile(file_path,[Da_ID, '.png']))
                otherwise
                    warning('Cannot be applied to other patterns')
            end
        %end
    end
end


