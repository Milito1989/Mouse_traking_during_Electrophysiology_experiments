function Output_figures(vid)
% Creating output figures

%% Heat Map
%     f = figure;
%     imagesc(vid.object.heat_map);
%     colormap(jet);
%     drawnow;
%     saveas(f,fullfile(vid.file.analysis_dir,'Heat Map.jpg'));
%     close(f);
%% Object Tracking ,location

    f = video_tracked_plot(vid);
    drawnow;
    saveas(f,fullfile(vid.file.analysis_dir,'Object Location.jpg'));
    close(f);
    
%% Distance Traveled
    f = video_distance_all(vid);
    saveas(f,fullfile(vid.file.analysis_dir,'Distance_Traveled.jpg'));
    drawnow;
    close(f);
end