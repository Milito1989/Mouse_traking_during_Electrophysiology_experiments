function [vid] = video_analyze_flow(vid)

    % find the pixels that are outside the background callibration
    [vid] = VA_out_of_bg_minmax(vid);

    
    % find an object (the largest continous region in each frame)
    [vid] = VA_find_nonbg_object(vid);
    
    % compile metrics about the selected object
    [vid] = VA_object(vid);    


end