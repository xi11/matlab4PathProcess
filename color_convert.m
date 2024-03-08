clear;
clc;
close all

src_path = '/Volumes/xpan7/project/tcga_tnbc/public_train/background/TCGA-E9-A22G-Da86.jpg';
dst_path = '/Volumes/xpan7/project/tcga_tnbc/public_train/background/TCGA-E9-A22G-Da86_132.jpg';
dst_path1 = '/Volumes/xpan7/project/tcga_tnbc/public_train/background/TCGA-E9-A22G-Da86_231.jpg';
img = imread(src_path);
figure;
imshow(img)

img1 = img(:,:, 1);
img2 = img(:,:,2);
img3 = img(:,:,3);

img_red = cat(3, img1, img3, img2);
figure;
imshow(img_red)
imwrite(img_red, dst_path);

img_green = cat(3, img2, img3, img1);
figure;
imshow(img_green)
%imwrite(img_green, dst_path1);