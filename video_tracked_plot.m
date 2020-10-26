function [f] = video_tracked_plot(vid)
% Display graphs for diagnostic of tracking success

    f = figure;


    centroid_data = cell2mat(vid.all_detected_location);
    plot(centroid_data(:,1), centroid_data(:,2))
    set ( gca, 'ydir', 'reverse' )
    title('location')
    xlim([0 726])
    ylim([0 576])
       
end