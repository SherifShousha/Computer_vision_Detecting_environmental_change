function timelapse(app,image_array)
%TIMELAPSE: creates and displays a timelapse in the image viewer of the app.

n_images=size(image_array,2);
while(~app.EndPlaybackButton.Value)
    
    for i=1:n_images
        %if pause pressed while playing timelapse. Stop playing
        if app.EndPlaybackButton.Value
            break
        end
        imagesc(app.ImageAxes,image_array{i});
        pause(1/app.FPSField.Value);   % pause for between images to achieve desired fps
    end
    
end
    %reset playback button
    app.EndPlaybackButton.Value=false;
end
   
