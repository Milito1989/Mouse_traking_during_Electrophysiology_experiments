function [vid] = video_info(video_path_initial, folder_subnameini, analysis_dir,trial_number,calib_time)
    trial_subname = int2str(trial_number);
% Return a structure of file locations for video analysis
    [video_path, original_video_file_name, org_video_extension] = fileparts(video_path_initial);
    folder_subname= strcat(folder_subnameini, '/' , trial_subname);
    vid.file.name = folder_subname ; %For further output video
    original_video_file_name = [original_video_file_name, org_video_extension];
    
    % directory of images for data
    vid.file.analysis_dir = fullfile(folder_subname);
    vid.file.data_dir = fullfile(folder_subname, 'data');
    vid.file.matlab = fullfile(folder_subname, 'video_info.mat');
    [mkdir_state, mkdir_message, mkdir_message_id] = mkdir(vid.file.data_dir);
    

    vid.params.show_ffmpeg_output = false;

    vid.params.data_extract_fps = 10;%25;%changed to 25 F/Sec


%     %Here We get the calibration start time in seconds
%     vid.timing.callibration_start = query_seconds('Enter time for calibration ');
    vid.timing.callibration_start = calib_time;
    %Here is for the output video file; deafault was [80 60]
    vid.params.data_extract_clip_size = [100 100]; % [width height]
    %vid.params.data_extract_clip_size = [80 60];
    % the width of clip size will be adjusted by
    % vidz_query_physical_dimensions so that the aspect ratio of the video
    % will match the aspect ratio of the physical dimensions
    vid.file.original = video_path_initial;%vid.file.original
    vid.original.clip_rec = [0,0,720,576];
    vid.params.physical_dims = [1 1];
    vid.params.pixel_edge_length = vid.params.physical_dims(1) / vid.params.data_extract_clip_size(1);

%% region analysis

    vid.params.analysis_bin_size_in_secs = 60;

%% parameters for creating output video

    % see additional notes in vidz_create_analysis_video()

    % amount to speed up video (e.g. display mouse movements at 10 times
    % normal speed)
    vid.params.output_video_time_elapse_ratio = 10;%M was 10

    % number of frames to display per second of real time. lower numbers
    % reduce processing time and file size, but may appear more jumpy
    vid.params.output_video_input_fps = 0.5; %M was 0.5



    %*I will turn this to pixels 
    width = 720; % pixels
    height = 576; % pixels
    vid.params.physical_dims = [width height];

    
    height_pixel_count = 576;%288
    width_pixel_count = 720;%360;
    %Following values are just for the output video and not analysis result
    %I have selected half from both
    vid.params.data_extract_clip_size(1) = width_pixel_count;
    vid.params.data_extract_clip_size(2) = height_pixel_count;

    clip_coords.left    = 0;
    clip_coords.top     = 0;
    clip_coords.right   = 720;
    clip_coords.bottom  = 576;
    clip_coords.width   = 720;
    clip_coords.height  = 576;
    clip_coords.x_center= 360;
    clip_coords.y_center= 288;

    vid.original.clip_trbl = [...
        clip_coords.top, ...                          % top
        0, ...   % right
        0, ...  % bottom
        clip_coords.left];

    %% delete existing files
    if trial_number == 1
  
        vid.file.callibration_dir = fullfile(folder_subname, 'callibration');
        [mkdir_state, mkdir_message, mkdir_message_id] = mkdir(vid.file.callibration_dir);
        
        [status, message] = system(sprintf('rm -f %s/callibration*.png', strrep(vid.file.callibration_dir, ' ', '\ ')));

    %% ffmpeg command

        ffmpeg_params = ffmpeg_build_cmd();
        ffmpeg_params.input = vid.file.original;
        ffmpeg_params.start = vid.timing.callibration_start;%40;%vid.timing.callibration_start,0, 1:06:47 is 4007sec was 28
        ffmpeg_params.duration = 1;%vid.timing.callibration_duration,1
        ffmpeg_params.size = vid.params.data_extract_clip_size;
        ffmpeg_params.rate = vid.params.data_extract_fps;
        ffmpeg_params.clip_trbl = vid.original.clip_trbl;
        ffmpeg_params.crop = vid.original.clip_rec;
        ffmpeg_params.output = fullfile(vid.file.callibration_dir, 'callibration%04d.png');

        ffmpeg_run_cmd(ffmpeg_params, vid.params.show_ffmpeg_output);
    end
   
     if trial_number > 1
       trial_subname = int2str(trial_number);
       folder_subname2= strcat(folder_subnameini, '/' , trial_subname);
       DIR = fullfile(folder_subname2, 'callibration');
       mkdir(DIR);
       Calib_Files= strcat(folder_subnameini, '/' , int2str(1),'/callibration');
       vid.file.callibration_dir = DIR;
       copyfile(Calib_Files, DIR);
     end
end
    