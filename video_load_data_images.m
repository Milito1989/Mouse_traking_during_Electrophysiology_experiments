function [vid] = video_load_data_images(vid)

    user_message(vid, 'Loading images into matlab...\n');

%% get a list of files

    img_files = dir(fullfile(vid.file.data_dir, 'data*.png'));
    img_count = length(img_files);
    
    % don't load the last image
    % example: start at 2 seconds, 4 fps, for 10 seconds. this will
    % actually produce 81 frames because it includes the frame for both the
    % start at 2 seconds and the end at 10 seconds. so just don't load the
    % last one
    img_count = img_count - 1;
    
    vid.data.frames = img_count;
    
%% iterate through each file
   % tic%Took 26.149060
    for x = 1:img_count
    %Changed it to run in a faster way    
    %parfor x = 1:img_count        
        % build the file name
        img_file = fullfile(vid.file.data_dir, img_files(x).name);
        
        % import the image
        img_data = imread(img_file);
        
        % convert to black and white
        img_bw = rgb2gray(img_data);
        
        % load into video
        vid.data.video(:,:,x) = img_bw;
    end
   % toc
    
%% feedback

    user_message(vid, '\bDONE\n');


end