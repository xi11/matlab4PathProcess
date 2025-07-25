clear;
clc;
close all

% this is for ST overlay
%to overlay tissue, tumor-bed
tme_path = '/Volumes/yuan_lab/TIER2/anthracosis/10x_xenium/mit-b3-finetuned-TCGAbcssWsss10xLuadMacroMuscle-40x896-20x512-10x256re/mask_ss1x512';
tbed_path = '/Volumes/yuan_lab/TIER2/anthracosis/10x_xenium/tbed1536_ss1/maskLuadLusc_nonTper_nonAlveoli_remove10000_smooth30';
pgmn_path = '/Volumes/yuan_lab/TIER2/anthracosis/10x_xenium/pgmn_segformer_stainedgeV3/mask_ss1_x1_filter0fill_dilate91';
dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/10x_xenium/fullresoverlay_pgmnClass_dilate91_alveoli_tbedraw_remove160000';  %default ss1x8overlay_alveoli_tbed_remove90000
 
%tme_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/fig1_demo/mask_10x_tme';
%tbed_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/fig1_demo/maskLuadLusc_tmeMacro_tumor5per_remove10000';
%pgmn_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/fig1_demo/mask_10x_pgmn';
%dst_path = '/Volumes/yuan_lab/TIER2/anthracosis/never_smoker/fig1_demo/x10resoverlay_pgmn_alveoli_tbedraw_remove160000';  %default ss1x8overlay_alveoli_tbed_remove90000

if ~exist(dst_path, 'dir')
    mkdir(dst_path)
end
tbed_corlor = [135, 133, 186];
tissue_color = [0, 128, 0];  %alveoli
files = dir(fullfile(tbed_path, '*tbed.png'));
for i =1:length(files)
    file_name = files(i).name(1: end-13); %-13 / -9
    disp(file_name)
        mask_tbed = imread(fullfile(tbed_path, [file_name, '_tme_tbed.png'])); %_tme_tbed.png / _tbed.png
        mask_tme = imread(fullfile(tme_path, [file_name, '.tif_Ss1.png']));
        mask_pgmn = imread(fullfile(pgmn_path, [file_name, '_dilate.png'])); %'.tif_Ss1.png'
        [m, n, ~] = size(mask_pgmn);
        mask_tbed = imresize(mask_tbed, [m, n], 'nearest');

        %%%%tissue
        mask_tissue0 = logical(rgb2gray(mask_tme));
        mask_tissue  = imfill(mask_tissue0 , 'holes');
        se1 = strel('disk',21);  %to set
        %mask_tissue  = imopen(mask_tissue , se1);
        mask_tissue  = imclose(mask_tissue , se1);
        mask_tissue  = imfill(mask_tissue , 'holes');

        cc2 = bwconncomp(mask_tissue);
        stats2 = regionprops(cc2,'Area');
        idx2 = find([stats2.Area] >= 160000); %dont change at 20x,0.44mpp
        BW2 = ismember(labelmatrix(cc2),idx2);
        BW2 = imresize(BW2, [m, n], 'nearest');
        mask_tissue0 = imresize(mask_tissue0, [m, n], 'nearest');
        
        mask_pgmn_re = mask_pgmn .*uint8(BW2);
        mask_alveoli = mask_tissue0 .*BW2;

        BW3 = logical(mask_tbed(:,:,1));
        mask_tissue1 = tissue_color(1) *uint8(mask_alveoli);
        mask_tissue2 = tissue_color(2) *uint8(mask_alveoli);
        mask_tissue3 = tissue_color(3) *uint8(mask_alveoli);

        mask_tme = imresize(mask_tme, [m, n], 'nearest');
        %mask_tme1 = mask_tme(:,:,1);
        %mask_tme2 = mask_tme(:,:,2);
        %mask_tme3 = mask_tme(:,:,3);
        mask_tissue1(BW3) = tbed_corlor(1); %mask_tme1(BW3); 
        mask_tissue2(BW3) = tbed_corlor(2); %mask_tme2(BW3);
        mask_tissue3(BW3) = tbed_corlor(3); %mask_tme3(BW3); 
        mask_final = cat(3,mask_tissue1, mask_tissue2, mask_tissue3);
        
        %%for better visualization with pgmn as all white
        %mask_pgmn_re = mask_pgmn_re(:,:,1);
        %mask_final(repmat(logical(mask_pgmn_re), [1, 1, 3])) = 255;
        %%mask_final = imresize(mask_final,2,'nearest');


        %%for better visualization with pgmn as in tbed[224, 130, 20] and non-tbed[222,119,174]
        mask_pgmn_re = mask_pgmn_re(:,:,1);
        color1 = [224, 130, 20];   % for pixels in both BW3 and mask_pgmn_re
        color2 = [222,119,174];  % for pixels in mask_pgmn_re but not in BW3
        
        % Mask where both BW3 and mask_pgmn_re are true
        mask_both = BW3 & mask_pgmn_re;
        
        % Mask where only mask_pgmn_re is true but not BW3
        mask_only_pgmn = mask_pgmn_re & ~BW3;
        
        % Assign colors to corresponding channels
        for c = 1:3
            channel = mask_final(:,:,c);
            channel(mask_both) = color1(c);
            channel(mask_only_pgmn) = color2(c);
            mask_final(:,:,c) = channel;
        end
       
        imwrite(mask_final, fullfile(dst_path, [file_name, '_alveoli_tbed.png']))
   
end