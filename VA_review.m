function [vid] = VA_review(vid)
% Interactive review of analysis results

%% initialize variables

    review_mode = '';
    content = [];
    content.current_frame = 1;
    do_review = false;


%% if applicable, start review process

        if do_review
            content = review_matrix_video(content);
            fprintf('At frame %d\n', content.current_frame);
            do_review = false;
        end
         
%%

    end
