clc
clear

% read the image
A = double(imread('mandrill.jpg'))/255;
A = A+0.1*randn(size(A));
A(A<0) = 0; A(A>1) = 1;

imshow(A)

% apply the filter
B = bilateral_filter(A,3,2,30);

figure;
imshow(B)