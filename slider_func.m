function slider_handle=slider_func(ax, image_right,image_left, slider_value)
%Display a before and after image alongside a slider to allow users to
%slide between the two images to compare them

image_right = imresize(image_right, size(image_left, [1 2])); % making the dimensions equal
sizex=size(image_right,2); %get horizontal image size

%setup image axes
ax.Units='pixels';
imagesc(ax,image_left); %display left image
hold(ax,'on');
slider_handle=imagesc(ax,image_right);%display right image
%hide right image by setting its entire alpha mask=0
slider_handle.AlphaData = zeros(size(image_left, [1 2])); 

%update mask to correspond to current slider value
slider_handle.AlphaData(:, 1:floor(slider_value*sizex)) = 0;
slider_handle.AlphaData(:, ceil(slider_value*sizex):end) = 1;

end


