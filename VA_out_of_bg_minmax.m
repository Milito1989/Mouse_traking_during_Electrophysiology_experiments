function [vid] = VA_out_of_bg_minmax(vid)
% Identify all values in the data video that are outside the callibration min/max
%

%     job = batch('VA_out_of_bg_minmax',{vid.callibration.range.min,vid.callibration.range.max,vid.data.frames});
%     wait(job);
%     load(job,'vid.data.out_of_minmax');
%     N = feature('numcores');
%     clust = parcluster('local');
%     job = batch(clust,@VA_out_of_bg_minmax,1,{vid},'pool',N-1);
%     submit(job);
%     wait(job,'finished');
%     vid.data.out_of_minmax = fetchOutputs(job);
%     delete(job)
%     clear job

    vid.data.out_of_minmax = (bsxfun(@gt,vid.data.video,vid.callibration.range.max)) | (bsxfun(@lt,vid.data.video,vid.callibration.range.min));
    
  
end