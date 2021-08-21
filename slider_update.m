function slider_update(handle, slider_value)
%SLIDER_UPDATE updates slider image in response to changing slider value.

%get horizontal size of image
size_x=handle.XData(2);

%update right image mask proportionally based on new slider value
handle.AlphaData(:, 1:floor(slider_value*size_x)+1) = 0;
handle.AlphaData(:, ceil(slider_value*size_x)+1:end) = 1;
end

