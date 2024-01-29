function tme_post = segRefine(mask_ss1_path, ss1_path) 
mask_ss1 = imread(mask_ss1_path);
mask_raw = imread(ss1_path);

max_c = max(mask_raw, [],3);
min_c = min(mask_raw, [], 3);
mask_minus = max_c - min_c;
mask_minus(mask_minus>20)=255;
mask_minus(mask_minus<=20)=0;
mask_post = mask_minus;
[m, n] = size(mask_post);
se = strel('disk',11);  %to set
mask_post1 = imerode(mask_post, se);
mask_post1 = imfill(mask_post1, 'holes'); 
mask_post2 = logical(mask_post1);
stat = regionprops(mask_post2, 'Area', 'PixelIdxList');
[~, index] = sort([stat.Area], 'descend');
if length(index)>0
if length(index)>1
    num_bed = min(3, length(index));  %to set
    for j=2:num_bed
        mask_iter = uint8(mask_post2)*255;  
        mask_iter(stat(index(j)).PixelIdxList)=128;
        mask_iter(mask_iter>128)=0;
        mask_iter(mask_iter==128)=1;
        mask_temp = mask_iter.*mask_ss1(1:m, 1:n,:);
        mask_tumor = zeros(m,n);
        mask_tumor(mask_temp(:,:,1)==128 & mask_temp(:,:,2)==0 & mask_temp(:,:,3)==0)=1;  
        tumor_area = length(find(mask_tumor>0));
        mask_temp = im2gray(mask_temp);
        temp_area = length(find(mask_temp>0));
        
        if temp_area*0.1 < tumor_area   %to set
            mask_post1(stat(index(j)).PixelIdxList)=128;
        end
        
    end
end
mask_post1(stat(index(1)).PixelIdxList)=128;
mask_post1(mask_post1>128)=0;
mask_post1(mask_post1==128)=1;

se1 = strel('disk',15);  %to set
mask_post1 = imdilate(mask_post1, se1);
mask_post1 = imfill(mask_post1, 'holes'); 
mask_ss1_post = mask_post1.*mask_ss1(1:m, 1:n,:);
mask_ss1_post = im2gray(mask_ss1_post);
mask_ss1_post(mask_ss1_post>0) = 255;
mask_ss1_post2 = DCP_morph(mask_ss1_post, mask_ss1,5, 5);  %to set
tme_post = mask_ss1_post2.*mask_ss1(1:m, 1:n,:);
else
    mask_ss1_post2=0;
  tme_post = mask_ss1_post2.*mask_ss1(1:m, 1:n,:);  
    
end
end

function mask_post = DCP_morph(mask_DCP, mask_ss1,seVal, se1Val)
mask_post1 = imfill(mask_DCP, 'holes'); %only, ss1_mask_fill_3
se = strel('disk',seVal);
mask_post1 = imerode(mask_post1, se);
mask_post2 = logical(mask_post1);
stat = regionprops(mask_post2, 'Centroid', 'Area', 'PixelIdxList');
[~, index] = sort([stat.Area], 'descend');
[m, n] = size(mask_DCP);
if length(index)>0
if length(index)>1
    num_bed = min(3, length(index));  %to set
    for j=2:num_bed
        mask_iter = uint8(mask_post2)*255;  
        mask_iter(stat(index(j)).PixelIdxList)=128;
        mask_iter(mask_iter>128)=0;
        mask_iter(mask_iter==128)=1;
        mask_temp = mask_iter.*mask_ss1(1:m, 1:n,:);
        mask_tumor = zeros(m,n);
        mask_tumor(mask_temp(:,:,1)==128 & mask_temp(:,:,2)==0 & mask_temp(:,:,3)==0)=1;
        tumor_area = length(find(mask_tumor>0));
        mask_temp = im2gray(mask_temp);
        temp_area = length(find(mask_temp>0));
        
        if temp_area*0.1 < tumor_area  %to set
            mask_post1(stat(index(j)).PixelIdxList)=128;
        end
        
    end
end

mask_post1(stat(index(1)).PixelIdxList)=128;
mask_post1(mask_post1>128)=0;
mask_post1(mask_post1==128)=1;

se1 = strel('disk',se1Val);
mask_post1 = imdilate(mask_post1, se1);
mask_post = imfill(mask_post1, 'holes');

else
    mask_post=0;
end
end
