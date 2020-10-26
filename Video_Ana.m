%%Info about this file ....
%setting up the default path
default_search_dir = '~/Best Detector';
%Here we select the video
[video_file, video_dir] = uigetfile(fullfile(default_search_dir , '*.*'), 'Please select the video');
%Path to the video file 
video_path =fullfile(video_dir, video_file);
% select a folder to store all the files for the analysis
analysis_dir = video_dir;
%Getting a name for the folder which will be created
folder_subname = input('Enter name for the analysis folder: ', 's');
[mkdir_state, mkdir_message, mkdir_message_id] = mkdir(folder_subname);
%Loop through all trials of an experiment/video
all_trials = str2double(input('Enter number of trial(s) : ', 's'));
%Here We get the calibration start time in seconds
calib_time = query_seconds('Enter time for calibration : ');
timing_table = zeros (all_trials,2);
for x1 = 1:all_trials
    % similar to specifying timing for callibration section, except for the
    % data sec
    timing_table(x1,1)=query_seconds(sprintf('Enter data start time for trial number.%d : ', x1));
    %vid.timing.data_start = query_seconds('Enter data start time ');

    % for experiments of fixed duration, use this format
    timing_table(x1,2)=query_seconds(sprintf('Enter data duration for trial number.%d : ', x1));
    %vid.timing.data_duration = query_seconds('Enter data duration ');

end




for x2 = 1:all_trials
    tic
%     N = feature('numcores');
%     clust = parcluster('local');
%     job = batch(clust,video_info(video_path, folder_subname, analysis_dir,int2str(x2),calib_time),1,'pool',N-1);
%     vid = submit(job);
   % trial_subname = input('Enter name for trial folder: ', 's');
    %Creating a large structure containing video information
    vid = video_info(video_path, folder_subname, analysis_dir,x2,calib_time);

    %% specify timing of data section of video


    vid.timing.data_start = timing_table(x2,1);
% 
    vid.timing.data_duration = timing_table(x2,2);

    %% create image  sequencesequence for data analysis

    % this is the section that slices up the video into individual images for
    % analysis. it doesn't not provide percent complete information because the
    % work is performed by ffmpeg
    vid.params.feedback = 1;

    vid = video_dataproc(vid);


    vid = video_load_data_images(vid);

    %% import the callibration images
    if x2 == 1
        cal_files = dir(fullfile(vid.file.callibration_dir, '*.png'));
        for x = 1:length(cal_files)
            cal_file = fullfile(vid.file.callibration_dir, cal_files(x).name);
            cal_img = rgb2gray(imread(cal_file));
            if x == 1
                cal_vid = nan([size(cal_img), length(cal_files)]);
            end

            cal_vid(:,:,x) = cal_img;
        end
    end

    %% save basic parameters    

    vid.callibration.image = mean(cal_vid,3);
    vid.callibration.dims = size(vid.callibration.image);
    vid.callibration.video = cal_vid;

    %% analyze intensity values
    %A Completely dark image
    vid.callibration.range.min = min(cal_vid,[],3)-45;
    %A Completely white image
    vid.callibration.range.max = max(cal_vid,[],3)+45;

    %% analyze data images against bg values

    % this section analyzes the exported images to track the object

    vid = video_analyze_flow(vid);

    %% review analysis results

    % this section provides a variety of options to the user to review the
    % results of the object tracking.
    %
    % there are options for making corrections if the tracking picks up on a
    % bad area (e.g. there is a reflection), but i'll document those elsewhere

    vid = VA_review(vid); 

    %% Some Outputs
    Output_figures(vid);
    %Copy contents of vis struct into the other
% 
    vidnew.file         = vid.file;
%     vidnew.params       = vid.params;
%     vidnew.original     = vid.original;
    vidnew.timing       = vid.timing;
    vidnew.callibration = vid.callibration;
    %Here we save some importnant video information
    save(vid.file.matlab, 'vidnew');
toc
end
close all;
