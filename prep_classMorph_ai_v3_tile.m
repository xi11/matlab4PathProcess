clc
clear
close all;
%% class: raw classification; class2: refined classification
data_folder = '/Volumes/yuan_lab/TIER2/tms-st_wenyi/lung2024/4_cell_class_segformerMacro/csv'; %annotations / cells
seg_folder = '/Volumes/yuan_lab/TIER2/tms-st_wenyi/lung2024/3_cell_seg/mat'; %1054 in RDS, 947 in proj5, not sure how many is overlapped
cws_folder = '/Volumes/yuan_lab/TIER2/tms-st_wenyi/lung2024/1_cws_tiling';
files = dir(fullfile(seg_folder, '*.tif'));

%%
save_folder = '/Volumes/yuan_lab/TIER2/tms-st_wenyi/lung2024/cellFeatures_v3_refine';
%save_filename = 'regional_tilesArea.csv';
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end
%%
for i = 1:length(files)
    sample = files(i).name;
    sampleName = sample; %sample(1:end-5);
    if ~isfile(fullfile(save_folder, [sample, '.csv']))
    if ~exist(fullfile(save_folder, sample), 'dir')
        mkdir(fullfile(save_folder, sample));
    end
    Das = dir(fullfile(data_folder,sample, '*.csv'));
    ref_table = [];
    for k = 1:length(Das)
        disp([sample ':'  num2str(k) '/' num2str(length(Das))]);
        DaName = Das(k).name(1:end-4);
        
        if ~isfile(fullfile(save_folder,sample,[DaName '.csv']))
            %the cell classification
            %1 2 3 4 | f l t o
            class = readtable(fullfile(data_folder, sample, Das(k).name));
            class = class(:, {'V1', 'V2', 'V3', 'V6'});
            
            %segmented cells
            if isfile(fullfile(seg_folder, sample, [DaName '.mat']))
            seg = load(fullfile(seg_folder, sample, [DaName '.mat']));
            if isfield(seg, 'mat')
                if any(seg.mat.BinLabel(:))
                    %retrieve all cancer cell segments, centroid = csv x,y
                    stats = regionprops('table',seg.mat.BinLabel,...
                        'Area',...
                        'Centroid',...
                        'ConvexArea',...
                        'ConvexHull',...
                        'ConvexImage',...
                        'Eccentricity',...
                        'EquivDiameter',...
                        'Extent',...
                        'FilledArea',...
                        'FilledImage',...
                        'MajorAxisLength',...
                        'MinorAxisLength',...
                        'Solidity',...
                        'Perimeter');
                    %'BoundingBox',...
                    %'Circularity',...%'Orientation',... %'PixelList',...%'PixelIdxList',...'Extrema',...'EulerNumber',...
                    
                    
                    %match with GT csv
                    P = stats.Centroid;
                    PQ = [class.V2 class.V3];
                    [xxk,dist] = dsearchn(P,PQ);
                    stats = stats(xxk,:);
                    
                    class.Properties.VariableNames = {'class' 'x_tile' 'y_tile' 'class2'};
                    stats = [class stats];
                    
                    %average
                    if (iscell(stats.ConvexHull)==1) && (iscell(stats.FilledImage)==1) && (iscell(stats.ConvexImage)==1)
                        ConvexHullMedian = cellfun(@(x) mean(x, 'all'), stats.ConvexHull);
                        FilledImageMedian = cellfun(@(x) mean(x, 'all'), stats.FilledImage);
                        ConvexImageMedian = cellfun(@(x) mean(x, 'all'), stats.ConvexImage);
                        
                        
                        tConvexHullMedian = table(ConvexHullMedian, 'VariableNames',{'ConvexHullMedian'});
                        tFilledImageMedian = table(FilledImageMedian, 'VariableNames',{'FilledImageMedian'});
                        tConvexImageMedian = table(ConvexImageMedian, 'VariableNames',{'ConvexImageMedian'});
                        %takeout
                        stats.ConvexImage=[];
                        stats.ConvexHull=[];
                        stats.FilledImage=[];
                        
                        diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
                        radii = diameters/2;
                        tDiameters = table(diameters, 'VariableNames',{'Diameters'});
                        tRadii = table(radii, 'VariableNames',{'Radii'});
                        
                        %now the HE
                        im = imread(fullfile(cws_folder, sample, [DaName '.jpg']));
                        im = im2double(im);
                        mask = seg.mat.BinLabel;
                        imR = im(:,:,1).*mask;
                        imG = im(:,:,2).*mask;
                        imB = im(:,:,3).*mask;
                        statsImR = regionprops('table',mask, imR,...
                            'MaxIntensity', 'MeanIntensity', 'MinIntensity'); %take out 'WeightedCentroid'
                        statsImG = regionprops('table',mask, imG,...
                            'MaxIntensity', 'MeanIntensity', 'MinIntensity');
                        statsImB = regionprops('table',mask, imB,...
                            'MaxIntensity', 'MeanIntensity', 'MinIntensity');
                        statsImR.Properties.VariableNames = {'MeanIntensity_R' 'MinIntensity_R' 'MaxIntensity_R'};
                        statsImG.Properties.VariableNames = {'MeanIntensity_G' 'MinIntensity_G' 'MaxIntensity_G'};
                        statsImB.Properties.VariableNames = {'MeanIntensity_B' 'MinIntensity_B' 'MaxIntensity_B'};
                        statsImR = statsImR(xxk,:);
                        statsImG = statsImG(xxk,:);
                        statsImB = statsImB(xxk,:);
                        
                        stats = [stats tConvexHullMedian tFilledImageMedian tConvexImageMedian tDiameters tRadii statsImR statsImG statsImB];
                        
                        %average RGB img intensity features
                        %RGBWCx = mean([statsImR.WeightedCentroid_R(:,1), statsImG.WeightedCentroid_G(:,1), statsImB.WeightedCentroid_B(:,1)],2);
                        %RGBWCy = mean([statsImR.WeightedCentroid_R(:,2), statsImG.WeightedCentroid_G(:,2), statsImB.WeightedCentroid_B(:,2)],2);
                        tmeanI = table2array(stats(:, contains(stats.Properties.VariableNames, 'MeanIntensity')));
                        RGBMeanIntensity = mean(tmeanI, 2);
                        tminI = table2array(stats(:, contains(stats.Properties.VariableNames, 'MinIntensity')));
                        RGBMinIntensity = mean(tminI, 2);
                        tmaxI = table2array(stats(:, contains(stats.Properties.VariableNames, 'MaxIntensity')));
                        RGBMaxIntensity = mean(tmaxI, 2);
                        RGBStats = table(RGBMeanIntensity, RGBMinIntensity, RGBMaxIntensity); %taken out RGBWCx, RGBWCy,
                        
                        trait = [stats RGBStats];
                        trait = string_to_table(trait, DaName, 'tile');  %Players.Role = repmat("Cricketer", size(Players.Name))
                        trait = string_to_table(trait, sample, 'sample');
                        
                        writetable(trait, fullfile(save_folder,sample,[DaName '.csv']));
                        %more features
                        
                        % %                 if isempty(ref_table)
                        % %                     ref_table = trait;
                        % %                 else
                        % %                     ref_table = [ref_table; trait]; %#ok<AGROW>
                        % %                 end
                    end
                end
            else
                continue
            end
            end
        end
    end
    end
    % %     if ~isempty(ref_table)
    % %         writetable(ref_table, fullfile(save_folder, [sampleName '.csv']));
    % %
    % %     end
    
    %save(fullfile(save_folder, [sampleName '.mat']), 'ref_table', '-v7.3');
end