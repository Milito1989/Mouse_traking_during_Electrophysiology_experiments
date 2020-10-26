function [vid] = VA_object(vid)
% Compiles and reviews metrics from vid.object.props


%% Check for data reliablity/jumps and interpolate it
    Tempo_data = [vid.object.props.Centroid];
    Tempo_data = reshape(Tempo_data, [2, vid.data.frames])';
    counter = 1 ;
    for frame_num = 1:(vid.data.frames-1)
       p=1;
        %Temporarily copied data(center of detexted locations)
       P_Coordinate = [ Tempo_data(frame_num,1), Tempo_data(frame_num,2); Tempo_data(frame_num+p,1), Tempo_data(frame_num+p,2)]; 
       Eu_Dist = pdist(P_Coordinate,'euclidean');

       %I set the maximum moved distance by 100cm 
       %As it doesn't seem to be any higher value in standard analysis
       while Eu_Dist>(100*(fix(p/25)+1)) %EUdist1~=EUdist    
           counter = counter +1;
           Tempo_data(frame_num+p,1) = NaN;
           Tempo_data(frame_num+p,2) = NaN;
           p=p+1;
           if frame_num + p > vid.data.frames
               break
           end
           P_Coordinate = [ Tempo_data(frame_num,1), Tempo_data(frame_num,2); Tempo_data(frame_num+p,1), Tempo_data(frame_num+p,2)]; 
           Eu_Dist = pdist(P_Coordinate,'euclidean');

       end
       if p>1
           frame_num = frame_num + p -1;
       end
    end

    centroid_data_temp(1:(vid.timing.data_duration*25),1:2)=nan;
 
    
   for i=1:vid.data.frames
       if(mod(i,2)==0)
           centroid_data_temp(floor(5*((i-2)/2))+4,:) = Tempo_data(i,:);    
       end
       if(mod(i,2)==1)
           centroid_data_temp(floor(5*((i-1)/2))+2,:) = Tempo_data(i,:);
       end
    end
    
    %Following we replace centroid_data object location values 
    %with new values after interpolation
    centroid_data = fillmissing(centroid_data_temp,'linear',1);
    XPO = mat2cell(centroid_data,ones(1,size(centroid_data,1)));

    vid.all_detected_location = XPO;
    
    vid.data.frames = vid.timing.data_duration*25;%ceil(vid.data.frames * (5/2));

%% centroid

    vid.object.x = centroid_data(:,1) / vid.data.dims(2);
    vid.object.y = centroid_data(:,2) / vid.data.dims(1);
    
%% Location per frame
    %FSEC= vid.timing.data_start:0.25:vid.timing.data_start+vid.timing.data_duration;
    %Here we save the output in the scale from 0 to 1 
    current_dir = cd;
    cd(vid.file.analysis_dir)
    Tableout = table(vid.object.x,vid.object.y);
    writetable(Tableout,'Positions.txt');
    save('Positions_X_Y.mat', 'Tableout')

    %Here we save the output in the pixels scale
    Tableout2 = table(centroid_data(:,1),centroid_data(:,2));
    writetable(Tableout2,'Positions_pixel.txt');
    save('Positions_X_Y_pixel.mat', 'Tableout2')
    cd(current_dir);
    clear(current_dir);
    


%% movement

    % the distance variables are adjusted for physical dimensions, if
    % physical dimensions have been provided
    x_distance = diff(vid.object.x) * vid.params.physical_dims(1) ;
    y_distance = diff(vid.object.y) * vid.params.physical_dims(2) ;
    combined_distance = sqrt([(x_distance .^ 2) + (y_distance .^ 2)]);
    vid.object.movement = video_structure_means(vid, [NaN; combined_distance]);

    % movement is by frame, speed is per second
    speed = combined_distance / vid.params.data_extract_fps;
    vid.object.speed = video_structure_means(vid, [NaN; speed]);    
    
%% area and solidity

    vid.object.pixel_count = [vid.object.props.Area]';
    
    pixel_volume = vid.params.pixel_edge_length ^ 2;
    vid.object.area = vid.object.pixel_count * pixel_volume;
      

end