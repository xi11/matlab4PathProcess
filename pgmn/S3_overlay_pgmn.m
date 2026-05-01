clear;
clc;
close all

%to overlay pgmn onto overlayed tumor-bed, ss1x8 level
tbed_path = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/ss1x8overlay_alveoli_nonTper_tbedAlveoli81000tme_close5remove90000_nec';
tme_path = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/mit-b3-finetuned-TCGAbcssWsss10xLuadMacroMuscle-40x896-20x512-10x256re/mask_ss1512';
pgmn_path = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/pgmn_segformer_stainedgeV3/mask_ss1_x8';
dst_path  = '/Volumes/yuan_lab/TIER2/anthracosis/cptac_luad/ss1x8overlay_pgmn_tme_nonTper_tbedAlveoli81000tme_close5remove90000_nec';

if ~exist(dst_path, 'dir')
    mkdir(dst_path);
end

files = dir(fullfile(tbed_path, '*_alveoli_tbed.png'));

for i = 1:length(files)

    % Example input name: xxx_tme_tbed.png
    file_name = erase(files(i).name, '_alveoli_tbed.png');

    disp(file_name)

    tbed_file = fullfile(tbed_path, [file_name, '_alveoli_tbed.png']);
    pgmn_file = fullfile(pgmn_path, [file_name, '_Ss1.png']);
    tme_file = fullfile(tme_path, [file_name, '_Ss1.png']);

    if ~exist(pgmn_file, 'file')
        warning('PGMN mask not found: %s', pgmn_file);
        continue;
    end

    mask_tbed = imread(tbed_file);
    mask_pgmn = imread(pgmn_file);
    mask_tme = imread(tme_file);

    % Ensure tbed is RGB
    if ismatrix(mask_tbed)
        mask_tbed = repmat(mask_tbed, [1, 1, 3]);
    end

    % Ensure tme is RGB
    if ismatrix(mask_tme)
        mask_tme = repmat(mask_tme, [1, 1, 3]);
    end

    % Use first channel if pgmn mask is RGB
    if ndims(mask_pgmn) == 3
        mask_pgmn_re = mask_pgmn(:, :, 1);
    else
        mask_pgmn_re = mask_pgmn;
    end

    % Check dimensions
    if size(mask_tbed, 1) ~= size(mask_pgmn_re, 1) || size(mask_tbed, 2) ~= size(mask_pgmn_re, 2)
        warning('Dimension mismatch for %s. Skipping.', file_name);
        continue;
    end

    [m, n, ~] = size(mask_tbed);
    mask_tme = imresize(mask_tme, [m, n], 'nearest');

    tbed_color = uint8([135, 133, 186]);

    % Extract tissue_color region from RGB tbed mask
    tbed_binary = ...
        mask_tbed(:, :, 1) == tbed_color(1) & ...
        mask_tbed(:, :, 2) == tbed_color(2) & ...
        mask_tbed(:, :, 3) == tbed_color(3);
    
    % Filter mask_tme using tissue_binary
    mask_tme_filtered = mask_tme;
    mask_tme_filtered(repmat(~tbed_binary, [1, 1, 3])) = 0;
    
    % Use first channel if PGMN is RGB
    if ndims(mask_pgmn) == 3
        mask_pgmn_re = mask_pgmn(:, :, 1);
    else
        mask_pgmn_re = mask_pgmn;
    end
    
    % Condition:
    % 1) PGMN mask is 255
    % 2) filtered TME RGB is not all zeros
    pgmn_positive = mask_pgmn_re == 255;
    tme_positive = any(mask_tme_filtered > 0, 3);
    
    overlay_mask = pgmn_positive & tme_positive;
    
    % Set overlay pixels to white
    mask_tme_filtered(repmat(overlay_mask, [1, 1, 3])) = 255;


    % Save result
    imwrite(mask_tme_filtered, fullfile(dst_path, [file_name, '_alveoli_tbed.png']));

end