function [cmd] = ffmpeg_build_cmd(mov)
% converts a structure of parameters to an ffmpeg command
%
% To return an executable ffmpeg command, pass a structure of
% appropriate arguments:
%
%   [cmd] = ffmpeg(mov)
    
%% if no arguments were provided, return default structure

    if ~exist('mov', 'var') || isempty(mov)
        mov = struct;
        mov.input = '';
        mov.start = 0;
        mov.rate = 10;
        mov.duration = [];
        mov.frames = [];        
        mov.size = [0 0];
        mov.clip_trbl = [0 0 0 0]; % DEPRECATED, use .crop instead
        mov.crop = [0 0 0 0];
        mov.format = '';
        mov.remove_audio = false;
        mov.overwrite = true;
        mov.same_quality = true;
        mov.output = '';
        mov.ffmpeg_path = ffmpeg_find_path();
        mov.use_libavfilter = true;        
        cmd = mov;
        return
    end    
    
%% build command    
    
    if ~isfield(mov, 'ffmpeg_path') || isempty(mov.ffmpeg_path)
        cmd = ffmpeg_find();
    else
        cmd = mov.ffmpeg_path;
    end        

%% setup for libavfilter

    if ~isfield(mov, 'use_libavfilter')
        mov.use_libavfilter = true;
    end
    
    vf_string = '';
    
%% input file

    if isfield(mov, 'input')
        cmd = sprintf('%s -i "%s"', cmd, mov.input);
    end
    
%% add parameters    

    % start time
    if isfield(mov, 'start') && mov.start ~= 0
        cmd = sprintf('%s -ss %d', cmd, mov.start);
    end
    
    % rate
    if isfield(mov, 'rate') && ~isempty(mov.rate)
        cmd = sprintf('%s -r %d', cmd, mov.rate);
    end
           
    % duration
    if isfield(mov, 'duration') && ~isempty(mov.duration)
        cmd = sprintf('%s -t %d', cmd, mov.duration);
    end

    % total frames
    if isfield(mov, 'frames') && ~isempty(mov.frames)
        cmd = sprintf('%s -vframes %d', cmd, mov.frames);
    end

    % remove audio
    if isfield(mov, 'remove_audio') && mov.remove_audio
        cmd = sprintf('%s -an', cmd);
    end
    
    % format
    if isfield(mov, 'format') && ~isempty(mov.format)
        cmd = sprintf('%s -f %s', cmd, mov.format);
    end

    % same quality
    if isfield(mov, 'same_quality') && mov.same_quality
        cmd = sprintf('%s -qscale 0', cmd);
    end    
    
%% cropping    
   
    if mov.use_libavfilter
        if isfield(mov, 'crop') && any(mov.crop)
            % cropping cmd creation
            crop_string = sprintf('crop=%d:%d:%d:%d', mov.crop(3), mov.crop(4), mov.crop(1), mov.crop(2));
            vf_string = comma_list(vf_string, crop_string);
        end
        
    else
        if isfield(mov, 'clip_trbl') && any(mov.clip_trbl)
            mov.clip_trbl = floor(mov.clip_trbl);
            cmd = sprintf('%s -croptop %d -cropright %d -cropbottom %d -cropleft %d', cmd, ...
                mov.clip_trbl(1), ...
                mov.clip_trbl(2), ...
                mov.clip_trbl(3), ...
                mov.clip_trbl(4));
        end
    end

    
%% scale output size

    if mov.use_libavfilter

        if isfield(mov, 'size') && ~isempty(mov.size)
            scale_string = sprintf('scale=%d:%d', mov.size(1), mov.size(2));
            vf_string = comma_list(vf_string, scale_string);
        end
        
    else
        
        if isfield(mov, 'size') && any(mov.size)
            
            % old version, example "80x60" width X height
            if ischar(mov.size)
                cmd = sprintf('%s -s %s', cmd, mov.size);
                
            % new version, example [80 60] width X height
            else
                cmd = sprintf('%s -s %dx%d', cmd, mov.size(1), mov.size(2));
            end
                
        end    
    end

%% libavfilter

    if mov.use_libavfilter && ~isempty(vf_string)
        cmd = [cmd ' -vf "' vf_string '"'];
    end
           
%% specify output file    
    
    % overwrite output file
    if isfield(mov, 'overwrite') && mov.overwrite
        cmd = sprintf('%s -y', cmd);
    end
           
    % 
    if isfield(mov, 'output') && ~isempty(mov.output)
        cmd = sprintf('%s "%s"', cmd, mov.output);
    else
        error('no output file specified');
    end
           
end
           

