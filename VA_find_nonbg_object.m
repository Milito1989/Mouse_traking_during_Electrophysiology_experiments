function [vid] = VA_find_nonbg_object(vid)
% Select the target object based on background data

    % feedback
    user_message(vid, 'Analyzing for object location...00\n');
    
%% determine candidate pixels

    [vid] = VA_candidate_pixels(vid);%576*720*4479

%% find all objects

    object_props = cell(vid.data.frames, 1);

    for frame_num = 1:vid.data.frames
        user_message(vid, sprintf('\b\b\b%02d\n', floor(frame_num / vid.data.frames * 100)));
        object_image = bwlabel(vid.data.candidate_pixels(:,:,frame_num));
        object_props{frame_num} = regionprops(object_image, {'area','centroid'});
    end
%% perform first pass by selecting the largest object

    selected_object_indices = nan(frame_num, 1);
    
    for frame_num = 1:vid.data.frames
        this_object_props = object_props{frame_num};
        
        % as long as 1 object was found, get its index. otherwise leave
        % selected_object_indices(frame_num) as NaN
        if ~isempty(this_object_props)
            [junk_sorted_areas, descending_area_indices] = sort([this_object_props.Area], 'descend');
            largest_object = descending_area_indices(1);
            selected_object_indices(frame_num) = largest_object;
        end
    end

    
%% compile properties of selected object

    nan_props = struct;
    nan_props.Area = NaN;
    nan_props.Centroid = [NaN NaN];

    for frame_num = 1:vid.data.frames
        frame_object_props = object_props{frame_num};
        selected_object_index = selected_object_indices(frame_num);
        % if object was found
        if ~isnan(selected_object_index)
            selected_object_props = frame_object_props(selected_object_index);
        % if no object was found
        else
            selected_object_props = nan_props;
        end
        if frame_num == 1              
            vid.object.props = selected_object_props;
        else
            vid.object.props(frame_num) = selected_object_props;
        end            
    end

%%    
  
    user_message(vid, '\b\b\b\bDONE\n');

    
    
%%
end