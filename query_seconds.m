function [answer] = query_seconds(prompt)
% Prompt user to enter a time either in seconds or minute:seconds format

    original_answer = input(sprintf('%s (in seconds or m:ss): ', prompt), 's');
    
    [answer] = time_str2secs(original_answer);
    
end