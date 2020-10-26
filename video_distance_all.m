function [f] = video_distance_all(vid)
% Display graph of distance travelled, useful for finding tracking jumps


%% display figure

    f = figure;

    plot(vid.object.movement.by_frame)
    xlabel('Frame Number');
    ylabel('Distance moved (pix)');
    xlim([1 vid.data.frames]);
    
%% Report distances & Speed to output

    total_distance = nansum(vid.object.movement.by_frame);
    fprintf('Total distance traveled: %3.1f pixels\n', total_distance);

    [max_speed, frame_of_max] = max(vid.object.speed.by_frame);
    % convert max speed from m to cm
    max_speed = max_speed * 100;
    fprintf('Max speed traveled was %1.2f pixel/sec at frame %d\n', max_speed, frame_of_max);
    
%%

end
    
