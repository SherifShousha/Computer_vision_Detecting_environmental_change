function [outImage] = preprocessor(inImage)
% this function takes input images and performs a set of processes on it to enhance the feature detection and segmentation
% input is rgb image 
% output is grayscale filtered image
%  processes are: gamma correction, conversion to grayscale, contrast enhancement, and filtering the image to discard the noise
%Author:Esam Hassan

% %Gamma correction
outImage = lin2rgb(inImage);

%convert the image to grayscale
if size(inImage,3)~=1
   outImage = rgb2gray(outImage); 
end

%contrast enhancment
 outImage = adapthisteq(outImage);
% 
% %filtering the image
sigma = 30;
outImage = imflatfield(outImage,sigma);
