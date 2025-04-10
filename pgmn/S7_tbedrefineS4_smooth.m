
clear;
clc;
close all



src_path = '/Volumes/yuan_lab/TIER2/anthracosis/visium_TMA5primary2014/HE40x_tif/tbed1536_ss1/maskLuadLusc_tmeMacro_nonAlveoli_tumor5per_remove10000';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/visium_TMA5primary2014/HE40x_tif/tbed1536_ss1/maskLuadLusc_tmeMacro_nonAlveoli_tumor5per_remove10000_smooth30';

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end

files = dir(fullfile(src_path, '*.png'));
for i =1:length(files)
    file_name = files(i).name(1:end-13); 
    disp(file_name)
   
        mask_raw = imread(fullfile(src_path, [file_name,  '_tme_tbed.png'])); 
        mask_raw = mask_raw(:,:,1)/255;
       
        mask_bed = imgaussfilt(double(mask_raw), 30); %30 is the final to use
        mask_bed = 255 *uint8(mask_bed > 0.5);
        imwrite(cat(3, mask_bed, mask_bed, mask_bed), fullfile(dst_path, [file_name, '_tme_tbed.png']))
        

      
    
end


