
% Sleep Consolidation
% This script loads the paths for the experiment, and creates
% the variable thePath in the workspace.

pwd
thePath.start = pwd;

[pathstr,curr_dir,ext,versn] = fileparts(pwd);
if ~strcmp(curr_dir,'SleepConsolidation')
    fprintf(['You must start the experiment from the ' curr_dir ' directory. Go there and try again.\n']);
else
    thePath.script = fullfile(thePath.start, 'script');
    thePath.stim = fullfile(thePath.start, 'stim');
    thePath.data = fullfile(thePath.start, 'data');
    thePath.list = fullfile(thePath.start, 'list');

    fn = fieldnames(thePath);
    for f = 1:length(fn)
       addpath(thePath.(fn{f})) 
    end
    
    cd(thePath.start);
end
